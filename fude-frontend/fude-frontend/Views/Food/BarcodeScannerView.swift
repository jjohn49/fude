import SwiftUI
import VisionKit

// VisionKit DataScannerViewController wrapper.
// DataScanner requires iOS 16+ and a physical device with a camera.
// It is not available in the Simulator — the parent view guards availability.

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        private var hasScanned = false

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            guard !hasScanned else { return }
            guard case .barcode(let barcode) = addedItems.first,
                  let payload = barcode.payloadStringValue else { return }
            hasScanned = true
            dataScanner.stopScanning()
            onScan(payload)
        }
    }
}

// MARK: - Availability wrapper

struct BarcodeScannerAvailabilityView: View {
    let onScan: (String) -> Void

    var body: some View {
        if DataScannerViewController.isAvailable && DataScannerViewController.isSupported {
            BarcodeScannerView(onScan: onScan)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "camera.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Camera not available")
                    .font(.headline)
                Text("Barcode scanning requires a physical iPhone or iPad with a camera.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.05))
        }
    }
}
