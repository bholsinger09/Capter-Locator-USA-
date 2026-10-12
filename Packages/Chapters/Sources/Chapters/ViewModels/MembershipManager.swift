import Foundation

public class MembershipManager: ObservableObject {
    @Published public var memberChapters: Set<String> = ["Arizona State University Chapter", "Texas State"] {
        didSet {
            print("🔄 MembershipManager updated: \(memberChapters)")
        }
    }
    
    // Track how many app users have joined each chapter
    @Published public var appMemberCounts: [String: Int] = [:] {
        didSet {
            print("📊 App member counts updated: \(appMemberCounts)")
        }
    }
    
    public init() {
        print("✅ MembershipManager initialized with: \(memberChapters)")
        // Initialize member counts for each chapter the user is in
        for chapter in memberChapters {
            appMemberCounts[chapter] = (appMemberCounts[chapter] ?? 0) + 1
        }
    }
    
    public func isMember(of chapterName: String) -> Bool {
        let result = memberChapters.contains(chapterName)
        print("🔍 Checking membership for '\(chapterName)': \(result)")
        return result
    }
    
    public func joinChapter(_ chapterName: String) {
        print("➕ Joining chapter: \(chapterName)")
        memberChapters.insert(chapterName)
        appMemberCounts[chapterName] = (appMemberCounts[chapterName] ?? 0) + 1
        print("📊 After join - Members: \(memberChapters), Counts: \(appMemberCounts)")
    }
    
    public func leaveChapter(_ chapterName: String) {
        print("➖ Leaving chapter: \(chapterName)")
        memberChapters.remove(chapterName)
        appMemberCounts[chapterName] = max(0, (appMemberCounts[chapterName] ?? 1) - 1)
        print("📊 After leave - Members: \(memberChapters), Counts: \(appMemberCounts)")
    }
    
    public func getAppMemberCount(for chapterName: String) -> Int {
        return appMemberCounts[chapterName] ?? 0
    }
    
    public func toggleMembership(for chapterName: String) {
        if isMember(of: chapterName) {
            leaveChapter(chapterName)
        } else {
            joinChapter(chapterName)
        }
    }
}
