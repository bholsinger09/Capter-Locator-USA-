import Foundation

public class MembershipManager: ObservableObject {
    @Published public var memberChapters: Set<String> = [
        "Alabama State University Chapter",
        "Arizona State University Chapter",
        "Arkansas State University Chapter",
        "Auburn University Chapter",
        "Boise State University Chapter",
        "Boston University Chapter",
        "Bowdoin College Chapter",
        "Brigham Young University Chapter",
        "Brown University Chapter",
        "Case Western Reserve University Chapter",
        "Casper College Chapter",
        "Clemson University Chapter",
        "College of Charleston Chapter",
        "Colorado State University Chapter",
        "Columbia University Chapter",
        "Cornell University Chapter",
        "Creighton University Chapter",
        "Dartmouth College Chapter",
        "Delaware State University Chapter",
        "Duke University Chapter",
        "Florida State University Chapter",
        "Georgia Institute of Technology Chapter",
        "Georgia State University Chapter",
        "Idaho State University Chapter",
        "Indiana University Chapter",
        "Iowa State University Chapter",
        "Johns Hopkins University Chapter",
        "Kansas State University Chapter",
        "Laramie County Community College Chapter",
        "Louisiana State University Chapter",
        "Louisiana Tech University Chapter",
        "Marshall University Chapter",
        "Massachusetts Institute of Technology Chapter",
        "Miami University Chapter",
        "Michigan State University Chapter",
        "Middlebury College Chapter",
        "Minnesota State University, Mankato Chapter",
        "Minot State University Chapter",
        "Mississippi State University Chapter",
        "Montana State University Chapter",
        "Montana Tech Chapter",
        "Nevada State College Chapter",
        "New Mexico Institute of Mining and Technology Chapter",
        "New Mexico State University Chapter",
        "New York University Chapter",
        "North Carolina State University Chapter",
        "North Dakota State University Chapter",
        "Northern Arizona University Chapter",
        "Northwestern University Chapter",
        "Norwich University Chapter",
        "Ohio State University Chapter",
        "Oklahoma State University Chapter",
        "Oregon State University Chapter",
        "Pennsylvania State University Chapter",
        "Portland State University Chapter",
        "Princeton University Chapter",
        "Providence College Chapter",
        "Purdue University Chapter",
        "Quinnipiac University Chapter",
        "Rutgers University Chapter",
        "Southern Methodist University Chapter",
        "Southern New Hampshire University Chapter",
        "St. Cloud State University Chapter",
        "Stanford University Chapter",
        "Syracuse University Chapter",
        "Temple University Chapter",
        "Texas A&M University Chapter",
        "Texas Christian University Chapter",
        "Texas State University Chapter",
        "The College of New Jersey Chapter",
        "Towson University Chapter",
        "Tulane University Chapter",
        "University of Alabama Chapter",
        "University of Alabama at Birmingham Chapter",
        "University of Alaska Anchorage Chapter",
        "University of Alaska Fairbanks Chapter",
        "University of Alaska Southeast Chapter",
        "University of Arizona Chapter",
        "University of Arkansas Chapter",
        "University of Arkansas at Little Rock Chapter",
        "University of California, Berkeley Chapter",
        "University of California, Los Angeles Chapter",
        "University of California, San Diego Chapter",
        "University of Central Arkansas Chapter",
        "University of Central Florida Chapter",
        "University of Chicago Chapter",
        "University of Cincinnati Chapter",
        "University of Colorado Boulder Chapter",
        "University of Connecticut Chapter",
        "University of Delaware Chapter",
        "University of Florida Chapter",
        "University of Georgia Chapter",
        "University of Houston Chapter",
        "University of Idaho Chapter",
        "University of Illinois at Urbana-Champaign Chapter",
        "University of Iowa Chapter",
        "University of Kansas Chapter",
        "University of Louisiana at Lafayette Chapter",
        "University of Maine Chapter",
        "University of Maryland Chapter",
        "University of Miami Chapter",
        "University of Michigan Chapter",
        "University of Minnesota Chapter",
        "University of Mississippi Chapter",
        "University of Missouri Chapter",
        "University of Montana Chapter",
        "University of Nebraska Omaha Chapter",
        "University of Nebraska-Lincoln Chapter",
        "University of Nevada, Las Vegas Chapter",
        "University of Nevada, Reno Chapter",
        "University of New Hampshire Chapter",
        "University of New Haven Chapter",
        "University of New Mexico Chapter",
        "University of North Carolina Chapter",
        "University of North Dakota Chapter",
        "University of Northern Iowa Chapter",
        "University of Oklahoma Chapter",
        "University of Oregon Chapter",
        "University of Pennsylvania Chapter",
        "University of Pittsburgh Chapter",
        "University of Rhode Island Chapter",
        "University of South Carolina Chapter",
        "University of South Florida Chapter",
        "University of Southern California Chapter",
        "University of Southern Maine Chapter",
        "University of Southern Mississippi Chapter",
        "University of Tennessee Chapter",
        "University of Texas at Austin Chapter",
        "University of Tulsa Chapter",
        "University of Utah Chapter",
        "University of Vermont Chapter",
        "University of Virginia Chapter",
        "University of Wyoming Chapter",
        "Utah State University Chapter",
        "Vanderbilt University Chapter",
        "Virginia Commonwealth University Chapter",
        "Virginia Tech Chapter",
        "Wayne State University Chapter",
        "West Virginia State University Chapter",
        "West Virginia University Chapter",
        "Wichita State University Chapter",
        "Wilmington University Chapter",
        "Yale University Chapter",
    ] {
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
