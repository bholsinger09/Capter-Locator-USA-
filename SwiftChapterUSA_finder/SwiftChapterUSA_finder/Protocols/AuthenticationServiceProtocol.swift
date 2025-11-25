//
//  AuthenticationServiceProtocol.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation
import Combine

protocol AuthenticationServiceProtocol: AnyObject {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
    var errorMessage: String? { get }
    
    func register(email: String, password: String, firstName: String, lastName: String, state: String, university: String?)
    func login(email: String, password: String)
    func logout()
    func updateUser(_ user: User)
    func deleteAccount()
}
