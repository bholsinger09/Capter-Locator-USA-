import Foundation

/// Standard error types for the application
public enum AppError: LocalizedError, Identifiable, Equatable {
    case networkError(String)
    case decodingError(String)
    case validationError(String)
    case notFound(String)
    case unauthorized
    case serverError(Int, String)
    case unknown(String)
    
    public var id: String {
        errorDescription ?? "Unknown error"
    }
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError(let message):
            return "Failed to load data: \(message)"
        case .validationError(let message):
            return "Invalid input: \(message)"
        case .notFound(let message):
            return "Not found: \(message)"
        case .unauthorized:
            return "You are not authorized to perform this action"
        case .serverError(let code, let message):
            return "Server Error (\(code)): \(message)"
        case .unknown(let message):
            return "An unknown error occurred: \(message)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .decodingError:
            return "Please try updating the app or clearing cache."
        case .validationError:
            return "Please correct the highlighted fields and try again."
        case .notFound:
            return "The requested item does not exist."
        case .unauthorized:
            return "Please log in and try again."
        case .serverError:
            return "The server is temporarily unavailable. Please try again later."
        case .unknown:
            return "Please try again or contact support."
        }
    }
}

/// Protocol for viewmodels that handle loading states
public protocol LoadableViewModel: AnyObject {
    associatedtype T: Equatable
    
    var state: LoadingState<T> { get set }
}

/// Generic loading state enum
public enum LoadingState<T>: Equatable where T: Equatable {
    case idle
    case loading
    case success(T)
    case failure(AppError)
    
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    public var value: T? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
    
    public var error: AppError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
