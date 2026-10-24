//
//  Reachability.swift
//  Common
//
//  Network connectivity checker using URLSession
//

import Foundation
import Combine

public class Reachability: ObservableObject {
    public static let shared = Reachability()
    
    @Published public var isConnected = true
    
    private init() {
        checkConnectivity()
        // Check connectivity every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkConnectivity()
        }
    }
    
    public func checkConnectivity() {
        var request = URLRequest(url: URL(string: "https://www.apple.com")!)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3.0
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, _ in
            DispatchQueue.main.async {
                self?.isConnected = (response as? HTTPURLResponse)?.statusCode == 200
            }
        }
        task.resume()
    }
}
