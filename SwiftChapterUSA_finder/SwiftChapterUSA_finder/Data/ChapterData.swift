//
//  ChapterData.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import Foundation

struct ChapterData {
    static let sampleChapters: [Chapter] = [
        // California (5 chapters)
        Chapter(name: "USC Trojans TPUSA", state: "California", city: "Los Angeles", university: "University of Southern California", presidentName: "Sarah Johnson", contactEmail: "usc@tpusa.local", phoneNumber: "213-555-0101", description: "Active chapter promoting conservative values on campus", memberCount: 145, meetingLocation: "Student Union Room 305", meetingSchedule: "Wednesdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1577836800), stateCoordinatorName: "Jennifer Wellenstein", stateCoordinatorEmail: "jennifer.wellenstein@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/jenniferwellenstein/"),
        
        Chapter(name: "UCLA Bruins TPUSA", state: "California", city: "Los Angeles", university: "University of California, Los Angeles", presidentName: "Michael Chen", contactEmail: "ucla@tpusa.local", phoneNumber: "310-555-0102", description: "Engaging students in political discourse", memberCount: 132, meetingLocation: "Ackerman Union", meetingSchedule: "Thursdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1580515200), stateCoordinatorName: "Jennifer Wellenstein", stateCoordinatorEmail: "jennifer.wellenstein@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/jenniferwellenstein/"),
        
        Chapter(name: "Stanford TPUSA", state: "California", city: "Stanford", university: "Stanford University", presidentName: "Emily Rodriguez", contactEmail: "stanford@tpusa.local", phoneNumber: "650-555-0103", description: "Conservative voices at Stanford", memberCount: 98, meetingLocation: "White Plaza", meetingSchedule: "Tuesdays 5PM", dateEstablished: Date(timeIntervalSince1970: 1583020800), stateCoordinatorName: "Jennifer Wellenstein", stateCoordinatorEmail: "jennifer.wellenstein@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/jenniferwellenstein/"),
        
        Chapter(name: "Berkeley TPUSA", state: "California", city: "Berkeley", university: "University of California, Berkeley", presidentName: "David Kim", contactEmail: "berkeley@tpusa.local", phoneNumber: "510-555-0104", description: "Free speech advocates at UC Berkeley", memberCount: 167, meetingLocation: "Sproul Hall", meetingSchedule: "Mondays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1585699200), stateCoordinatorName: "Jennifer Wellenstein", stateCoordinatorEmail: "jennifer.wellenstein@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/jenniferwellenstein/"),
        
        Chapter(name: "San Diego TPUSA", state: "California", city: "San Diego", university: "University of California, San Diego", presidentName: "Jessica Martinez", contactEmail: "ucsd@tpusa.local", phoneNumber: "858-555-0105", description: "Conservative student organization", memberCount: 112, meetingLocation: "Price Center", meetingSchedule: "Fridays 4PM", dateEstablished: Date(timeIntervalSince1970: 1588291200), stateCoordinatorName: "Jennifer Wellenstein", stateCoordinatorEmail: "jennifer.wellenstein@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/jenniferwellenstein/"),
        
        // Texas (5 chapters)
        Chapter(name: "UT Austin TPUSA", state: "Texas", city: "Austin", university: "University of Texas at Austin", presidentName: "Brandon Williams", contactEmail: "utaustin@tpusa.local", phoneNumber: "512-555-0201", description: "Largest chapter in Texas", memberCount: 203, meetingLocation: "Texas Union", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1590969600)),
        
        Chapter(name: "Texas A&M TPUSA", state: "Texas", city: "College Station", university: "Texas A&M University", presidentName: "Ashley Thompson", contactEmail: "tamu@tpusa.local", phoneNumber: "979-555-0202", description: "Aggies for conservative values", memberCount: 189, meetingLocation: "Memorial Student Center", meetingSchedule: "Thursdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1593648000)),
        
        Chapter(name: "Houston TPUSA", state: "Texas", city: "Houston", university: "University of Houston", presidentName: "Carlos Ramirez", contactEmail: "uh@tpusa.local", phoneNumber: "713-555-0203", description: "Conservative student activism", memberCount: 156, meetingLocation: "Student Center South", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1596240000)),
        
        Chapter(name: "SMU TPUSA", state: "Texas", city: "Dallas", university: "Southern Methodist University", presidentName: "Lauren Anderson", contactEmail: "smu@tpusa.local", phoneNumber: "214-555-0204", description: "Mustangs for America", memberCount: 87, meetingLocation: "Hughes-Trigg Student Center", meetingSchedule: "Mondays 5:30PM", dateEstablished: Date(timeIntervalSince1970: 1598918400)),
        
        Chapter(name: "TCU TPUSA", state: "Texas", city: "Fort Worth", university: "Texas Christian University", presidentName: "Ryan Parker", contactEmail: "tcu@tpusa.local", phoneNumber: "817-555-0205", description: "Horned Frogs conservative voice", memberCount: 93, meetingLocation: "Brown-Lupton University Union", meetingSchedule: "Wednesdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1601510400)),
        
        // Florida (5 chapters)
        Chapter(name: "UF TPUSA", state: "Florida", city: "Gainesville", university: "University of Florida", presidentName: "Amanda Scott", contactEmail: "uf@tpusa.local", phoneNumber: "352-555-0301", description: "Gators for freedom", memberCount: 178, meetingLocation: "Reitz Union", meetingSchedule: "Thursdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1604188800)),
        
        Chapter(name: "FSU TPUSA", state: "Florida", city: "Tallahassee", university: "Florida State University", presidentName: "Justin Moore", contactEmail: "fsu@tpusa.local", phoneNumber: "850-555-0302", description: "Seminoles standing for liberty", memberCount: 165, meetingLocation: "Student Union", meetingSchedule: "Wednesdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1606780800)),
        
        Chapter(name: "Miami TPUSA", state: "Florida", city: "Coral Gables", university: "University of Miami", presidentName: "Sofia Hernandez", contactEmail: "miami@tpusa.local", phoneNumber: "305-555-0303", description: "Hurricanes for conservative principles", memberCount: 142, meetingLocation: "Shalala Student Center", meetingSchedule: "Tuesdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1609459200)),
        
        Chapter(name: "UCF TPUSA", state: "Florida", city: "Orlando", university: "University of Central Florida", presidentName: "Marcus Green", contactEmail: "ucf@tpusa.local", phoneNumber: "407-555-0304", description: "Knights for America", memberCount: 134, meetingLocation: "Student Union", meetingSchedule: "Mondays 7PM", dateEstablished: Date(timeIntervalSince1970: 1612137600)),
        
        Chapter(name: "USF TPUSA", state: "Florida", city: "Tampa", university: "University of South Florida", presidentName: "Rachel Davis", contactEmail: "usf@tpusa.local", phoneNumber: "813-555-0305", description: "Bulls for freedom", memberCount: 119, meetingLocation: "Marshall Student Center", meetingSchedule: "Fridays 5PM", dateEstablished: Date(timeIntervalSince1970: 1614556800)),
        
        // New York (4 chapters)
        Chapter(name: "Columbia TPUSA", state: "New York", city: "New York", university: "Columbia University", presidentName: "Alexander Brown", contactEmail: "columbia@tpusa.local", phoneNumber: "212-555-0401", description: "Conservative voices in NYC", memberCount: 95, meetingLocation: "Lerner Hall", meetingSchedule: "Thursdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1617235200)),
        
        Chapter(name: "NYU TPUSA", state: "New York", city: "New York", university: "New York University", presidentName: "Olivia Wilson", contactEmail: "nyu@tpusa.local", phoneNumber: "212-555-0402", description: "Violets for liberty", memberCount: 108, meetingLocation: "Kimmel Center", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1619827200)),
        
        Chapter(name: "Cornell TPUSA", state: "New York", city: "Ithaca", university: "Cornell University", presidentName: "Ethan Taylor", contactEmail: "cornell@tpusa.local", phoneNumber: "607-555-0403", description: "Big Red conservatives", memberCount: 89, meetingLocation: "Willard Straight Hall", meetingSchedule: "Tuesdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1622505600)),
        
        Chapter(name: "Syracuse TPUSA", state: "New York", city: "Syracuse", university: "Syracuse University", presidentName: "Isabella Martinez", contactEmail: "syracuse@tpusa.local", phoneNumber: "315-555-0404", description: "Orange for America", memberCount: 76, meetingLocation: "Schine Student Center", meetingSchedule: "Mondays 7PM", dateEstablished: Date(timeIntervalSince1970: 1625097600)),
        
        // Pennsylvania (4 chapters)
        Chapter(name: "Penn State TPUSA", state: "Pennsylvania", city: "State College", university: "Pennsylvania State University", presidentName: "Jacob Anderson", contactEmail: "psu@tpusa.local", phoneNumber: "814-555-0501", description: "Nittany Lions for freedom", memberCount: 172, meetingLocation: "HUB-Robeson Center", meetingSchedule: "Thursdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1627776000)),
        
        Chapter(name: "UPenn TPUSA", state: "Pennsylvania", city: "Philadelphia", university: "University of Pennsylvania", presidentName: "Sophia Lee", contactEmail: "upenn@tpusa.local", phoneNumber: "215-555-0502", description: "Quakers for conservative values", memberCount: 102, meetingLocation: "Houston Hall", meetingSchedule: "Wednesdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1630368000)),
        
        Chapter(name: "Pitt TPUSA", state: "Pennsylvania", city: "Pittsburgh", university: "University of Pittsburgh", presidentName: "Noah Thomas", contactEmail: "pitt@tpusa.local", phoneNumber: "412-555-0503", description: "Panthers standing strong", memberCount: 118, meetingLocation: "William Pitt Union", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1633046400)),
        
        Chapter(name: "Temple TPUSA", state: "Pennsylvania", city: "Philadelphia", university: "Temple University", presidentName: "Emma White", contactEmail: "temple@tpusa.local", phoneNumber: "215-555-0504", description: "Owls for liberty", memberCount: 94, meetingLocation: "Student Center", meetingSchedule: "Mondays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1635638400)),
        
        // Ohio (4 chapters)
        Chapter(name: "Ohio State TPUSA", state: "Ohio", city: "Columbus", university: "Ohio State University", presidentName: "Liam Johnson", contactEmail: "osu@tpusa.local", phoneNumber: "614-555-0601", description: "Buckeyes for America", memberCount: 195, meetingLocation: "Ohio Union", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1638316800)),
        
        Chapter(name: "Cincinnati TPUSA", state: "Ohio", city: "Cincinnati", university: "University of Cincinnati", presidentName: "Ava Harris", contactEmail: "uc@tpusa.local", phoneNumber: "513-555-0602", description: "Bearcats for freedom", memberCount: 128, meetingLocation: "Tangeman University Center", meetingSchedule: "Thursdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1640908800)),
        
        Chapter(name: "CWRU TPUSA", state: "Ohio", city: "Cleveland", university: "Case Western Reserve University", presidentName: "Mason Clark", contactEmail: "cwru@tpusa.local", phoneNumber: "216-555-0603", description: "Spartans for conservative values", memberCount: 71, meetingLocation: "Tinkham Veale University Center", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1643587200)),
        
        Chapter(name: "Miami OH TPUSA", state: "Ohio", city: "Oxford", university: "Miami University", presidentName: "Charlotte Walker", contactEmail: "miamioh@tpusa.local", phoneNumber: "513-555-0604", description: "RedHawks standing for freedom", memberCount: 83, meetingLocation: "Armstrong Student Center", meetingSchedule: "Mondays 6PM", dateEstablished: Date(timeIntervalSince1970: 1646179200)),
        
        // Illinois (3 chapters)
        Chapter(name: "UIUC TPUSA", state: "Illinois", city: "Champaign", university: "University of Illinois at Urbana-Champaign", presidentName: "William Martinez", contactEmail: "uiuc@tpusa.local", phoneNumber: "217-555-0701", description: "Fighting Illini for liberty", memberCount: 156, meetingLocation: "Illini Union", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1648771200)),
        
        Chapter(name: "Northwestern TPUSA", state: "Illinois", city: "Evanston", university: "Northwestern University", presidentName: "Mia Rodriguez", contactEmail: "northwestern@tpusa.local", phoneNumber: "847-555-0702", description: "Wildcats for America", memberCount: 91, meetingLocation: "Norris University Center", meetingSchedule: "Thursdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1651363200)),
        
        Chapter(name: "Chicago TPUSA", state: "Illinois", city: "Chicago", university: "University of Chicago", presidentName: "James Brown", contactEmail: "uchicago@tpusa.local", phoneNumber: "773-555-0703", description: "Maroons for freedom", memberCount: 78, meetingLocation: "Reynolds Club", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1654041600)),
        
        // Michigan (3 chapters)
        Chapter(name: "UMich TPUSA", state: "Michigan", city: "Ann Arbor", university: "University of Michigan", presidentName: "Benjamin Davis", contactEmail: "umich@tpusa.local", phoneNumber: "734-555-0801", description: "Wolverines for conservative values", memberCount: 183, meetingLocation: "Michigan Union", meetingSchedule: "Wednesdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1656633600)),
        
        Chapter(name: "MSU TPUSA", state: "Michigan", city: "East Lansing", university: "Michigan State University", presidentName: "Abigail Wilson", contactEmail: "msu@tpusa.local", phoneNumber: "517-555-0802", description: "Spartans for America", memberCount: 167, meetingLocation: "Union Building", meetingSchedule: "Thursdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1659312000)),
        
        Chapter(name: "Wayne State TPUSA", state: "Michigan", city: "Detroit", university: "Wayne State University", presidentName: "Daniel Garcia", contactEmail: "wayne@tpusa.local", phoneNumber: "313-555-0803", description: "Warriors for freedom", memberCount: 95, meetingLocation: "Student Center", meetingSchedule: "Tuesdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1661990400)),
        
        // Arizona (3 chapters)
        Chapter(name: "ASU TPUSA", state: "Arizona", city: "Tempe", university: "Arizona State University", presidentName: "Jonathan Coon", contactEmail: "jonathan.coon@tpusa.com", phoneNumber: "480-555-0901", description: "Sun Devils for liberty", memberCount: 201, meetingLocation: "Memorial Union", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1664582400)),
        
        Chapter(name: "UofA TPUSA", state: "Arizona", city: "Tucson", university: "University of Arizona", presidentName: "Matthew Taylor", contactEmail: "uofa@tpusa.local", phoneNumber: "520-555-0902", description: "Wildcats for America", memberCount: 147, meetingLocation: "Student Union Memorial Center", meetingSchedule: "Thursdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1667260800)),
        
        Chapter(name: "NAU TPUSA", state: "Arizona", city: "Flagstaff", university: "Northern Arizona University", presidentName: "Emily Anderson", contactEmail: "nau@tpusa.local", phoneNumber: "928-555-0903", description: "Lumberjacks for freedom", memberCount: 68, meetingLocation: "University Union", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1669852800)),
        
        // Georgia (3 chapters)
        Chapter(name: "UGA TPUSA", state: "Georgia", city: "Athens", university: "University of Georgia", presidentName: "Andrew White", contactEmail: "uga@tpusa.local", phoneNumber: "706-555-1001", description: "Bulldogs for conservative values", memberCount: 174, meetingLocation: "Tate Student Center", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1672531200)),
        
        Chapter(name: "Georgia Tech TPUSA", state: "Georgia", city: "Atlanta", university: "Georgia Institute of Technology", presidentName: "Victoria Martin", contactEmail: "gatech@tpusa.local", phoneNumber: "404-555-1002", description: "Yellow Jackets for liberty", memberCount: 129, meetingLocation: "Student Center", meetingSchedule: "Thursdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1675209600)),
        
        Chapter(name: "Georgia State TPUSA", state: "Georgia", city: "Atlanta", university: "Georgia State University", presidentName: "Christopher Lee", contactEmail: "gsu@tpusa.local", phoneNumber: "404-555-1003", description: "Panthers for America", memberCount: 112, meetingLocation: "Student Center", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1677628800)),
        
        // North Carolina (3 chapters)
        Chapter(name: "UNC TPUSA", state: "North Carolina", city: "Chapel Hill", university: "University of North Carolina", presidentName: "Madison Thomas", contactEmail: "unc@tpusa.local", phoneNumber: "919-555-1101", description: "Tar Heels for freedom", memberCount: 158, meetingLocation: "Student Union", meetingSchedule: "Wednesdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1680307200)),
        
        Chapter(name: "Duke TPUSA", state: "North Carolina", city: "Durham", university: "Duke University", presidentName: "Elijah Harris", contactEmail: "duke@tpusa.local", phoneNumber: "919-555-1102", description: "Blue Devils for conservative values", memberCount: 97, meetingLocation: "Bryan Center", meetingSchedule: "Thursdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1682899200)),
        
        Chapter(name: "NC State TPUSA", state: "North Carolina", city: "Raleigh", university: "North Carolina State University", presidentName: "Harper Clark", contactEmail: "ncsu@tpusa.local", phoneNumber: "919-555-1103", description: "Wolfpack for liberty", memberCount: 143, meetingLocation: "Talley Student Union", meetingSchedule: "Tuesdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1685577600)),
        
        // Virginia (3 chapters)
        Chapter(name: "UVA TPUSA", state: "Virginia", city: "Charlottesville", university: "University of Virginia", presidentName: "Evelyn Walker", contactEmail: "uva@tpusa.local", phoneNumber: "434-555-1201", description: "Cavaliers for freedom", memberCount: 136, meetingLocation: "Newcomb Hall", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1688169600)),
        
        Chapter(name: "VT TPUSA", state: "Virginia", city: "Blacksburg", university: "Virginia Tech", presidentName: "Logan Martinez", contactEmail: "vt@tpusa.local", phoneNumber: "540-555-1202", description: "Hokies for America", memberCount: 152, meetingLocation: "Squires Student Center", meetingSchedule: "Thursdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1690761600)),
        
        Chapter(name: "VCU TPUSA", state: "Virginia", city: "Richmond", university: "Virginia Commonwealth University", presidentName: "Scarlett Rodriguez", contactEmail: "vcu@tpusa.local", phoneNumber: "804-555-1203", description: "Rams for conservative values", memberCount: 108, meetingLocation: "Commons", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1693440000)),
        
        // Washington (2 chapters)
        Chapter(name: "UW TPUSA", state: "Washington", city: "Seattle", university: "University of Washington", presidentName: "Carter Brown", contactEmail: "uw@tpusa.local", phoneNumber: "206-555-1301", description: "Huskies for liberty", memberCount: 141, meetingLocation: "HUB", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1696032000)),
        
        Chapter(name: "WSU TPUSA", state: "Washington", city: "Pullman", university: "Washington State University", presidentName: "Luna Davis", contactEmail: "wsu@tpusa.local", phoneNumber: "509-555-1302", description: "Cougars for freedom", memberCount: 98, meetingLocation: "CUB", meetingSchedule: "Thursdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1698710400)),
        
        // Colorado (2 chapters)
        Chapter(name: "CU Boulder TPUSA", state: "Colorado", city: "Boulder", university: "University of Colorado Boulder", presidentName: "Henry Wilson", contactEmail: "cuboulder@tpusa.local", phoneNumber: "303-555-1401", description: "Buffaloes for conservative values", memberCount: 125, meetingLocation: "UMC", meetingSchedule: "Wednesdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1701388800), stateCoordinatorName: "Vega Stamatien", stateCoordinatorEmail: "vega.stamatien@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/vega-stamatien-74456a346/"),
        
        Chapter(name: "CSU TPUSA", state: "Colorado", city: "Fort Collins", university: "Colorado State University", presidentName: "Penelope Garcia", contactEmail: "csu@tpusa.local", phoneNumber: "970-555-1402", description: "Rams for America", memberCount: 103, meetingLocation: "Lory Student Center", meetingSchedule: "Thursdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1703980800), stateCoordinatorName: "Vega Stamatien", stateCoordinatorEmail: "vega.stamatien@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/vega-stamatien-74456a346/"),
        
        // Wisconsin (2 chapters)
        Chapter(name: "UW Madison TPUSA", state: "Wisconsin", city: "Madison", university: "University of Wisconsin-Madison", presidentName: "Jackson Taylor", contactEmail: "uwmadison@tpusa.local", phoneNumber: "608-555-1501", description: "Badgers for freedom", memberCount: 168, meetingLocation: "Memorial Union", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1706659200)),
        
        Chapter(name: "Marquette TPUSA", state: "Wisconsin", city: "Milwaukee", university: "Marquette University", presidentName: "Grace Anderson", contactEmail: "marquette@tpusa.local", phoneNumber: "414-555-1502", description: "Golden Eagles for liberty", memberCount: 86, meetingLocation: "Alumni Memorial Union", meetingSchedule: "Thursdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1709251200)),
        
        // Massachusetts (2 chapters)
        Chapter(name: "MIT TPUSA", state: "Massachusetts", city: "Cambridge", university: "Massachusetts Institute of Technology", presidentName: "Sebastian White", contactEmail: "mit@tpusa.local", phoneNumber: "617-555-1601", description: "Engineers for freedom", memberCount: 73, meetingLocation: "Student Center", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1711929600)),
        
        Chapter(name: "Boston University TPUSA", state: "Massachusetts", city: "Boston", university: "Boston University", presidentName: "Lily Martin", contactEmail: "bu@tpusa.local", phoneNumber: "617-555-1602", description: "Terriers for conservative values", memberCount: 114, meetingLocation: "GSU", meetingSchedule: "Wednesdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1714521600)),
        
        // Additional states to reach 50+ chapters
        // Tennessee (2 chapters)
        Chapter(name: "UT Knoxville TPUSA", state: "Tennessee", city: "Knoxville", university: "University of Tennessee", presidentName: "Wyatt Lee", contactEmail: "utk@tpusa.local", phoneNumber: "865-555-1701", description: "Volunteers for freedom", memberCount: 149, meetingLocation: "University Center", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1717200000)),
        
        Chapter(name: "Vanderbilt TPUSA", state: "Tennessee", city: "Nashville", university: "Vanderbilt University", presidentName: "Stella Harris", contactEmail: "vandy@tpusa.local", phoneNumber: "615-555-1702", description: "Commodores for America", memberCount: 92, meetingLocation: "Student Life Center", meetingSchedule: "Thursdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1719792000)),
        
        // Indiana (2 chapters)
        Chapter(name: "IU TPUSA", state: "Indiana", city: "Bloomington", university: "Indiana University", presidentName: "Jaxon Clark", contactEmail: "iu@tpusa.local", phoneNumber: "812-555-1801", description: "Hoosiers for liberty", memberCount: 132, meetingLocation: "IMU", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1722470400)),
        
        Chapter(name: "Purdue TPUSA", state: "Indiana", city: "West Lafayette", university: "Purdue University", presidentName: "Nora Walker", contactEmail: "purdue@tpusa.local", phoneNumber: "765-555-1802", description: "Boilermakers for freedom", memberCount: 145, meetingLocation: "PMU", meetingSchedule: "Thursdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1725148800)),
        
        // Missouri (2 chapters)
        Chapter(name: "Mizzou TPUSA", state: "Missouri", city: "Columbia", university: "University of Missouri", presidentName: "Leo Martinez", contactEmail: "mizzou@tpusa.local", phoneNumber: "573-555-1901", description: "Tigers for conservative values", memberCount: 121, meetingLocation: "MU Student Center", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1727740800)),
        
        // Idaho (3 chapters)
        Chapter(name: "Boise State TPUSA", state: "Idaho", city: "Boise", university: "Boise State University", presidentName: "Cade Syvock", contactEmail: "cade.syvock@tpusa.com", phoneNumber: "208-555-2001", description: "Broncos for freedom and conservative values", memberCount: 156, meetingLocation: "Student Union Building", meetingSchedule: "Thursdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1730419200)),
        
        Chapter(name: "University of Idaho TPUSA", state: "Idaho", city: "Moscow", university: "University of Idaho", presidentName: "Sarah Mitchell", contactEmail: "uidaho@tpusa.local", phoneNumber: "208-555-2002", description: "Vandals standing for liberty", memberCount: 98, meetingLocation: "Bruce Pitman Center", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1733011200)),
        
        Chapter(name: "Idaho State TPUSA", state: "Idaho", city: "Pocatello", university: "Idaho State University", presidentName: "Connor Davis", contactEmail: "isu@tpusa.local", phoneNumber: "208-555-2003", description: "Bengals for America", memberCount: 87, meetingLocation: "Pond Student Union", meetingSchedule: "Tuesdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1735689600)),
        
        // Alabama (4 chapters)
        Chapter(name: "University of Alabama TPUSA", state: "Alabama", city: "Tuscaloosa", university: "University of Alabama", presidentName: "TBD", contactEmail: "alabama@tpusa.com", phoneNumber: "205-555-3001", description: "Roll Tide for conservative values", memberCount: 185, meetingLocation: "Ferguson Center", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1738368000), stateCoordinatorName: "Katerina Zardoust", stateCoordinatorEmail: "katerina.zardoust@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/katerina-zardoust-283208210/"),
        
        Chapter(name: "Auburn TPUSA", state: "Alabama", city: "Auburn", university: "Auburn University", presidentName: "TBD", contactEmail: "auburn@tpusa.com", phoneNumber: "334-555-3002", description: "War Eagle for freedom", memberCount: 167, meetingLocation: "Student Center", meetingSchedule: "Thursdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1740960000), stateCoordinatorName: "Katerina Zardoust", stateCoordinatorEmail: "katerina.zardoust@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/katerina-zardoust-283208210/"),
        
        Chapter(name: "UAB TPUSA", state: "Alabama", city: "Birmingham", university: "University of Alabama at Birmingham", presidentName: "TBD", contactEmail: "uab@tpusa.com", phoneNumber: "205-555-3003", description: "Blazers for America", memberCount: 124, meetingLocation: "Hill University Center", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1743638400), stateCoordinatorName: "Katerina Zardoust", stateCoordinatorEmail: "katerina.zardoust@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/katerina-zardoust-283208210/"),
        
        Chapter(name: "Alabama State TPUSA", state: "Alabama", city: "Montgomery", university: "Alabama State University", presidentName: "TBD", contactEmail: "alabamastate@tpusa.com", phoneNumber: "334-555-3004", description: "Hornets for liberty", memberCount: 89, meetingLocation: "Student Union", meetingSchedule: "Mondays 6PM", dateEstablished: Date(timeIntervalSince1970: 1746316800), stateCoordinatorName: "Katerina Zardoust", stateCoordinatorEmail: "katerina.zardoust@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/katerina-zardoust-283208210/"),
        
        // Alaska (3 chapters)
        Chapter(name: "UAF TPUSA", state: "Alaska", city: "Fairbanks", university: "University of Alaska Fairbanks", presidentName: "TBD", contactEmail: "uaf@tpusa.com", phoneNumber: "907-555-3101", description: "Nanooks for freedom", memberCount: 67, meetingLocation: "Wood Center", meetingSchedule: "Thursdays 6PM", dateEstablished: Date(timeIntervalSince1970: 1748995200), stateCoordinatorName: "Tessa Toman", stateCoordinatorEmail: "tessa.toman@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/tessa-toman-739507385/"),
        
        Chapter(name: "UAA TPUSA", state: "Alaska", city: "Anchorage", university: "University of Alaska Anchorage", presidentName: "TBD", contactEmail: "uaa@tpusa.com", phoneNumber: "907-555-3102", description: "Seawolves for America", memberCount: 94, meetingLocation: "Student Union", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1751587200), stateCoordinatorName: "Tessa Toman", stateCoordinatorEmail: "tessa.toman@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/tessa-toman-739507385/"),
        
        Chapter(name: "UAS TPUSA", state: "Alaska", city: "Juneau", university: "University of Alaska Southeast", presidentName: "TBD", contactEmail: "uas@tpusa.com", phoneNumber: "907-555-3103", description: "Humpbacks for conservative values", memberCount: 45, meetingLocation: "Egan Library", meetingSchedule: "Tuesdays 5:30PM", dateEstablished: Date(timeIntervalSince1970: 1754265600), stateCoordinatorName: "Tessa Toman", stateCoordinatorEmail: "tessa.toman@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/tessa-toman-739507385/"),
        
        // Arkansas (4 chapters)
        Chapter(name: "University of Arkansas TPUSA", state: "Arkansas", city: "Fayetteville", university: "University of Arkansas", presidentName: "TBD", contactEmail: "uark@tpusa.com", phoneNumber: "479-555-3201", description: "Razorbacks for freedom", memberCount: 156, meetingLocation: "Arkansas Union", meetingSchedule: "Wednesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1756857600), stateCoordinatorName: "Dino F", stateCoordinatorEmail: "dino.f@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/dino-f-abb155265/"),
        
        Chapter(name: "Arkansas State TPUSA", state: "Arkansas", city: "Jonesboro", university: "Arkansas State University", presidentName: "TBD", contactEmail: "astate@tpusa.com", phoneNumber: "870-555-3202", description: "Red Wolves for America", memberCount: 112, meetingLocation: "Student Union", meetingSchedule: "Thursdays 6:30PM", dateEstablished: Date(timeIntervalSince1970: 1759536000), stateCoordinatorName: "Dino F", stateCoordinatorEmail: "dino.f@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/dino-f-abb155265/"),
        
        Chapter(name: "UCA TPUSA", state: "Arkansas", city: "Conway", university: "University of Central Arkansas", presidentName: "TBD", contactEmail: "uca@tpusa.com", phoneNumber: "501-555-3203", description: "Bears for conservative values", memberCount: 93, meetingLocation: "Student Center", meetingSchedule: "Tuesdays 7PM", dateEstablished: Date(timeIntervalSince1970: 1762128000), stateCoordinatorName: "Dino F", stateCoordinatorEmail: "dino.f@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/dino-f-abb155265/"),
        
        Chapter(name: "UALR TPUSA", state: "Arkansas", city: "Little Rock", university: "University of Arkansas at Little Rock", presidentName: "TBD", contactEmail: "ualr@tpusa.com", phoneNumber: "501-555-3204", description: "Trojans for liberty", memberCount: 78, meetingLocation: "Student Services Center", meetingSchedule: "Mondays 6PM", dateEstablished: Date(timeIntervalSince1970: 1764806400), stateCoordinatorName: "Dino F", stateCoordinatorEmail: "dino.f@tpusa.com", stateCoordinatorLinkedIn: "https://www.linkedin.com/in/dino-f-abb155265/")
    ]
}
