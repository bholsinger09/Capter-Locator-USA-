import XCTest
@testable import App

final class LifePathTests: XCTestCase {
    
    // MARK: - DailyMilestone Tests
    
    func testDailyMilestoneCreation() {
        let milestone = DailyMilestone(
            day: 1,
            title: "Test Title",
            description: "Test Description",
            action: "Test Action",
            completed: false
        )
        
        XCTAssertEqual(milestone.day, 1)
        XCTAssertEqual(milestone.title, "Test Title")
        XCTAssertEqual(milestone.description, "Test Description")
        XCTAssertEqual(milestone.action, "Test Action")
        XCTAssertFalse(milestone.completed)
    }
    
    func testDailyMilestoneToggleCompletion() {
        var milestone = DailyMilestone(
            day: 1,
            title: "Test",
            description: "Test",
            action: "Test"
        )
        
        XCTAssertFalse(milestone.completed)
        milestone.completed = true
        XCTAssertTrue(milestone.completed)
    }
    
    func testDailyMilestoneIsCodable() {
        let milestone = DailyMilestone(
            day: 5,
            title: "Sample",
            description: "Sample description",
            action: "Do something",
            completed: true
        )
        
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(milestone)
        XCTAssertNotNil(encoded)
        
        if let encoded = encoded {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(DailyMilestone.self, from: encoded)
            XCTAssertNotNil(decoded)
            XCTAssertEqual(decoded?.day, 5)
            XCTAssertEqual(decoded?.title, "Sample")
            XCTAssertTrue(decoded?.completed ?? false)
        }
    }
    
    // MARK: - LifePath Tests
    
    func testLifePathCreation() {
        let milestones = [
            DailyMilestone(day: 1, title: "Day 1", description: "Desc", action: "Act"),
            DailyMilestone(day: 2, title: "Day 2", description: "Desc", action: "Act")
        ]
        
        let path = LifePath(category: .career, milestones: milestones)
        
        XCTAssertEqual(path.category, .career)
        XCTAssertEqual(path.milestones.count, 2)
    }
    
    func testLifePathProgressPercentageEmpty() {
        let path = LifePath(category: .career, milestones: [])
        XCTAssertEqual(path.progressPercentage, 0)
    }
    
    func testLifePathProgressPercentageZeroCompleted() {
        let milestones = [
            DailyMilestone(day: 1, title: "Day 1", description: "Desc", action: "Act", completed: false),
            DailyMilestone(day: 2, title: "Day 2", description: "Desc", action: "Act", completed: false)
        ]
        
        let path = LifePath(category: .career, milestones: milestones)
        XCTAssertEqual(path.progressPercentage, 0)
    }
    
    func testLifePathProgressPercentagePartial() {
        let milestones = [
            DailyMilestone(day: 1, title: "Day 1", description: "Desc", action: "Act", completed: true),
            DailyMilestone(day: 2, title: "Day 2", description: "Desc", action: "Act", completed: false)
        ]
        
        let path = LifePath(category: .career, milestones: milestones)
        XCTAssertEqual(path.progressPercentage, 50)
    }
    
    func testLifePathProgressPercentageFull() {
        let milestones = [
            DailyMilestone(day: 1, title: "Day 1", description: "Desc", action: "Act", completed: true),
            DailyMilestone(day: 2, title: "Day 2", description: "Desc", action: "Act", completed: true)
        ]
        
        let path = LifePath(category: .career, milestones: milestones)
        XCTAssertEqual(path.progressPercentage, 100)
    }
    
    func testLifePathDaysRemainingEmpty() {
        let path = LifePath(category: .career, milestones: [])
        XCTAssertEqual(path.daysRemaining, 0)
    }
    
    func testLifePathDaysRemaining() {
        let milestones = [
            DailyMilestone(day: 1, title: "Day 1", description: "Desc", action: "Act", completed: true),
            DailyMilestone(day: 2, title: "Day 2", description: "Desc", action: "Act", completed: false),
            DailyMilestone(day: 3, title: "Day 3", description: "Desc", action: "Act", completed: false)
        ]
        
        let path = LifePath(category: .career, milestones: milestones)
        XCTAssertEqual(path.daysRemaining, 2)
    }
    
    func testLifePathIsCodable() {
        let milestones = [
            DailyMilestone(day: 1, title: "Day 1", description: "Desc", action: "Act")
        ]
        let path = LifePath(category: .career, milestones: milestones)
        
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(path)
        XCTAssertNotNil(encoded)
        
        if let encoded = encoded {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(LifePath.self, from: encoded)
            XCTAssertNotNil(decoded)
            XCTAssertEqual(decoded?.category, .career)
            XCTAssertEqual(decoded?.milestones.count, 1)
        }
    }
    
    // MARK: - PathContent Tests
    
    func testPathContentHasAllCategories() {
        let paths = PathContent.paths
        
        XCTAssertNotNil(paths[.career])
        XCTAssertNotNil(paths[.money])
        XCTAssertNotNil(paths[.relationships])
        XCTAssertNotNil(paths[.living])
        XCTAssertNotNil(paths[.direction])
        XCTAssertNotNil(paths[.more])
        XCTAssertNotNil(paths[.unknown])
        // Note: .politics is a guidance-only category, not a 30-day path
        XCTAssertEqual(LifePathCategory.allCases.count, 8)
    }
    
    func testCareerPathHas30Days() {
        XCTAssertEqual(PathContent.careerPath.count, 30)
    }
    
    func testMoneyPathHas30Days() {
        XCTAssertEqual(PathContent.moneyPath.count, 30)
    }
    
    func testRelationshipsPathHas30Days() {
        XCTAssertEqual(PathContent.relationshipsPath.count, 30)
    }
    
    func testLivingPathHas30Days() {
        XCTAssertEqual(PathContent.livingPath.count, 30)
    }
    
    func testDirectionPathHas30Days() {
        XCTAssertEqual(PathContent.directionPath.count, 30)
    }
    
    func testMorePathHas30Days() {
        XCTAssertEqual(PathContent.morePath.count, 30)
    }
    
    func testUnknownPathHas30Days() {
        XCTAssertEqual(PathContent.unknownPath.count, 30)
    }
    
    func testPathMilestonesAreSequential() {
        let paths = [
            PathContent.careerPath,
            PathContent.moneyPath,
            PathContent.relationshipsPath,
            PathContent.livingPath,
            PathContent.directionPath,
            PathContent.morePath,
            PathContent.unknownPath
        ]
        
        for path in paths {
            for (index, milestone) in path.enumerated() {
                XCTAssertEqual(milestone.day, index + 1, "Days should be sequential starting from 1")
            }
        }
    }
    
    func testPathMilestoneTitlesNotEmpty() {
        let paths = [
            PathContent.careerPath,
            PathContent.moneyPath,
            PathContent.relationshipsPath,
            PathContent.livingPath,
            PathContent.directionPath,
            PathContent.morePath,
            PathContent.unknownPath
        ]
        
        for path in paths {
            for milestone in path {
                XCTAssertFalse(milestone.title.isEmpty, "Milestone title should not be empty")
                XCTAssertFalse(milestone.description.isEmpty, "Milestone description should not be empty")
                XCTAssertFalse(milestone.action.isEmpty, "Milestone action should not be empty")
            }
        }
    }
    
    // MARK: - LifePathCategory Tests
    
    func testAllLifePathCategoriesHaveEmoji() {
        for category in LifePathCategory.allCases {
            XCTAssertFalse(category.emoji.isEmpty, "\(category) should have emoji")
        }
    }
    
    func testAllLifePathCategoriesHaveTitle() {
        for category in LifePathCategory.allCases {
            XCTAssertFalse(category.title.isEmpty, "\(category) should have title")
        }
    }
    
    func testAllLifePathCategoriesHaveDescription() {
        for category in LifePathCategory.allCases {
            XCTAssertFalse(category.description.isEmpty, "\(category) should have description")
        }
    }
    
    func testLifePathCategoryIsCodable() {
        for category in LifePathCategory.allCases {
            let encoder = JSONEncoder()
            let encoded = try? encoder.encode(category)
            XCTAssertNotNil(encoded, "\(category) should be encodable")
            
            if let encoded = encoded {
                let decoder = JSONDecoder()
                let decoded = try? decoder.decode(LifePathCategory.self, from: encoded)
                XCTAssertNotNil(decoded, "\(category) should be decodable")
                XCTAssertEqual(decoded, category)
            }
        }
    }
    
    // MARK: - Category Specific Content Tests
    
    func testCareerPathContentQuality() {
        let path = PathContent.careerPath
        
        // Check that days are labeled correctly
        XCTAssertTrue(path[0].title.lowercased().contains("assess"))
        
        // Check milestone day 30
        XCTAssertEqual(path[29].day, 30)
        XCTAssertTrue(path[29].title.lowercased().contains("celebrate"))
    }
    
    func testMoneyPathContentQuality() {
        let path = PathContent.moneyPath
        
        XCTAssertTrue(path[0].title.lowercased().contains("know"))
        XCTAssertTrue(path[0].title.lowercased().contains("number"))
    }
    
    func testRelationshipsPathContentQuality() {
        let path = PathContent.relationshipsPath
        
        XCTAssertTrue(path[0].title.lowercased().contains("audit"))
    }
    
    func testLivingPathContentQuality() {
        let path = PathContent.livingPath
        
        XCTAssertTrue(path[0].title.lowercased().contains("assess"))
        XCTAssertTrue(path[0].title.lowercased().contains("living"))
    }
    
    func testDirectionPathContentQuality() {
        let path = PathContent.directionPath
        
        XCTAssertTrue(path[0].title.lowercased().contains("values"))
    }
    
    func testMorePathContentQuality() {
        let path = PathContent.morePath
        
        XCTAssertTrue(path[0].title.lowercased().contains("define"))
    }
    
    func testUnknownPathContentQuality() {
        let path = PathContent.unknownPath
        
        XCTAssertTrue(path[0].title.lowercased().contains("exploration"))
    }
    
    // MARK: - Data Consistency Tests
    
    func testNoDuplicateMilestonesDayWithinPath() {
        let paths = [
            PathContent.careerPath,
            PathContent.moneyPath,
            PathContent.relationshipsPath,
            PathContent.livingPath,
            PathContent.directionPath,
            PathContent.morePath,
            PathContent.unknownPath
        ]
        
        for path in paths {
            let days = path.map { $0.day }
            let uniqueDays = Set(days)
            XCTAssertEqual(days.count, uniqueDays.count, "No duplicate days should exist within a path")
        }
    }
    
    func testAllPathMilestonesTitlesSynthetic() {
        let paths = [
            (name: "Career", path: PathContent.careerPath),
            (name: "Money", path: PathContent.moneyPath),
            (name: "Relationships", path: PathContent.relationshipsPath),
            (name: "Living", path: PathContent.livingPath),
            (name: "Direction", path: PathContent.directionPath),
            (name: "More", path: PathContent.morePath),
            (name: "Unknown", path: PathContent.unknownPath)
        ]
        
        for (name, path) in paths {
            for milestone in path {
                XCTAssertGreaterThan(milestone.title.count, 3, "\(name) path milestone title should be meaningful")
            }
        }
    }
}
