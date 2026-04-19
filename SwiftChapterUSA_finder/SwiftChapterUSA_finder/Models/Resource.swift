//
//  Resource.swift
//  SwiftChapterUSA Finder
//
//  Created on December 9, 2025.
//

import Foundation

struct Resource: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var category: ResourceCategory
    var type: ResourceType
    var content: String // For text content or URL for external links
    var imageURL: String?
    var author: String?
    var dateAdded: Date = Date()
    var tags: [String] = []
    var downloadCount: Int = 0
    var isFeatured: Bool = false
    
    enum ResourceCategory: String, Codable, CaseIterable {
        case talkingPoints = "Talking Points"
        case research = "Research & Statistics"
        case eventPlanning = "Event Planning"
        case recruitment = "Recruitment Materials"
        case socialMedia = "Social Media Graphics"
        case videos = "Videos & Speeches"
        case activism = "Activism Guides"
        case debate = "Debate Prep"
        case constitutionalLaw = "Constitutional Law"
        case economics = "Economics & Policy"
        
        var icon: String {
            switch self {
            case .talkingPoints: return "text.bubble.fill"
            case .research: return "chart.bar.fill"
            case .eventPlanning: return "calendar.badge.plus"
            case .recruitment: return "person.2.fill"
            case .socialMedia: return "photo.fill"
            case .videos: return "play.circle.fill"
            case .activism: return "megaphone.fill"
            case .debate: return "quote.bubble.fill"
            case .constitutionalLaw: return "scroll.fill"
            case .economics: return "dollarsign.circle.fill"
            }
        }
    }
    
    enum ResourceType: String, Codable {
        case article = "Article"
        case pdf = "PDF"
        case video = "Video"
        case image = "Image"
        case link = "External Link"
        case guide = "Guide"
    }
}

// Extension for sample data
extension Resource {
    static var samples: [Resource] {
        [
            Resource(
                title: "Free Speech on Campus",
                description: "Comprehensive guide to understanding and defending First Amendment rights on college campuses. Includes legal precedents and practical strategies.",
                category: .talkingPoints,
                type: .guide,
                content: """
                # Free Speech on Campus
                
                ## Understanding Your Rights
                
                The First Amendment protects your right to free speech on public college campuses. Here's what you need to know:
                
                ### Key Points:
                
                1. **Public Forums**: Outdoor areas of campus are generally considered public forums where speech is protected.
                
                2. **Content-Neutral Policies**: Universities can enforce reasonable time, place, and manner restrictions, but they must be content-neutral.
                
                3. **Heckler's Veto**: The potential for audience disruption cannot be used to censor protected speech.
                
                4. **Free Speech Zones**: Many courts have found these unconstitutional when they severely restrict speech.
                
                ## What To Do If Your Rights Are Violated:
                
                1. Document everything (photos, videos, witnesses)
                2. File a formal complaint with university administration
                3. Contact FIRE (Foundation for Individual Rights and Expression)
                4. Consider legal action if necessary
                
                ## Important Case Law:
                
                - Tinker v. Des Moines (1969)
                - Healy v. James (1972)
                - Rosenberger v. University of Virginia (1995)
                
                ## Resources:
                
                - FIRE Campus Rights Guide
                - ACLU Know Your Rights: Free Speech
                - Supreme Court First Amendment cases
                """,
                tags: ["first amendment", "free speech", "campus rights", "legal"],
                isFeatured: true
            ),
            
            Resource(
                title: "Economic Freedom Statistics",
                description: "Data and statistics comparing economic freedom, prosperity, and quality of life across different economic systems.",
                category: .research,
                type: .article,
                content: """
                # Economic Freedom & Prosperity
                
                ## Key Statistics:
                
                ### Economic Freedom Index (2024):
                
                - Countries with greater economic freedom have:
                  - 2.7x higher per capita income
                  - 5x higher income for poorest 10%
                  - Longer life expectancy (79.4 vs 65.2 years)
                  - Lower poverty rates (1.8% vs 24.6%)
                
                ### Regulatory Burden:
                
                - Federal regulations cost American economy $1.9 trillion annually
                - Small businesses spend $12,000 per employee on compliance
                - Each new regulation reduces job growth by 0.5%
                
                ### Tax Policy Impact:
                
                - States with no income tax grew 58% faster than high-tax states
                - Tax cuts in 2017 led to 4.1% GDP growth (highest in decade)
                - Corporate investment increased by 20% after tax reform
                
                ### Historical Data:
                
                - Free market reforms in China lifted 800M out of poverty
                - East vs West Germany: 3x income disparity by 1989
                - Venezuela GDP declined 75% after socialist policies
                
                ## Sources:
                
                - Heritage Foundation Economic Freedom Index
                - Bureau of Labor Statistics
                - Congressional Budget Office
                - World Bank Development Indicators
                """,
                tags: ["economics", "statistics", "capitalism", "freedom"],
                isFeatured: true
            ),
            
            Resource(
                title: "Event Planning Checklist",
                description: "Complete step-by-step guide for planning successful campus events, from small meetings to large rallies.",
                category: .eventPlanning,
                type: .guide,
                content: """
                # Campus Event Planning Guide
                
                ## 6-8 Weeks Before:
                
                - [ ] Reserve venue/room
                - [ ] Check university event policies
                - [ ] Submit event registration forms
                - [ ] Confirm speaker availability
                - [ ] Create event budget
                - [ ] Assign planning committee roles
                
                ## 4 Weeks Before:
                
                - [ ] Design promotional materials
                - [ ] Order any necessary supplies
                - [ ] Arrange A/V equipment
                - [ ] Plan refreshments (if applicable)
                - [ ] Create Facebook event page
                - [ ] Begin promoting on social media
                
                ## 2 Weeks Before:
                
                - [ ] Distribute flyers on campus
                - [ ] Send email announcements
                - [ ] Confirm speaker travel/accommodation
                - [ ] Brief security if needed
                - [ ] Prepare contingency plans
                - [ ] Create event day schedule
                
                ## 1 Week Before:
                
                - [ ] Final speaker confirmation
                - [ ] Send reminders to RSVPs
                - [ ] Test all equipment
                - [ ] Print materials (programs, handouts)
                - [ ] Recruit volunteers for day-of help
                
                ## Day Of Event:
                
                - [ ] Arrive early (2 hours minimum)
                - [ ] Set up room/equipment
                - [ ] Test microphones/projector
                - [ ] Set up registration table
                - [ ] Brief volunteers on roles
                - [ ] Welcome attendees
                - [ ] Take photos/videos
                - [ ] Collect contact info for follow-up
                
                ## After Event:
                
                - [ ] Send thank you emails to speakers
                - [ ] Post photos on social media
                - [ ] Send follow-up to attendees
                - [ ] Complete expense reports
                - [ ] Document lessons learned
                - [ ] Plan next event!
                
                ## Budget Template:
                
                - Venue: $
                - A/V Equipment: $
                - Refreshments: $
                - Marketing Materials: $
                - Speaker Fees/Travel: $
                - Contingency (10%): $
                
                Total: $
                """,
                tags: ["events", "planning", "organizing", "campus"],
                isFeatured: true
            ),
            
            Resource(
                title: "Recruitment Script & Tips",
                description: "Proven strategies and conversation starters for recruiting new chapter members. Includes handling objections and follow-up techniques.",
                category: .recruitment,
                type: .guide,
                content: """
                # Chapter Recruitment Guide
                
                ## The Opening (Tabling/Approaching):
                
                "Hi! Are you interested in getting involved on campus? We're [Chapter Name], a group of students who discuss policy, host speakers, and engage in activism. We'd love to tell you more!"
                
                ## The Pitch (30 seconds):
                
                "We meet [frequency] to discuss current events and policy from a conservative/libertarian perspective. We host guest speakers, organize debates, and participate in activism. It's a great way to:
                - Meet like-minded students
                - Develop leadership skills
                - Make an impact on campus
                - Build your resume
                
                Would you like to come to our next meeting?"
                
                ## Handling Common Objections:
                
                ### "I'm not political"
                "That's okay! Many of our members weren't either. We discuss policy issues that affect everyone - free speech, tuition costs, job opportunities. It's less about politics and more about ideas."
                
                ### "I don't have time"
                "We totally understand! We only meet [frequency] for [duration]. Many members just come when they can. Even attending a few events per semester is valuable."
                
                ### "I'm not sure I agree with everything"
                "Perfect! We encourage diverse viewpoints and healthy debate. You don't have to agree with everything - we value intellectual diversity."
                
                ### "I'm afraid of being judged/attacked"
                "That's a valid concern. Our chapter is a safe space for open discussion. We support each other and stand up for free expression on campus."
                
                ## Follow-Up Strategy:
                
                1. **Immediate**: Get phone number or email
                2. **24 hours**: Text/email with next meeting details
                3. **Day before meeting**: Reminder text
                4. **After first meeting**: Personal thank you + invite to social event
                5. **Week after**: Check in, answer questions
                
                ## Tips for Success:
                
                - Be enthusiastic and genuine
                - Share personal story of why you joined
                - Offer to attend first meeting together
                - Mention specific upcoming events
                - Don't pressure - plant seeds
                - Focus on community/friendship aspect
                - Highlight leadership opportunities
                
                ## Table Setup Ideas:
                
                - Free Constitution pocket guides
                - Candy with political puns
                - Sign-up sheet with raffle prizes
                - Photos from past events
                - QR code for easy sign-up
                - Chapter social media handles displayed
                
                ## Best Recruitment Opportunities:
                
                - Club fairs
                - First week of semester
                - After classes in high-traffic areas
                - During controversial campus events
                - Partner with other conservative groups
                - Host pizza socials
                """,
                tags: ["recruitment", "tabling", "membership", "growth"],
                isFeatured: false
            ),
            
            Resource(
                title: "Social Media Templates",
                description: "Ready-to-use graphics and post templates for Instagram, Facebook, Twitter, and TikTok. Customizable for your chapter.",
                category: .socialMedia,
                type: .guide,
                content: """
                # Social Media Strategy Guide
                
                ## Posting Frequency:
                
                - Instagram: 3-5 times per week
                - Facebook: Daily
                - Twitter: 3-5 times per day
                - TikTok: 2-3 times per week
                
                ## Content Mix (Weekly):
                
                - 40% Educational content
                - 30% Event promotion
                - 20% Engagement/questions
                - 10% Personal stories/behind scenes
                
                ## Post Templates:
                
                ### Quote Graphics:
                "[Powerful quote]"
                - [Attribution]
                
                #TPUSA #[YourChapter] #Freedom #[Topic]
                
                ### Event Announcements:
                🎤 UPCOMING EVENT 🎤
                
                [Speaker Name] is coming to [Campus]!
                📅 [Date & Time]
                📍 [Location]
                🎟️ Free admission
                
                Don't miss it! Link in bio to RSVP.
                
                ### Discussion Starters:
                "Question: [Thought-provoking question]
                
                Comment your thoughts below! 👇
                
                ### Activism Updates:
                ✅ SUCCESS!
                
                Our chapter [accomplished action]:
                - [Result 1]
                - [Result 2]
                - [Result 3]
                
                This is what happens when we take action! 💪
                
                ### Behind the Scenes:
                "A day in the life of a TPUSA chapter member..."
                
                [Carousel of candid photos from meetings/events]
                
                ## Hashtag Strategy:
                
                Primary: #TPUSA #TurningPointUSA #BigGovSucks
                Local: #[YourUniversity] #[YourCity]
                Topic: #FreeSpeech #Capitalism #Constitution
                Trending: [Use relevant trending tags]
                
                ## Best Posting Times:
                
                - Instagram: 11am-1pm, 7pm-9pm
                - Facebook: 1pm-3pm
                - Twitter: 8am-10am, 6pm-9pm
                - TikTok: 7am-9am, 4pm-6pm
                
                ## Story Ideas:
                
                - Poll: "Do you support [policy]?"
                - Quiz: "Test your knowledge!"
                - Countdown to event
                - Member spotlights
                - Meeting recaps
                - Q&A sessions
                - Day-in-the-life takeovers
                
                ## Engagement Tactics:
                
                - Respond to all comments within 1 hour
                - Ask questions in captions
                - Use interactive stickers in Stories
                - Repost user-generated content
                - Host Instagram Lives
                - Create shareable meme content
                - Run contests/giveaways
                
                ## Crisis Communication:
                
                If facing negative attention:
                1. Don't delete comments (looks defensive)
                2. Respond calmly with facts
                3. Document harassment
                4. Report abusive content
                5. Focus on positive messaging
                6. Rally your supporters
                """,
                tags: ["social media", "marketing", "instagram", "engagement"]
            ),
            
            Resource(
                title: "Constitutional Amendments Quick Reference",
                description: "Easy-to-understand breakdown of all 27 Constitutional amendments with historical context and modern applications.",
                category: .constitutionalLaw,
                type: .article,
                content: """
                # Constitutional Amendments Guide
                
                ## Bill of Rights (1-10):
                
                ### 1st Amendment - Religion, Speech, Press, Assembly, Petition
                - No government establishment of religion
                - Free exercise of religion
                - Freedom of speech and press
                - Right to peacefully assemble
                - Right to petition government
                
                **Modern Issues**: Campus speech codes, social media censorship, religious liberty cases
                
                ### 2nd Amendment - Right to Bear Arms
                - Right to keep and bear arms shall not be infringed
                - Well regulated militia clause
                
                **Modern Issues**: Gun control laws, concealed carry, assault weapon bans
                
                ### 3rd Amendment - Quartering of Soldiers
                - No forced quartering of soldiers in private homes
                
                **Modern Issues**: Rarely invoked; property rights
                
                ### 4th Amendment - Search and Seizure
                - Protection against unreasonable searches
                - Warrant requirement with probable cause
                
                **Modern Issues**: Digital privacy, phone searches, surveillance, police powers
                
                ### 5th Amendment - Due Process, Self-Incrimination
                - Grand jury requirement for serious crimes
                - No double jeopardy
                - Right against self-incrimination
                - Due process clause
                - Eminent domain with just compensation
                
                **Modern Issues**: Miranda rights, property takings, criminal justice reform
                
                ### 6th Amendment - Criminal Trial Rights
                - Speedy and public trial
                - Impartial jury
                - Right to know charges
                - Right to confront witnesses
                - Right to counsel
                
                **Modern Issues**: Public defenders, plea bargains, trial delays
                
                ### 7th Amendment - Civil Trial by Jury
                - Jury trial in civil cases over $20
                
                **Modern Issues**: Class action lawsuits, arbitration clauses
                
                ### 8th Amendment - Cruel and Unusual Punishment
                - No excessive bail or fines
                - No cruel and unusual punishment
                
                **Modern Issues**: Death penalty, prison conditions, sentencing reform
                
                ### 9th Amendment - Rights Retained by People
                - Rights not enumerated are retained by people
                
                **Modern Issues**: Privacy rights, unenumerated rights debate
                
                ### 10th Amendment - Powers Reserved to States
                - Powers not delegated to federal government reserved to states/people
                
                **Modern Issues**: Federalism, state sovereignty, federal overreach
                
                ## Other Key Amendments:
                
                ### 13th (1865) - Abolished Slavery
                ### 14th (1868) - Equal Protection, Due Process
                ### 15th (1870) - Voting Rights (Race)
                ### 19th (1920) - Women's Suffrage
                ### 26th (1971) - Voting Age to 18
                
                ## Quick Tips for Debates:
                
                - Know the text, not just summaries
                - Understand original intent vs living document debate
                - Reference Supreme Court cases
                - Distinguish between constitutional and policy arguments
                """,
                tags: ["constitution", "law", "amendments", "rights", "reference"]
            )
        ]
    }
}
