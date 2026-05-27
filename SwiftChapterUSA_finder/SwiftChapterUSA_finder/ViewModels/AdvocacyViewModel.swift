//
//  AdvocacyViewModel.swift
//  SwiftChapterUSA Finder
//

import Foundation

enum AdvocacyIssue: String, CaseIterable, Identifiable {
    case campusFreeSpeech = "Campus Free Speech"
    case chapterSupport = "Chapter Support"
    case studentOutreach = "Student Outreach"
    case campusSafety = "Campus Safety"

    var id: String { rawValue }

    var subject: String {
        switch self {
        case .campusFreeSpeech:
            return "Protect free speech rights on campus"
        case .chapterSupport:
            return "Request support for our TPUSA chapter"
        case .studentOutreach:
            return "Increase student engagement and outreach"
        case .campusSafety:
            return "Strengthen campus safety and support resources"
        }
    }

    var description: String {
        switch self {
        case .campusFreeSpeech:
            return "Send a clear message about academic freedom and student speech."
        case .chapterSupport:
            return "Ask for practical support for local TPUSA chapter activities."
        case .studentOutreach:
            return "Share ideas that help connect students to conservative events."
        case .campusSafety:
            return "Raise awareness about safety, mental health, and event security."
        }
    }
}
struct AdvocacyFetchResult {
    let officials: [ElectedOfficial]
    let sourceDescription: String
}

class AdvocacyViewModel: ObservableObject {
    private let chapterService: ChapterServiceProtocol
    private let congressService: CongressServiceProtocol

    init(chapterService: ChapterServiceProtocol,
         congressService: CongressServiceProtocol = CongressAPIService()) {
        self.chapterService = chapterService
        self.congressService = congressService
    }

    var stateOptions: [String] {
        let states = Set(chapterService.universities.map { $0.state })
        return ["All States"] + states.sorted()
    }

    func filteredUniversities(state: String, query: String) -> [University] {
        var universities = chapterService.universities

        if state != "All States" {
            universities = universities.filter { $0.state == state }
        }

        if !query.isEmpty {
            universities = universities.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.city.localizedCaseInsensitiveContains(query) ||
                $0.state.localizedCaseInsensitiveContains(query)
            }
        }

        return universities.sorted { $0.state < $1.state }
    }

    func electedOfficials(for state: String, university: University?) -> [ElectedOfficial] {
        let selectedState = state.trimmingCharacters(in: .whitespacesAndNewlines)
        return AdvocacyData.officials(forState: selectedState, university: university)
    }

    /// Async public API that attempts to fetch live data, then reports whether local fallback data was used.
    func fetchOfficialsResult(for state: String, university: University?) async -> AdvocacyFetchResult {
        do {
            let officials = try await congressService.fetchOfficials(forState: state, university: university)
            print("[Advocacy] Congress fetch succeeded. state=\(state), university=\(university?.name ?? "nil"), count=\(officials.count)")
            for (idx, o) in officials.prefix(3).enumerated() {
                print("[Advocacy] Official[\(idx)] name=\(o.name), title=\(o.displayTitle), location=\(o.locationText), phone=\(o.phone ?? "nil"), email=\(o.email ?? "nil"), website=\(o.website ?? "nil")")
            }
            return AdvocacyFetchResult(officials: officials, sourceDescription: "live Congress API")
        } catch CongressServiceError.missingAPIKey {
            let fallback = electedOfficials(for: state, university: university)
            print("[Advocacy] Missing Congress API key. Using local fallback. state=\(state), university=\(university?.name ?? "nil"), fallbackCount=\(fallback.count)")
            return AdvocacyFetchResult(officials: fallback, sourceDescription: "local fallback (missing API key)")
        } catch {
            let fallback = electedOfficials(for: state, university: university)
            print("[Advocacy] Congress fetch failed. Using local fallback. state=\(state), university=\(university?.name ?? "nil"), fallbackCount=\(fallback.count), error=\(error)")
            return AdvocacyFetchResult(officials: fallback, sourceDescription: "local fallback (API error)")
        }
    }

    func fetchOfficials(for state: String, university: University?) async -> [ElectedOfficial] {
        await fetchOfficialsResult(for: state, university: university).officials
    }

    func emailSubject(for issue: AdvocacyIssue, official: ElectedOfficial?) -> String {
        if let official = official, official.chamber == "House" {
            return "\(issue.subject) — \(official.district ?? official.state)"
        }
        return issue.subject
    }

    func emailBody(for issue: AdvocacyIssue, user: User?, university: University?, official: ElectedOfficial?) -> String {
        let userName = user?.fullName ?? "A campus member"
        let campus = university?.name ?? user?.university ?? "my university"
        let location = university?.displayLocation ?? user?.state ?? "your district"
        let greeting = official.map { "Dear \($0.name)," } ?? "Dear Representative,"

        let issueText: String
        switch issue {
        case .campusFreeSpeech:
            issueText = "I am writing to ask for your support in protecting free speech on campus at \(campus). Recent incidents have shown the need for stronger protections for student expression in \(location)."
        case .chapterSupport:
            issueText = "Our TPUSA chapter at \(campus) is building student engagement, and we would appreciate your support in connecting our group with resources, outreach opportunities, or campus leadership."
        case .studentOutreach:
            issueText = "Students at \(campus) want to engage more directly with conservative ideas and civic life. I would like your assistance in helping our chapter organize a campus event or meet-and-greet for constituents."
        case .campusSafety:
            issueText = "Campus safety is a top priority for students at \(campus). We would welcome your help in improving communication, supporting mental health resources, and making sure student-run events are safe and secure."
        }

        return "\(greeting)\n\nMy name is \(userName). I am a student and member of TPUSA at \(campus) in \(location). \(issueText)\n\nThank you for your consideration and for representing students in your district.\n\nSincerely,\n\(userName)"
    }

    func makeMailURL(to email: String, subject: String, body: String) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }
}
