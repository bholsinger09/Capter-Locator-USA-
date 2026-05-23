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
    private let apiKey: String?
    private let session: URLSession

    init(apiKey: String? = Bundle.main.object(forInfoDictionaryKey: "CONGRESS_API_KEY") as? String,
         session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func fetchOfficials(forState state: String, university: University?) async throws -> [ElectedOfficial] {
        // If no API key is provided, skip network lookups and return local sample data
        guard let key = apiKey, !key.isEmpty else {
            return AdvocacyData.officials(forState: state, university: university)
        }

        // Prefer the official Congress.gov API (api.congress.gov). If that fails, fall back to ProPublica, then local data.
        do {
            let cg = try await fetchCongressGovMembers(state: state, apiKey: key)
            if !cg.isEmpty { return cg }
        } catch {
            // swallow and try ProPublica next
        }

        // Try ProPublica as a secondary source
        do {
            async let senators = fetchSenators(state: state, apiKey: key)
            async let reps = fetchRepresentatives(state: state, apiKey: key)
            let (s, r) = try await (senators, reps)
            let combined = s + r
            if !combined.isEmpty { return combined }
        } catch {
            // fall through to local data
        }

        return AdvocacyData.officials(forState: state, university: university)
    }

    private func fetchCongressGovMembers(state: String, apiKey: String) async throws -> [ElectedOfficial] {
        let code = stateAddingNormalization(state)
        guard let url = URL(string: "https://api.congress.gov/member/\(code)?api_key=\(apiKey)") else {
            return []
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        do {
            let (data, response) = try await session.data(for: req)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw CongressServiceError.networkError(NSError(domain: "CongressGov", code: http.statusCode, userInfo: nil))
            }

            // Parse JSON loosely to map available fields into ElectedOfficial
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let dict = json as? [String: Any] else {
                throw CongressServiceError.decodingError(NSError(domain: "CongressGov", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response"]))
            }

            // Look for common container keys that hold member arrays
            let possibleKeys = ["member", "members", "results", "data"]
            for key in possibleKeys {
                if let arr = dict[key] as? [[String: Any]] {
                    let mapped = arr.compactMap { item -> ElectedOfficial? in
                        let name = (item["name"] as? String) ?? {
                            if let first = item["first_name"] as? String {
                                return first + " " + (item["last_name"] as? String ?? "")
                            }
                            return nil
                        }()

                        guard let nm = name else { return nil }

                        let party = item["party"] as? String
                        let office = item["office"] as? String
                        let phone = item["phone"] as? String
                        let website = item["url"] as? String ?? item["website"] as? String
                        let email = item["email"] as? String
                        let stateVal = item["state"] as? String ?? state
                        let district = (item["district"] as? String) ?? (item["districtNumber"] as? String)

                        return ElectedOfficial(name: nm, office: office ?? "", chamber: office?.contains("Senate") == true ? "Senate" : "House", party: party ?? "", state: stateVal, district: district, phone: phone, email: email, website: website)
                    }

                    if !mapped.isEmpty { return mapped }
                }
            }

            // If no arrays were found, try to see if the dict itself looks like a single member
            if let single = dict as? [String: Any], (single["name"] as? String) != nil {
                let name = single["name"] as? String ?? ""
                let party = single["party"] as? String
                let office = single["office"] as? String
                let phone = single["phone"] as? String
                let website = single["url"] as? String ?? single["website"] as? String
                let email = single["email"] as? String
                let district = (single["district"] as? String) ?? (single["districtNumber"] as? String)

                return [ElectedOfficial(name: name, office: office ?? "", chamber: office?.contains("Senate") == true ? "Senate" : "House", party: party ?? "", state: state, district: district, phone: phone, email: email, website: website)]
            }

            throw CongressServiceError.decodingError(NSError(domain: "CongressGov", code: -2, userInfo: [NSLocalizedDescriptionKey: "No member data found"]))
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
