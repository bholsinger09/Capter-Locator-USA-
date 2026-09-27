//
//  ServiceProtocol.swift
//  Common
//
//  Foundation protocol for all services
//

import Foundation

/// Base protocol for all services in the application
public protocol Service: AnyObject {
    /// Service name for logging and debugging
    var serviceName: String { get }
}

/// Base protocol for error handling in services
public protocol ServiceError: Error, LocalizedError {
    var errorDescription: String? { get }
    var failureReason: String? { get }
    var recoverySuggestion: String? { get }
}

/// Base repository protocol for data access
public protocol Repository: AnyObject {
    associatedtype Item
    
    func fetch() async throws -> [Item]
    func save(_ item: Item) async throws
    func delete(_ id: UUID) async throws
}
