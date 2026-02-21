import Foundation

enum AppConfiguration {
    enum Environment {
        case development
        case production
    }

    static let current: Environment = {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }()

    static var backendBaseURL: URL {
        switch current {
        case .development:
            // Update this to your local backend address when running locally
            return URL(string: "http://localhost:8080")!
        case .production:
            // Update this to your deployed Fly.io / Railway URL
            return URL(string: "https://fude-backend.fly.dev")!
        }
    }
}
