import Foundation

struct ChapterContactInfo: Codable {
    let state: String
    let presidentName: String
    let title: String?
    let contactEmail: String?
    let phoneNumber: String?
    let memberCount: Int?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case state
        case presidentName
        case title
        case contactEmail
        case phoneNumber
        case memberCount
        case description
    }
}

struct ChaptersDataFile: Codable {
    let chapters: [ChapterContactInfo]
}

class ChaptersDataLoader {
    static let shared = ChaptersDataLoader()
    
    private var cachedData: [ChapterContactInfo] = []
    private var isLoaded = false
    
    func loadChaptersData() -> [ChapterContactInfo] {
        if isLoaded {
            return cachedData
        }
        
        guard let url = Bundle.module.url(forResource: "chapters-data", withExtension: "json") else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let file = try decoder.decode(ChaptersDataFile.self, from: data)
            self.cachedData = file.chapters
            self.isLoaded = true
            return file.chapters
        } catch {
            print("Error loading chapters data: \(error)")
            return []
        }
    }
    
    func getChapterContact(forState state: String) -> ChapterContactInfo? {
        let data = loadChaptersData()
        return data.first { $0.state.lowercased() == state.lowercased() }
    }
}
