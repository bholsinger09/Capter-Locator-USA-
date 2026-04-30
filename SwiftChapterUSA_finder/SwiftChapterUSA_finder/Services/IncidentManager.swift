//
//  IncidentManager.swift
//  SwiftChapterUSA Finder
//
//  Created on April 30, 2026.
//

import Foundation
import CloudKit
import Combine

class IncidentManager: ObservableObject, IncidentManagerProtocol {
    @Published var incidents: [Incident] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    init() {
        container = CKContainer(identifier: "iCloud.ChapterFinder")
        publicDatabase = container.publicCloudDatabase
    }
    
    // MARK: - Create Operation
    
    /// Create a new incident report
    func createIncident(_ incident: Incident) async -> Bool {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        print("📤 [IncidentManager] Creating new incident: \(incident.title)")
        
        var incidentToSave = incident
        incidentToSave.createdAt = Date()
        incidentToSave.updatedAt = Date()
        
        let record = incidentToSave.toRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            print("✅ [IncidentManager] Successfully created incident: \(savedRecord.recordID.recordName)")
            
            if var savedIncident = Incident.fromRecord(savedRecord) {
                savedIncident.recordName = savedRecord.recordID.recordName
                
                await MainActor.run {
                    self.incidents.append(savedIncident)
                    self.incidents.sort { $0.createdAt > $1.createdAt } // Most recent first
                    self.errorMessage = nil
                }
            }
            
            return true
        } catch {
            print("❌ [IncidentManager] Failed to create incident: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to create incident: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Fetch Operations
    
    /// Fetch all active incidents
    func fetchIncidents() async {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        let predicate = NSPredicate(format: "isActive == %d", 1)
        let query = CKQuery(recordType: "Incident", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedIncidents = allRecords.compactMap { Incident.fromRecord($0) }
            
            await MainActor.run {
                self.incidents = fetchedIncidents
                self.errorMessage = nil
            }
            
            print("✅ [IncidentManager] Fetched \(fetchedIncidents.count) incidents")
        } catch {
            print("❌ [IncidentManager] Failed to fetch incidents: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to load incidents: \(error.localizedDescription)"
            }
        }
    }
    
    /// Fetch incidents for a specific state
    func fetchIncidents(forState state: String) async -> [Incident] {
        let predicate = NSPredicate(format: "isActive == %d AND state == %@", 1, state)
        let query = CKQuery(recordType: "Incident", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedIncidents = allRecords.compactMap { Incident.fromRecord($0) }
            print("✅ [IncidentManager] Fetched \(fetchedIncidents.count) incidents for \(state)")
            return fetchedIncidents
        } catch {
            print("❌ [IncidentManager] Failed to fetch incidents: \(error)")
            return []
        }
    }
    
    /// Fetch incidents for a specific university
    func fetchIncidents(forUniversity university: String) async -> [Incident] {
        let predicate = NSPredicate(format: "isActive == %d AND universityName == %@", 1, university)
        let query = CKQuery(recordType: "Incident", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedIncidents = allRecords.compactMap { Incident.fromRecord($0) }
            print("✅ [IncidentManager] Fetched \(fetchedIncidents.count) incidents for \(university)")
            return fetchedIncidents
        } catch {
            print("❌ [IncidentManager] Failed to fetch incidents: \(error)")
            return []
        }
    }
    
    /// Fetch incidents of a specific type
    func fetchIncidents(ofType type: Incident.IncidentType) async -> [Incident] {
        let predicate = NSPredicate(format: "isActive == %d AND incidentType == %@", 1, type.rawValue)
        let query = CKQuery(recordType: "Incident", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedIncidents = allRecords.compactMap { Incident.fromRecord($0) }
            print("✅ [IncidentManager] Fetched \(fetchedIncidents.count) incidents of type \(type.rawValue)")
            return fetchedIncidents
        } catch {
            print("❌ [IncidentManager] Failed to fetch incidents: \(error)")
            return []
        }
    }
    
    /// Fetch only verified incidents
    func fetchVerifiedIncidents() async -> [Incident] {
        let predicate = NSPredicate(format: "isActive == %d AND verificationStatus == %@", 1, Incident.VerificationStatus.verified.rawValue)
        let query = CKQuery(recordType: "Incident", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            var allRecords: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor? = nil
            
            repeat {
                let (records, nextCursor) = try await fetchRecordsWithCursor(query: query, cursor: cursor)
                allRecords.append(contentsOf: records)
                cursor = nextCursor
            } while cursor != nil
            
            let fetchedIncidents = allRecords.compactMap { Incident.fromRecord($0) }
            print("✅ [IncidentManager] Fetched \(fetchedIncidents.count) verified incidents")
            return fetchedIncidents
        } catch {
            print("❌ [IncidentManager] Failed to fetch verified incidents: \(error)")
            return []
        }
    }
    
    // MARK: - Update Operation
    
    /// Update an existing incident
    func updateIncident(_ incident: Incident) async -> Bool {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        print("📤 [IncidentManager] Updating incident: \(incident.title)")
        
        var incidentToUpdate = incident
        incidentToUpdate.updatedAt = Date()
        
        let record = incidentToUpdate.toRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            print("✅ [IncidentManager] Successfully updated incident")
            
            if var updatedIncident = Incident.fromRecord(savedRecord) {
                updatedIncident.recordName = savedRecord.recordID.recordName
                
                await MainActor.run {
                    if let index = self.incidents.firstIndex(where: { $0.id == updatedIncident.id }) {
                        self.incidents[index] = updatedIncident
                    }
                    self.errorMessage = nil
                }
            }
            
            return true
        } catch {
            print("❌ [IncidentManager] Failed to update incident: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to update incident: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Delete Operation
    
    /// Delete an incident (soft delete by setting isActive = false)
    func deleteIncident(_ incident: Incident) async -> Bool {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        print("📤 [IncidentManager] Deleting incident: \(incident.title)")
        
        var incidentToDelete = incident
        incidentToDelete.isActive = false
        incidentToDelete.updatedAt = Date()
        
        let record = incidentToDelete.toRecord()
        
        do {
            _ = try await publicDatabase.save(record)
            print("✅ [IncidentManager] Successfully deleted incident")
            
            await MainActor.run {
                self.incidents.removeAll { $0.id == incident.id }
                self.errorMessage = nil
            }
            
            return true
        } catch {
            print("❌ [IncidentManager] Failed to delete incident: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to delete incident: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Support/Engagement Operations
    
    /// Increment the support count for an incident
    func incrementSupportCount(for incident: Incident) async -> Bool {
        var updatedIncident = incident
        updatedIncident.supportCount += 1
        return await updateIncident(updatedIncident)
    }
    
    // MARK: - Campus Statistics
    
    /// Get statistics for a specific campus
    func getCampusStatistics(for university: String) async -> CampusStats? {
        let universityIncidents = await fetchIncidents(forUniversity: university)
        
        guard !universityIncidents.isEmpty else { return nil }
        
        let firstIncident = universityIncidents.first!
        let totalIncidents = universityIncidents.count
        let verifiedIncidents = universityIncidents.filter { $0.isVerified }.count
        let criticalIncidents = universityIncidents.filter { $0.severity == .critical }.count
        let recentIncidents = universityIncidents.filter { $0.isRecent }.count
        
        return CampusStats(
            universityName: university,
            state: firstIncident.state,
            city: firstIncident.city,
            coordinate: firstIncident.coordinate,
            totalIncidents: totalIncidents,
            verifiedIncidents: verifiedIncidents,
            criticalIncidents: criticalIncidents,
            recentIncidents: recentIncidents
        )
    }
    
    /// Get statistics for all campuses
    func getAllCampusStatistics() async -> [CampusStats] {
        await fetchIncidents()
        
        let universities = Set(incidents.map { $0.universityName })
        var allStats: [CampusStats] = []
        
        for university in universities {
            if let stats = await getCampusStatistics(for: university) {
                allStats.append(stats)
            }
        }
        
        // Sort by hostility score (highest first)
        return allStats.sorted { $0.hostilityScore > $1.hostilityScore }
    }
    
    // MARK: - Verification
    
    /// Verify an incident (admin/moderator action)
    func verifyIncident(_ incident: Incident, verifiedBy: String) async -> Bool {
        var verifiedIncident = incident
        verifiedIncident.verificationStatus = .verified
        verifiedIncident.verifiedBy = verifiedBy
        verifiedIncident.verifiedDate = Date()
        
        return await updateIncident(verifiedIncident)
    }
    
    // MARK: - Search
    
    /// Search incidents by keyword
    func searchIncidents(query: String) async -> [Incident] {
        await fetchIncidents()
        
        let lowercaseQuery = query.lowercased()
        
        return incidents.filter { incident in
            incident.title.lowercased().contains(lowercaseQuery) ||
            incident.description.lowercased().contains(lowercaseQuery) ||
            incident.universityName.lowercased().contains(lowercaseQuery) ||
            incident.tags.contains(where: { $0.lowercased().contains(lowercaseQuery) })
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func fetchRecordsWithCursor(query: CKQuery, cursor: CKQueryOperation.Cursor?) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
        if let cursor = cursor {
            let (matchResults, queryCursor) = try await publicDatabase.records(continuingMatchFrom: cursor)
            let records = matchResults.compactMap { try? $0.1.get() }
            return (records, queryCursor)
        } else {
            let (matchResults, queryCursor) = try await publicDatabase.records(matching: query)
            let records = matchResults.compactMap { try? $0.1.get() }
            return (records, queryCursor)
        }
    }
}

// MARK: - CloudKit Extensions

extension Incident {
    /// Convert Incident to CloudKit Record
    func toRecord() -> CKRecord {
        let recordID: CKRecord.ID
        if let recordName = recordName {
            recordID = CKRecord.ID(recordName: recordName)
        } else {
            recordID = CKRecord.ID(recordName: id.uuidString)
        }
        
        let record = CKRecord(recordType: "Incident", recordID: recordID)
        
        // Basic information
        record["id"] = id.uuidString
        record["title"] = title
        record["description"] = description
        record["incidentDate"] = incidentDate
        record["reportedDate"] = reportedDate
        
        // Location
        record["universityName"] = universityName
        record["campusLocation"] = campusLocation
        record["city"] = city
        record["state"] = state
        if let lat = latitude, let lon = longitude {
            record["location"] = CLLocation(latitude: lat, longitude: lon)
        }
        
        // Classification
        record["incidentType"] = incidentType.rawValue
        record["severity"] = severity.rawValue
        record["tags"] = tags
        
        // People involved
        record["targetedIndividual"] = targetedIndividual
        record["perpetrator"] = perpetrator
        record["perpetratorRole"] = perpetratorRole
        record["witnesses"] = witnesses
        
        // Evidence
        record["evidenceURLs"] = evidenceURLs
        record["evidenceDescription"] = evidenceDescription
        record["newsArticleURLs"] = newsArticleURLs
        
        // Reporter
        record["reporterEmail"] = reporterEmail
        record["reporterName"] = reporterName
        record["isAnonymous"] = isAnonymous ? 1 : 0
        record["chapterID"] = chapterID?.uuidString
        record["chapterName"] = chapterName
        
        // Status
        record["verificationStatus"] = verificationStatus.rawValue
        record["verifiedBy"] = verifiedBy
        record["verifiedDate"] = verifiedDate
        record["isPublic"] = isPublic ? 1 : 0
        record["isActive"] = isActive ? 1 : 0
        
        // Engagement
        record["viewCount"] = viewCount
        record["supportCount"] = supportCount
        record["shareCount"] = shareCount
        
        // Resolution
        record["resolutionStatus"] = resolutionStatus.rawValue
        record["resolutionDescription"] = resolutionDescription
        record["resolutionDate"] = resolutionDate
        
        // Metadata
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
        
        return record
    }
    
    /// Create Incident from CloudKit Record
    static func fromRecord(_ record: CKRecord) -> Incident? {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let title = record["title"] as? String,
            let description = record["description"] as? String,
            let incidentDate = record["incidentDate"] as? Date,
            let universityName = record["universityName"] as? String,
            let city = record["city"] as? String,
            let state = record["state"] as? String,
            let incidentTypeString = record["incidentType"] as? String,
            let incidentType = Incident.IncidentType(rawValue: incidentTypeString),
            let severityString = record["severity"] as? String,
            let severity = Incident.Severity(rawValue: severityString),
            let reporterEmail = record["reporterEmail"] as? String
        else {
            print("❌ [Incident] Failed to parse required fields from record")
            return nil
        }
        
        // Location
        let location = record["location"] as? CLLocation
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        // Get verification status
        let verificationStatusString = record["verificationStatus"] as? String ?? Incident.VerificationStatus.pending.rawValue
        let verificationStatus = Incident.VerificationStatus(rawValue: verificationStatusString) ?? .pending
        
        // Get resolution status
        let resolutionStatusString = record["resolutionStatus"] as? String ?? Incident.ResolutionStatus.unresolved.rawValue
        let resolutionStatus = Incident.ResolutionStatus(rawValue: resolutionStatusString) ?? .unresolved
        
        // Build incident
        var incident = Incident(
            id: id,
            recordName: record.recordID.recordName,
            title: title,
            description: description,
            incidentDate: incidentDate,
            reportedDate: record["reportedDate"] as? Date ?? Date(),
            universityName: universityName,
            campusLocation: record["campusLocation"] as? String,
            city: city,
            state: state,
            latitude: latitude,
            longitude: longitude,
            incidentType: incidentType,
            severity: severity,
            tags: record["tags"] as? [String] ?? [],
            targetedIndividual: record["targetedIndividual"] as? String,
            perpetrator: record["perpetrator"] as? String,
            perpetratorRole: record["perpetratorRole"] as? String,
            witnesses: record["witnesses"] as? [String] ?? [],
            evidenceURLs: record["evidenceURLs"] as? [String] ?? [],
            evidenceDescription: record["evidenceDescription"] as? String,
            newsArticleURLs: record["newsArticleURLs"] as? [String] ?? [],
            reporterEmail: reporterEmail,
            reporterName: record["reporterName"] as? String,
            isAnonymous: (record["isAnonymous"] as? Int ?? 0) == 1,
            chapterID: (record["chapterID"] as? String).flatMap { UUID(uuidString: $0) },
            chapterName: record["chapterName"] as? String,
            verificationStatus: verificationStatus,
            verifiedBy: record["verifiedBy"] as? String,
            verifiedDate: record["verifiedDate"] as? Date,
            isPublic: (record["isPublic"] as? Int ?? 1) == 1,
            isActive: (record["isActive"] as? Int ?? 1) == 1,
            viewCount: record["viewCount"] as? Int ?? 0,
            supportCount: record["supportCount"] as? Int ?? 0,
            shareCount: record["shareCount"] as? Int ?? 0,
            resolutionStatus: resolutionStatus,
            resolutionDescription: record["resolutionDescription"] as? String,
            resolutionDate: record["resolutionDate"] as? Date,
            createdAt: record["createdAt"] as? Date ?? Date(),
            updatedAt: record["updatedAt"] as? Date ?? Date()
        )
        
        return incident
    }
}
