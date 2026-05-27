//
//  CongressAPIService.swift
//  SwiftChapterUSA Finder
//

import Foundation

protocol CongressServiceProtocol {
    func fetchOfficials(forState state: String, university: University?) async throws -> [ElectedOfficial]
}

enum CongressServiceError: Error {
    case missingAPIKey
    case networkError(Error)
    case decodingError(Error)
}

/// Simple ProPublica-based implementation. If no API key is configured, the service falls back to local sample data.
final class CongressAPIService: CongressServiceProtocol {
    private let congressGovKey: String?
    private let propublicaKey: String?
    private let session: URLSession

    init(apiKey: String? = nil,
         session: URLSession = .shared) {
        let resolvedCongressKey = apiKey ?? ProcessInfo.processInfo.environment["CONGRESS_API_KEY"] ?? Self.normalizedKeyValue(for: "CONGRESS_API_KEY")
        let resolvedProPublicaKey = ProcessInfo.processInfo.environment["PROPUBLICA_API_KEY"] ?? Self.normalizedKeyValue(for: "PROPUBLICA_API_KEY")

        self.congressGovKey = resolvedCongressKey
        self.propublicaKey = resolvedProPublicaKey
        self.session = session
    }

    private static func normalizedKeyValue(for key: String) -> String? {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        // Ignore unresolved build expressions and placeholder defaults.
        if trimmed.hasPrefix("$(") && trimmed.hasSuffix(")") {
            return nil
        }
        if trimmed.lowercased().contains("your_") && trimmed.lowercased().contains("api_key") {
            return nil
        }
        return trimmed
    }

    func fetchOfficials(forState state: String, university: University?) async throws -> [ElectedOfficial] {
        // If no API key is provided, skip network lookups and return local sample data
        // Determine available keys
        let cgKey = congressGovKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        let ppKey = propublicaKey?.trimmingCharacters(in: .whitespacesAndNewlines)

        // If no keys are configured, let the view model decide how to fall back and report diagnostics.
        if (cgKey == nil || cgKey == "") && (ppKey == nil || ppKey == "") {
            throw CongressServiceError.missingAPIKey
        }

        var lastError: Error?

        // Prefer the official Congress.gov API (api.congress.gov) when a key is present.
        if let cg = cgKey, !cg.isEmpty {
            do {
                let cgMembers = try await fetchCongressGovMembers(state: state, apiKey: cg)
                if !cgMembers.isEmpty { return cgMembers }
            } catch {
                lastError = error
                print("CongressGov fetch failed: \(error). Trying secondary sources.")
            }
        }

        // Try ProPublica as a secondary source if a ProPublica key is available
        if let pp = ppKey, !pp.isEmpty {
            do {
                async let senators = fetchSenators(state: state, apiKey: pp)
                async let reps = fetchRepresentatives(state: state, apiKey: pp)
                let (s, r) = try await (senators, reps)
                let combined = s + r
                if !combined.isEmpty { return combined }
            } catch {
                lastError = error
                print("ProPublica fetch failed: \(error).")
            }
        }

        if let lastError {
            throw lastError
        }
        throw CongressServiceError.networkError(NSError(domain: "Congress", code: 204, userInfo: nil))
    }

    private func fetchCongressGovMembers(state: String, apiKey: String) async throws -> [ElectedOfficial] {
        let code = stateAddingNormalization(state)
        guard let url = URL(string: "https://api.congress.gov/v3/member/\(code)?api_key=\(apiKey)&format=json") else {
            return []
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        do {
            let (data, response) = try await session.data(for: req)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw CongressServiceError.networkError(NSError(domain: "CongressGov", code: http.statusCode, userInfo: nil))
            }

            let decoded = try JSONDecoder().decode(CongressGovMembersResponse.self, from: data)
            let members = decoded.members
            if members.isEmpty { return [] }

            return try await withThrowingTaskGroup(of: ElectedOfficial?.self) { group in
                for member in members {
                    group.addTask {
                        try await self.makeCongressGovOfficial(from: member, fallbackState: state, apiKey: apiKey)
                    }
                }

                var officials: [ElectedOfficial] = []
                for try await official in group {
                    if let official = official {
                        officials.append(official)
                    }
                }
                return officials
            }
        } catch let err as DecodingError {
            throw CongressServiceError.decodingError(err)
        } catch {
            throw CongressServiceError.networkError(error)
        }
    }

    private func makeCongressGovOfficial(from member: CongressGovMember, fallbackState: String, apiKey: String) async throws -> ElectedOfficial {
        let detail = try await fetchCongressGovMemberDetail(bioguideId: member.bioguideId, apiKey: apiKey)

        let name = detail.name ?? member.name
        let party = detail.partyName ?? member.partyName ?? ""
        let stateVal = detail.state ?? member.state ?? fallbackState
        let latestTerm = parseCongressGovTerms(from: detail.terms?.value)?.last ?? parseCongressGovTerms(from: member.terms?.value)?.last
        let chamber = latestTerm?.chamber ?? ""
        let office: String
        if let type = latestTerm?.memberType?.lowercased() {
            if type.contains("senator") { office = "U.S. Senator" }
            else if type.contains("representative") { office = "U.S. Representative" }
            else { office = type.capitalized }
        } else if chamber.lowercased().contains("senate") {
            office = "U.S. Senator"
        } else if chamber.lowercased().contains("house") {
            office = "U.S. Representative"
        } else {
            office = chamber.isEmpty ? "Member of Congress" : chamber
        }

        let district = latestTerm?.district?.isEmpty == false ? latestTerm?.district : detail.addressInformation?.district
        let phone = detail.addressInformation?.phoneNumber
        let website = detail.officialWebsiteUrl ?? member.officialWebsiteUrl

        return ElectedOfficial(
            name: name,
            office: office,
            chamber: chamber,
            party: party,
            state: stateVal,
            district: district,
            phone: phone,
            email: nil,
            website: website
        )
    }

    private func fetchCongressGovMemberDetail(bioguideId: String, apiKey: String) async throws -> CongressGovMemberDetail {
        guard let url = URL(string: "https://api.congress.gov/v3/member/\(bioguideId)?api_key=\(apiKey)&format=json") else {
            throw CongressServiceError.networkError(NSError(domain: "CongressGov", code: -1, userInfo: nil))
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        do {
            let (data, response) = try await session.data(for: req)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw CongressServiceError.networkError(NSError(domain: "CongressGov", code: http.statusCode, userInfo: nil))
            }
            let decoded = try JSONDecoder().decode(CongressGovMemberDetailResponse.self, from: data)
            return decoded.member
        } catch let err as DecodingError {
            throw CongressServiceError.decodingError(err)
        } catch {
            throw CongressServiceError.networkError(error)
        }
    }

    private func fetchSenators(state: String, apiKey: String) async throws -> [ElectedOfficial] {
        // ProPublica endpoint: /members/senate/{state}/current.json
        let code = stateAddingNormalization(state)
        guard let url = URL(string: "https://api.propublica.org/congress/v1/members/senate/\(code)/current.json") else {
            return []
        }

        var req = URLRequest(url: url)
        req.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

        do {
            let (data, _) = try await session.data(for: req)
            let decoded = try JSONDecoder().decode(ProPublicaMembersResponse.self, from: data)
            return decoded.results.map { r in
                ElectedOfficial(name: "\(r.first_name) \(r.last_name)", office: "U.S. Senator", chamber: "Senate", party: r.party, state: r.state, district: nil, phone: r.phone, email: nil, website: r.url)
            }
        } catch let err as DecodingError {
            throw CongressServiceError.decodingError(err)
        } catch {
            throw CongressServiceError.networkError(error)
        }
    }

    private func fetchRepresentatives(state: String, apiKey: String) async throws -> [ElectedOfficial] {
        // ProPublica endpoint: /members/house/{state}/current.json
        let code = stateAddingNormalization(state)
        guard let url = URL(string: "https://api.propublica.org/congress/v1/members/house/\(code)/current.json") else {
            return []
        }

        var req = URLRequest(url: url)
        req.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

        do {
            let (data, _) = try await session.data(for: req)
            let decoded = try JSONDecoder().decode(ProPublicaMembersResponse.self, from: data)
            return decoded.results.map { r in
                ElectedOfficial(name: "\(r.first_name) \(r.last_name)", office: "U.S. Representative", chamber: "House", party: r.party, state: r.state, district: r.district, phone: r.phone, email: r.oc_email, website: r.url)
            }
        } catch let err as DecodingError {
            throw CongressServiceError.decodingError(err)
        } catch {
            throw CongressServiceError.networkError(error)
        }
    }

    private func stateAddingNormalization(_ state: String) -> String {
        // ProPublica endpoints expect a two-letter state code in many cases; the sample data uses full state names.
        // Simplify: if it's already two letters return uppercased, otherwise try to get first word's state code via lookup.
        let trimmed = state.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count == 2 {
            return trimmed.uppercased()
        }
        // Basic mapping for common states; expand as needed.
        let mapping: [String: String] = [
            "California": "CA",
            "Texas": "TX",
            "Florida": "FL",
            "Arizona": "AZ",
            "Maryland": "MD",
            "Massachusetts": "MA",
            "New York": "NY"
        ]
        return mapping[trimmed] ?? trimmed
    }
}

// MARK: - Congress.gov response models
private struct CongressGovMembersResponse: Decodable {
    let members: [CongressGovMember]
}

private struct CongressGovMemberDetailResponse: Decodable {
    let member: CongressGovMemberDetail
}

private struct CongressGovMember: Decodable {
    let bioguideId: String
    let name: String
    let partyName: String?
    let state: String?
    let terms: AnyDecodable?
    let officialWebsiteUrl: String?
}

private struct CongressGovMemberDetail: Decodable {
    let bioguideId: String?
    let name: String?
    let partyName: String?
    let state: String?
    let officialWebsiteUrl: String?
    let addressInformation: CongressGovAddressInformation?
    let terms: AnyDecodable?
}

private struct CongressGovAddressInformation: Decodable {
    let phoneNumber: String?
    let district: String?
}

private func parseCongressGovTerms(from raw: Any?) -> [CongressGovTerm]? {
    guard let raw = raw else {
        return nil
    }

    if let array = raw as? [Any], let items = decodeTermArray(from: array) {
        return items
    }

    if let dict = raw as? [String: Any] {
        if let direct = decodeTermObject(from: dict) {
            return [direct]
        }

        for key in ["items", "item", "terms", "term"] {
            if let nested = dict[key], let items = parseCongressGovTerms(from: nested) {
                return items
            }
        }

        for value in dict.values {
            if let items = parseCongressGovTerms(from: value) {
                return items
            }
        }
    }

    return nil
}

private func decodeTermArray(from any: [Any]) -> [CongressGovTerm]? {
    guard let data = try? JSONSerialization.data(withJSONObject: any, options: []) else {
        return nil
    }
    return try? JSONDecoder().decode([CongressGovTerm].self, from: data)
}

private func decodeTermObject(from any: [String: Any]) -> CongressGovTerm? {
    guard let data = try? JSONSerialization.data(withJSONObject: any, options: []) else {
        return nil
    }
    return try? JSONDecoder().decode(CongressGovTerm.self, from: data)
}

private struct CongressGovTermItems: Decodable {
    let item: [CongressGovTerm]
}

private struct AnyDecodable: Decodable {
    let value: Any

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer() {
            if single.decodeNil() {
                value = NSNull()
                return
            }
            if let bool = try? single.decode(Bool.self) {
                value = bool
                return
            }
            if let int = try? single.decode(Int.self) {
                value = int
                return
            }
            if let double = try? single.decode(Double.self) {
                value = double
                return
            }
            if let string = try? single.decode(String.self) {
                value = string
                return
            }
            if let array = try? single.decode([AnyDecodable].self) {
                value = array.map { $0.value }
                return
            }
        }

        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        var dict: [String: Any] = [:]
        for key in container.allKeys {
            dict[key.stringValue] = try container.decode(AnyDecodable.self, forKey: key).value
        }
        value = dict
    }
}

private struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}

private struct CongressGovTerm: Decodable {
    let chamber: String?
    let memberType: String?
    let district: String?
}

// MARK: - ProPublica response models
private struct ProPublicaMembersResponse: Decodable {
    let status: String
    let results: [ProPublicaMember]
}

private struct ProPublicaMember: Decodable {
    let id: String
    let first_name: String
    let last_name: String
    let party: String
    let state: String
    let district: String?
    let phone: String?
    let office: String?
    let url: String?
    let oc_email: String?
}
