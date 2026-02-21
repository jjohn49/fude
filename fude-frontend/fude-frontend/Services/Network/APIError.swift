import Foundation

enum APIError: LocalizedError {
    case networkError(Error)
    case httpError(Int)
    case decodingError(Error)
    case notFound
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let code):
            return "Server error (HTTP \(code))"
        case .decodingError(let error):
            return "Data parsing error: \(error.localizedDescription)"
        case .notFound:
            return "Item not found"
        case .invalidURL:
            return "Invalid URL"
        }
    }
}
