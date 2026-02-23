//
//  ContentView.swift
//  fude-frontend
//
//  Created by John Johnston on 2/21/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        AuthGateView()
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
        .modelContainer(previewContainer())
}
#Preview("With Sample Data") {
    ContentView()
        .environment(AuthViewModel())
        .modelContainer(previewContainerWithSampleData())
}

