//
//  IncidentManagerProtocol.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import Foundation

protocol IncidentManagerProtocol: ObservableObject {
    var incidents: [Incident] { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    
    func createIncident(_ incident: Incident) async -> Bool
    func fetchIncidents() async
    func fetchIncidents(forState state: String) async -> [Incident]
    func fetchIncidents(forUniversity university: String) async -> [Incident]
    func fetchIncidents(ofType type: Incident.IncidentType) async -> [Incident]
    func fetchVerifiedIncidents() async -> [Incident]
    func updateIncident(_ incident: Incident) async -> Bool
    func deleteIncident(_ incident: Incident) async -> Bool
    func incrementSupportCount(for incident: Incident) async -> Bool
    func getCampusStatistics(for university: String) async -> CampusStats?
    func getAllCampusStatistics() async -> [CampusStats]
    func verifyIncident(_ incident: Incident, verifiedBy: String) async -> Bool
    func searchIncidents(query: String) async -> [Incident]
}
