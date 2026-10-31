import Foundation

public struct ChapterContactInfo: Codable {
    public let state: String
    public let presidentName: String
    public let title: String?
    public let contactEmail: String?
    public let memberCount: Int?
    public let description: String?
    public let linkedIn: String?
    
    enum CodingKeys: String, CodingKey {
        case state
        case presidentName
        case title
        case contactEmail
        case memberCount
        case description
        case linkedIn
    }
}

struct ChaptersDataFile: Codable {
    let chapters: [ChapterContactInfo]
}

public class ChaptersDataLoader {
    public static let shared = ChaptersDataLoader()
    
    private var cachedData: [ChapterContactInfo] = []
    private var isLoaded = false
    
    public func loadChaptersData() -> [ChapterContactInfo] {
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
    
    public func getChapterContact(forState state: String) -> ChapterContactInfo? {
        let data = loadChaptersData()
        return data.first { $0.state.lowercased() == state.lowercased() }
    }
}
