import Foundation

enum LifePathCategory: String, Codable, CaseIterable {
    case career = "career"
    case money = "money"
    case relationships = "relationships"
    case living = "living"
    case direction = "direction"
    case more = "more"
    case politics = "politics"
    case unknown = "unknown"
    
    var emoji: String {
        switch self {
        case .career: return "💼"
        case .money: return "💰"
        case .relationships: return "❤️"
        case .living: return "🏠"
        case .direction: return "🧠"
        case .more: return "🚀"
        case .politics: return "🗳️"
        case .unknown: return "❓"
        }
    }
    
    var title: String {
        switch self {
        case .career: return "My Career"
        case .money: return "My Money"
        case .relationships: return "My Relationships"
        case .living: return "My Living Situation"
        case .direction: return "My Direction"
        case .more: return "I Want Something More"
        case .politics: return "Choose My Political Party"
        case .unknown: return "I Don't Know Yet"
        }
    }
    
    var description: String {
        switch self {
        case .career: return "Build skills, find your calling, advance professionally"
        case .money: return "Improve finances, build wealth, financial independence"
        case .relationships: return "Strengthen connections, find community, build trust"
        case .living: return "Improve home, better environment, stability"
        case .direction: return "Clarify goals, find purpose, navigate life decisions"
        case .more: return "Transform yourself, exceed expectations, reach potential"
        case .politics: return "Align with your political values, find where you fit"
        case .unknown: return "Explore your options, find what matters"
        }
    }
}

struct DailyMilestone: Codable {
    let day: Int
    let title: String
    let description: String
    let action: String
    var completed: Bool = false
}

struct LifePath: Codable {
    let category: LifePathCategory
    let milestones: [DailyMilestone]
    var selectedDate: Date?
    var completedDays: Set<Int> = []
    
    var progressPercentage: Double {
        guard !milestones.isEmpty else { return 0 }
        let completed = milestones.filter { $0.completed }.count
        return Double(completed) / Double(milestones.count) * 100
    }
    
    var daysRemaining: Int {
        milestones.count - milestones.filter { $0.completed }.count
    }
}

// MARK: - 30-Day Path Content

struct PathContent {
    static let paths: [LifePathCategory: [DailyMilestone]] = [
        .career: careerPath,
        .money: moneyPath,
        .relationships: relationshipsPath,
        .living: livingPath,
        .direction: directionPath,
        .more: morePath,
        .unknown: unknownPath
    ]
    
    // Career Path
    static let careerPath: [DailyMilestone] = [
        DailyMilestone(day: 1, title: "Assess Your Current Role", description: "Evaluate what you currently do and what you enjoy", action: "Write down 3 things you love about your work and 3 you'd change"),
        DailyMilestone(day: 2, title: "Define Your Ideal Career", description: "Envision where you want to be", action: "Describe your ideal job in 5-10 sentences"),
        DailyMilestone(day: 3, title: "Identify Skills Gap", description: "Find what you need to learn", action: "List 5 skills you need to develop"),
        DailyMilestone(day: 4, title: "Research Opportunities", description: "Explore career paths that interest you", action: "Look up 3 companies or roles you'd like to pursue"),
        DailyMilestone(day: 5, title: "Network & Connect", description: "Reach out to professionals in your field", action: "Connect with 2 people on LinkedIn or schedule 1 coffee chat"),
        DailyMilestone(day: 6, title: "Skill Development Start", description: "Begin learning a key skill", action: "Enroll in or start an online course"),
        DailyMilestone(day: 7, title: "Week 1 Reflection", description: "Review your progress", action: "Reflect on this week's learnings"),
        DailyMilestone(day: 8, title: "Update Your Resume", description: "Highlight your achievements", action: "Add recent accomplishments to your resume"),
        DailyMilestone(day: 9, title: "Volunteer or Side Project", description: "Build experience outside your job", action: "Start a project that showcases your skills"),
        DailyMilestone(day: 10, title: "Speak Up at Work", description: "Share your ideas and opinions", action: "Contribute meaningfully in one meeting"),
        DailyMilestone(day: 11, title: "Find a Mentor", description: "Seek guidance from someone ahead", action: "Ask someone to grab coffee or mentor you"),
        DailyMilestone(day: 12, title: "Professional Development", description: "Invest in your growth", action: "Attend a webinar or workshop"),
        DailyMilestone(day: 13, title: "Mid-Month Check In", description: "Assess halfway progress", action: "Review your career goals and adjust if needed"),
        DailyMilestone(day: 14, title: "Build Your Personal Brand", description: "Establish your professional identity", action: "Update LinkedIn profile or create portfolio"),
        DailyMilestone(day: 15, title: "Interview Practice", description: "Prepare for opportunities", action: "Practice answering 5 common interview questions"),
        DailyMilestone(day: 16, title: "Expand Your Network", description: "Build professional relationships", action: "Join a professional group or association"),
        DailyMilestone(day: 17, title: "Learn Industry Trends", description: "Stay current in your field", action: "Read 2 industry articles or blogs"),
        DailyMilestone(day: 18, title: "Pitch Your Value", description: "Communicate what you bring", action: "Write your 30-second elevator pitch"),
        DailyMilestone(day: 19, title: "Negotiate & Advocate", description: "Ask for what you deserve", action: "Research salary ranges for your role"),
        DailyMilestone(day: 20, title: "Take on a Challenge", description: "Push yourself professionally", action: "Volunteer for a stretch assignment"),
        DailyMilestone(day: 21, title: "Week 3 Reflection", description: "Celebrate progress", action: "Write down wins and lessons learned"),
        DailyMilestone(day: 22, title: "Mentorship Reciprocal", description: "Help someone else grow", action: "Mentor or guide a junior colleague"),
        DailyMilestone(day: 23, title: "Document Your Work", description: "Build your portfolio", action: "Document a project or achievement"),
        DailyMilestone(day: 24, title: "Request Feedback", description: "Get insights from others", action: "Ask your manager or peer for constructive feedback"),
        DailyMilestone(day: 25, title: "Career Planning", description: "Map your next steps", action: "Create a 1-3 year career plan"),
        DailyMilestone(day: 26, title: "Financial Growth in Career", description: "Link career to income", action: "Explore paths to higher earning potential"),
        DailyMilestone(day: 27, title: "Set New Goals", description: "Define your next milestone", action: "Set 1 SMART goal for the next 90 days"),
        DailyMilestone(day: 28, title: "Consolidate Learning", description: "Solidify your progress", action: "Review all skills you've developed"),
        DailyMilestone(day: 29, title: "Plan Your Momentum", description: "Keep the energy going", action: "Schedule next steps and commitments"),
        DailyMilestone(day: 30, title: "Celebrate & Commit", description: "Honor your journey and recommit", action: "Celebrate your progress. Choose your next path or continue this one")
    ]
    
    // Money Path
    static let moneyPath: [DailyMilestone] = [
        DailyMilestone(day: 1, title: "Know Your Numbers", description: "Understand your financial situation", action: "Calculate your total income, expenses, and net worth"),
        DailyMilestone(day: 2, title: "Create a Budget", description: "Control where money goes", action: "Build a monthly budget spreadsheet"),
        DailyMilestone(day: 3, title: "Track Spending", description: "See real spending patterns", action: "Review last month's credit card and bank statements"),
        DailyMilestone(day: 4, title: "Emergency Fund Start", description: "Build financial security", action: "Open a separate savings account for emergencies"),
        DailyMilestone(day: 5, title: "Debt Assessment", description: "Face your debt situation", action: "List all debts with amounts and interest rates"),
        DailyMilestone(day: 6, title: "Debt Payoff Plan", description: "Create a strategy to eliminate debt", action: "Choose a debt payoff method (snowball or avalanche)"),
        DailyMilestone(day: 7, title: "Week 1 Review", description: "Check your progress", action: "Review your budgets and financial goals"),
        DailyMilestone(day: 8, title: "Cut Unnecessary Expenses", description: "Find money to save", action: "Identify and cancel 3 subscriptions you don't need"),
        DailyMilestone(day: 9, title: "Meal Plan & Save", description: "Food is often the biggest variable expense", action: "Plan meals for the week and cook at home"),
        DailyMilestone(day: 10, title: "Side Income Research", description: "Explore ways to earn more", action: "Research 3 side gigs you could do"),
        DailyMilestone(day: 11, title: "Negotiate Bills", description: "Lower fixed costs", action: "Call your insurance, internet, and phone providers"),
        DailyMilestone(day: 12, title: "Understand Interest", description: "Learn how interest works for/against you", action: "Calculate how compound interest affects your money"),
        DailyMilestone(day: 13, title: "Mid-Month Financial Check", description: "Halfway point assessment", action: "Review spending vs budget"),
        DailyMilestone(day: 14, title: "Start Investing Basics", description: "Grow wealth over time", action: "Learn about index funds and ETFs"),
        DailyMilestone(day: 15, title: "Retirement Planning", description: "Plan for the long term", action: "Understand 401k, IRA, and retirement accounts"),
        DailyMilestone(day: 16, title: "Insurance Assessment", description: "Protect your wealth", action: "Review health, auto, and renters insurance"),
        DailyMilestone(day: 17, title: "Financial Goals", description: "Define what money means to you", action: "Write 3 short-term and 3 long-term financial goals"),
        DailyMilestone(day: 18, title: "Credit Score Check", description: "Monitor your creditworthiness", action: "Check your credit score on a free site like Credit Karma"),
        DailyMilestone(day: 19, title: "Improve Credit Score", description: "Better credit = better rates", action: "Make a plan to address credit issues"),
        DailyMilestone(day: 20, title: "Tax Planning", description: "Keep more of what you earn", action: "Understand tax-advantaged accounts"),
        DailyMilestone(day: 21, title: "Week 3 Financial Review", description: "Progress checkpoint", action: "Celebrate financial wins this month"),
        DailyMilestone(day: 22, title: "Build Wealth Mindset", description: "Psychology of money", action: "Read about financial psychology or listen to a podcast"),
        DailyMilestone(day: 23, title: "Automate Savings", description: "Make savings effortless", action: "Set up automatic transfers to savings account"),
        DailyMilestone(day: 24, title: "Healthcare Costs", description: "Plan for medical expenses", action: "Understand FSA, HSA, and health savings"),
        DailyMilestone(day: 25, title: "Big Purchase Strategy", description: "Don't impulse spend", action: "Create a process before major purchases"),
        DailyMilestone(day: 26, title: "Giving & Generosity", description: "Money beyond yourself", action: "Plan how much you'll give to causes"),
        DailyMilestone(day: 27, title: "Financial Independence", description: "Envision financial freedom", action: "Calculate your FI number (what you need to retire)"),
        DailyMilestone(day: 28, title: "Review Financial Tools", description: "Use technology wisely", action: "Set up budget app or personal finance software"),
        DailyMilestone(day: 29, title: "Next Month Planning", description: "Plan continued progress", action: "Set financial priorities for next month"),
        DailyMilestone(day: 30, title: "Financial Commitment", description: "Lock in your financial future", action: "Commit to one financial habit for the next 30 days")
    ]
    
    // Relationships Path
    static let relationshipsPath: [DailyMilestone] = [
        DailyMilestone(day: 1, title: "Relationship Audit", description: "Assess your current relationships", action: "List important people in your life and how close you feel"),
        DailyMilestone(day: 2, title: "Identify Energy Drains", description: "Recognize toxic relationships", action: "Write which relationships drain vs energize you"),
        DailyMilestone(day: 3, title: "Reach Out to Someone", description: "Start reconnecting", action: "Text or call someone you haven't talked to recently"),
        DailyMilestone(day: 4, title: "Have a Real Conversation", description: "Go deeper than small talk", action: "Ask someone a meaningful question and listen"),
        DailyMilestone(day: 5, title: "Show Appreciation", description: "Let people know they matter", action: "Send a thank you message to someone"),
        DailyMilestone(day: 6, title: "Listen Without Fixing", description: "Practice empathy", action: "Listen to someone without trying to solve their problem"),
        DailyMilestone(day: 7, title: "Week 1 Reflection", description: "Check connection quality", action: "Notice if you feel more connected"),
        DailyMilestone(day: 8, title: "Resolve a Conflict", description: "Address past hurt", action: "Apologize to or have honest talk with someone"),
        DailyMilestone(day: 9, title: "Social Skills Check", description: "Evaluate how you interact", action: "Reflect on your communication patterns"),
        DailyMilestone(day: 10, title: "Join a Community", description: "Find your people", action: "Attend a meetup, club, or group activity"),
        DailyMilestone(day: 11, title: "Set Boundaries", description: "Protect your peace", action: "Identify where you need to set boundaries"),
        DailyMilestone(day: 12, title: "Quality Time", description: "Be fully present", action: "Spend phone-free time with someone you care about"),
        DailyMilestone(day: 13, title: "Mid-Point Relationship Check", description: "Assess progress", action: "Notice improvements in your relationships"),
        DailyMilestone(day: 14, title: "Vulnerability Practice", description: "Share more of yourself", action: "Share something real with someone you trust"),
        DailyMilestone(day: 15, title: "Gratitude Expression", description: "Acknowledge importance", action: "Tell 3 people why they matter to you"),
        DailyMilestone(day: 16, title: "Difficult Conversation", description: "Address an issue head-on", action: "Have one important conversation you've been avoiding"),
        DailyMilestone(day: 17, title: "Learn Communication Styles", description: "Understand how people work", action: "Read about or take a communication style quiz"),
        DailyMilestone(day: 18, title: "Give Genuine Compliment", description: "Lift others up", action: "Give 3 meaningful, specific compliments"),
        DailyMilestone(day: 19, title: "Ask for Help", description: "Build intimacy through needs", action: "Ask someone for help with something"),
        DailyMilestone(day: 20, title: "Be There for Someone", description: "Show up when it matters", action: "Support someone through their challenge"),
        DailyMilestone(day: 21, title: "Week 3 Connection Review", description: "Celebrate relationship growth", action: "Note how relationships have improved"),
        DailyMilestone(day: 22, title: "Family Time", description: "Strengthen family bonds", action: "Have meaningful time with family member"),
        DailyMilestone(day: 23, title: "Love Language Check", description: "Express care their way", action: "Learn and practice someone's love language"),
        DailyMilestone(day: 24, title: "Make New Friends", description: "Expand your circle", action: "Invite someone new to do something together"),
        DailyMilestone(day: 25, title: "Mentor Relationship", description: "Seek wisdom from others", action: "Connect with someone who inspires you"),
        DailyMilestone(day: 26, title: "Be a Good Friend", description: "Show up consistently", action: "Do something unexpectedly kind for a friend"),
        DailyMilestone(day: 27, title: "Celebrate Others", description: "Amplify their wins", action: "Celebrate a friend's or family's achievement"),
        DailyMilestone(day: 28, title: "Digital Detox Together", description: "Connect face-to-face", action: "Spend time with someone with no phones"),
        DailyMilestone(day: 29, title: "Plan Regular Check-ins", description: "Keep momentum going", action: "Schedule regular hangouts with important people"),
        DailyMilestone(day: 30, title: "Relationship Recommitment", description: "Solidify your connections", action: "Write how your relationships have changed this month")
    ]
    
    // Living Situation Path
    static let livingPath: [DailyMilestone] = [
        DailyMilestone(day: 1, title: "Assess Current Living", description: "Evaluate your space", action: "Write down what you like and dislike about where you live"),
        DailyMilestone(day: 2, title: "Dream Living Space", description: "Envision your ideal", action: "Describe your ideal living situation"),
        DailyMilestone(day: 3, title: "Declutter Start", description: "Begin simplifying", action: "Declutter one room or area"),
        DailyMilestone(day: 4, title: "Organization System", description: "Create systems for order", action: "Organize one closet, drawer, or shelf"),
        DailyMilestone(day: 5, title: "Deep Clean", description: "Fresh start with cleanliness", action: "Deep clean one room"),
        DailyMilestone(day: 6, title: "Budget Assessment", description: "Can you afford better?", action: "Review your housing budget"),
        DailyMilestone(day: 7, title: "Week 1 Living Review", description: "Notice improvements", action: "Reflect on how your space feels now"),
        DailyMilestone(day: 8, title: "Utility Optimization", description: "Make living efficient", action: "Review electric, water, heating costs"),
        DailyMilestone(day: 9, title: "Roommate Dynamics", description: "If applicable, improve living together", action: "Have honest conversation with roommate about shared space"),
        DailyMilestone(day: 10, title: "Storage Solutions", description: "Maximize your space", action: "Research or purchase storage solutions"),
        DailyMilestone(day: 11, title: "Aesthetic Upgrade", description: "Make it beautiful", action: "Add plants, art, or decor to brighten space"),
        DailyMilestone(day: 12, title: "Safety Audit", description: "Ensure security", action: "Check locks, lighting, and safety features"),
        DailyMilestone(day: 13, title: "Mid-Month Living Check", description: "Halfway progress", action: "Take before/after photos of your space"),
        DailyMilestone(day: 14, title: "Find Community", description: "Connect with neighbors", action: "Introduce yourself to a neighbor"),
        DailyMilestone(day: 15, title: "Furniture Arrangement", description: "Optimize flow", action: "Rearrange furniture to improve functionality"),
        DailyMilestone(day: 16, title: "Financial Planning for Move", description: "Plan your next step", action: "Research moving costs if you want to relocate"),
        DailyMilestone(day: 17, title: "Home Maintenance", description: "Care for your space", action: "Complete one deferred maintenance task"),
        DailyMilestone(day: 18, title: "Create Comfort Zones", description: "Design spaces for relaxation", action: "Set up a comfortable reading or relaxation nook"),
        DailyMilestone(day: 19, title: "Kitchen Upgrade", description: "Make cooking enjoyable", action: "Organize or upgrade your kitchen"),
        DailyMilestone(day: 20, title: "Outdoor Space", description: "Improve outside if possible", action: "Enhance balcony, patio, or outdoor area"),
        DailyMilestone(day: 21, title: "Week 3 Living Reflection", description: "Celebrate changes", action: "How does your home feel different now?"),
        DailyMilestone(day: 22, title: "Bedroom Sanctuary", description: "Better sleep environment", action: "Improve comfort and ambiance of bedroom"),
        DailyMilestone(day: 23, title: "Smart Home Basics", description: "Leverage technology", action: "Research or install one smart home feature"),
        DailyMilestone(day: 24, title: "Create Routines", description: "Make daily life easier", action: "Establish routines that improve living experience"),
        DailyMilestone(day: 25, title: "Green Living", description: "Eco-friendly improvements", action: "Add plants or implement one green practice"),
        DailyMilestone(day: 26, title: "Hosting Capability", description: "Make space welcoming", action: "Prepare your space to have guests over"),
        DailyMilestone(day: 27, title: "Long-term Housing Goals", description: "Plan your future", action: "Write housing goals (own home, upgrade, relocate, etc.)"),
        DailyMilestone(day: 28, title: "Insurance & Docs", description: "Protect your living space", action: "Review renter's or homeowner's insurance"),
        DailyMilestone(day: 29, title: "Guest Appreciation", description: "Enjoy your improved space", action: "Have friends over to enjoy your space"),
        DailyMilestone(day: 30, title: "Living Commitment", description: "Keep momentum going", action: "Commit to maintaining and improving your space")
    ]
    
    // Direction Path
    static let directionPath: [DailyMilestone] = [
        DailyMilestone(day: 1, title: "Values Clarification", description: "What matters most?", action: "List your top 5 core values"),
        DailyMilestone(day: 2, title: "Life Vision", description: "Dream without limits", action: "Write your ideal life in vivid detail"),
        DailyMilestone(day: 3, title: "Strengths Assessment", description: "What are you good at?", action: "List your top 10 strengths and talents"),
        DailyMilestone(day: 4, title: "Weakness Acceptance", description: "Know what to improve", action: "Honestly list areas for growth"),
        DailyMilestone(day: 5, title: "Life Roles Inventory", description: "How many hats do you wear?", action: "Identify all your life roles (student, friend, worker, etc)"),
        DailyMilestone(day: 6, title: "Life Satisfaction Check", description: "Rate your current state", action: "Rate satisfaction in each life area 1-10"),
        DailyMilestone(day: 7, title: "Week 1 Self-Awareness", description: "Reflection checkpoint", action: "Journal about what you've learned about yourself"),
        DailyMilestone(day: 8, title: "Purpose Exploration", description: "Why are you here?", action: "Write what gives your life meaning"),
        DailyMilestone(day: 9, title: "Passion Projects", description: "What excites you?", action: "List 5 things that make you lose track of time"),
        DailyMilestone(day: 10, title: "Bucket List Items", description: "What do you want to do?", action: "Write your top 20 bucket list items"),
        DailyMilestone(day: 11, title: "Fear Inventory", description: "What's holding you back?", action: "Write your top fears and challenges"),
        DailyMilestone(day: 12, title: "Overcome One Fear", description: "Take action despite fear", action: "Do one small thing that scares you"),
        DailyMilestone(day: 13, title: "Mid-Point Direction Check", description: "Clarity emerging?", action: "Write what's becoming clearer about your direction"),
        DailyMilestone(day: 14, title: "Mentor Conversation", description: "Seek guidance", action: "Ask someone you admire for life advice"),
        DailyMilestone(day: 15, title: "Skills & Interests", description: "Map your potential", action: "Write skills you have and want to develop"),
        DailyMilestone(day: 16, title: "Education Path", description: "What learning do you need?", action: "Research education or training options"),
        DailyMilestone(day: 17, title: "Inspiration Gathering", description: "Learn from others' paths", action: "Research 3 people whose lives inspire you"),
        DailyMilestone(day: 18, title: "Small Experiments", description: "Try before committing", action: "Do a small experiment in a direction you're considering"),
        DailyMilestone(day: 19, title: "Energy Audit", description: "What truly energizes you?", action: "Track what activities energize vs drain you"),
        DailyMilestone(day: 20, title: "Legacy Thinking", description: "What do you want to leave?", action: "Write what impact you want to have on the world"),
        DailyMilestone(day: 21, title: "Week 3 Direction Clarity", description: "Patterns emerging?", action: "Identify recurring themes in your reflections"),
        DailyMilestone(day: 22, title: "Decision Practice", description: "Make a medium decision", action: "Make one important decision you've been postponing"),
        DailyMilestone(day: 23, title: "Timeline Planning", description: "When will you act?", action: "Create a timeline for your major goals"),
        DailyMilestone(day: 24, title: "Accountability Partner", description: "Share your direction", action: "Tell someone your goals and ask them to hold you accountable"),
        DailyMilestone(day: 25, title: "Course Correction", description: "Adjust if needed", action: "Revise plans based on what you've learned"),
        DailyMilestone(day: 26, title: "Celebrate Progress", description: "Honor your growth", action: "Acknowledge how you've grown"),
        DailyMilestone(day: 27, title: "First Steps", description: "What's the next action?", action: "Identify 3 small first steps toward your direction"),
        DailyMilestone(day: 28, title: "Eliminate Roadblocks", description: "Clear the path", action: "Identify and plan to remove one major obstacle"),
        DailyMilestone(day: 29, title: "Vision Refinement", description: "Sharpen your picture", action: "Write a clear, specific vision for your future"),
        DailyMilestone(day: 30, title: "Direction Commitment", description: "Commit to your path", action: "Write a personal commitment to your life direction")
    ]
    
    // More (Something More) Path
    static let morePath: [DailyMilestone] = [
        DailyMilestone(day: 1, title: "Define 'Something More'", description: "What does transformation mean?", action: "Write what 'something more' means to you personally"),
        DailyMilestone(day: 2, title: "Current Reality Check", description: "Where are you now?", action: "Honestly assess your current situation"),
        DailyMilestone(day: 3, title: "Breakthrough Vision", description: "What's possible?", action: "Imagine yourself 5 years from now at your best"),
        DailyMilestone(day: 4, title: "Identify Your Ceiling", description: "What limits you?", action: "List beliefs and habits holding you back"),
        DailyMilestone(day: 5, title: "Break One Habit", description: "Small change, big impact", action: "Stop one bad habit for today"),
        DailyMilestone(day: 6, title: "Push Your Comfort Zone", description: "Grow through discomfort", action: "Do something that scares you"),
        DailyMilestone(day: 7, title: "Week 1 Breakthrough Check", description: "Notice shifts", action: "Reflect on what's changed this week"),
        DailyMilestone(day: 8, title: "Personal Audit", description: "Full life review", action: "Rate every area of life and identify #1 priority"),
        DailyMilestone(day: 9, title: "Eliminate Excuses", description: "Take full responsibility", action: "Write and eliminate 5 of your biggest excuses"),
        DailyMilestone(day: 10, title: "Peak Performance", description: "When are you at your best?", action: "Identify conditions for your peak performance"),
        DailyMilestone(day: 11, title: "Energy Management", description: "Protect your best self", action: "Create a system to manage your energy"),
        DailyMilestone(day: 12, title: "Failure Reframe", description: "Mistakes are data", action: "Reframe a past failure as a learning opportunity"),
        DailyMilestone(day: 13, title: "Mid-Journey Check", description: "Breakthrough progress?", action: "Celebrate wins and recognize growth"),
        DailyMilestone(day: 14, title: "Deep Focus Day", description: "Master concentration", action: "Spend 4 hours on your most important work"),
        DailyMilestone(day: 15, title: "Upgrade Your Identity", description: "Who do you want to become?", action: "Write a new identity statement for yourself"),
        DailyMilestone(day: 16, title: "Extreme Ownership", description: "Full accountability", action: "Take responsibility for one area of your life"),
        DailyMilestone(day: 17, title: "Level Up Skills", description: "Accelerated learning", action: "Spend time learning a critical skill"),
        DailyMilestone(day: 18, title: "Network Expansion", description: "Connect with higher levels", action: "Reach out to someone at the level you want"),
        DailyMilestone(day: 19, title: "Discipline Day", description: "Do hard things", action: "Accomplish something you've been avoiding"),
        DailyMilestone(day: 20, title: "Contribution Focus", description: "How do you add value?", action: "Do something that helps others succeed"),
        DailyMilestone(day: 21, title: "Week 3 Transformation", description: "You're changing", action: "Notice how different you feel"),
        DailyMilestone(day: 22, title: "Momentum Building", description: "Keep the fire burning", action: "Do 3 things that move you forward"),
        DailyMilestone(day: 23, title: "Inspiring Others", description: "Be a positive influence", action: "Inspire someone else to pursue their greatness"),
        DailyMilestone(day: 24, title: "Breakthrough Moment", description: "Go beyond limits", action: "Attempt something you thought impossible"),
        DailyMilestone(day: 25, title: "New Standards", description: "Raise your bar", action: "Set new, higher standards for yourself"),
        DailyMilestone(day: 26, title: "Gratitude Shift", description: "Abundance mindset", action: "Write 20 things you're grateful for"),
        DailyMilestone(day: 27, title: "Future Self Letter", description: "Vision crystallization", action: "Write a letter from your future self"),
        DailyMilestone(day: 28, title: "Commitment Deepening", description: "Strengthen your resolve", action: "Publicly commit to your transformation"),
        DailyMilestone(day: 29, title: "Integration", description: "Make it permanent", action: "Build systems to sustain your growth"),
        DailyMilestone(day: 30, title: "You Are Transformed", description: "Celebrate the new you", action: "Reflect on your 30-day transformation and recommit")
    ]
    
    // Unknown Path
    static let unknownPath: [DailyMilestone] = [
        DailyMilestone(day: 1, title: "Self-Exploration Start", description: "Begin discovering yourself", action: "Reflect on what you're curious about"),
        DailyMilestone(day: 2, title: "Try Something New", description: "Expand your experiences", action: "Try one activity you've never done before"),
        DailyMilestone(day: 3, title: "Ask Big Questions", description: "What really matters?", action: "Journal about life's big questions"),
        DailyMilestone(day: 4, title: "Personality Test", description: "Understand yourself", action: "Take a personality assessment (MBTI, Enneagram, etc)"),
        DailyMilestone(day: 5, title: "Talk to People", description: "Learn from others' paths", action: "Interview 3 people about their lives and choices"),
        DailyMilestone(day: 6, title: "Explore Interests", description: "What sparks curiosity?", action: "Research 3 careers or paths that intrigue you"),
        DailyMilestone(day: 7, title: "Week 1 Discovery", description: "What's emerging?", action: "Reflect on discoveries so far"),
        DailyMilestone(day: 8, title: "Try a New Hobby", description: "Explore skills", action: "Start a new hobby or skill you're interested in"),
        DailyMilestone(day: 9, title: "Read & Learn", description: "Expand your mind", action: "Read a book or article on an unfamiliar topic"),
        DailyMilestone(day: 10, title: "Skill Sampling", description: "Test different abilities", action: "Try one new skill you might enjoy long-term"),
        DailyMilestone(day: 11, title: "Community Exploration", description: "Find your people", action: "Attend a group or meetup in an area you're curious about"),
        DailyMilestone(day: 12, title: "Values Clarity", description: "What's important to you?", action: "Write your top 3 values"),
        DailyMilestone(day: 13, title: "Mid-Journey Clarity", description: "Patterns emerging?", action: "Notice common themes in your explorations"),
        DailyMilestone(day: 14, title: "Bucket List", description: "Dream big", action: "Write 30 things you want to try or experience"),
        DailyMilestone(day: 15, title: "Mentor Chat", description: "Seek guidance", action: "Talk to someone you admire about their journey"),
        DailyMilestone(day: 16, title: "Virtual Tour", description: "Explore possibilities", action: "Tour careers or schools online"),
        DailyMilestone(day: 17, title: "Skill Dive", description: "Go deeper in interest", action: "Spend a day learning more about one interest"),
        DailyMilestone(day: 18, title: "Travel or Adventure", description: "Expand perspectives", action: "Visit somewhere new or try a new experience"),
        DailyMilestone(day: 19, title: "Strength Finder", description: "What are you good at?", action: "List natural talents and strengths"),
        DailyMilestone(day: 20, title: "Dream Day", description: "Design your ideal day", action: "Write a description of your dream day"),
        DailyMilestone(day: 21, title: "Week 3 Reflection", description: "Direction becoming clear?", action: "Journal about what you've learned about yourself"),
        DailyMilestone(day: 22, title: "Networking", description: "Connect with possibilities", action: "Meet someone doing something you're curious about"),
        DailyMilestone(day: 23, title: "Cross Training", description: "Diverse exploration", action: "Try something in a completely different area"),
        DailyMilestone(day: 24, title: "Take a Chance", description: "Say yes to opportunity", action: "Say yes to something new that comes your way"),
        DailyMilestone(day: 25, title: "Feedback Seeking", description: "What do others see?", action: "Ask friends what they think your gifts are"),
        DailyMilestone(day: 26, title: "Life Satisfaction", description: "What fulfills you?", action: "Think about moments when you felt most alive"),
        DailyMilestone(day: 27, title: "Clarifying Choices", description: "Making it real", action: "Identify 1-3 directions worth exploring more"),
        DailyMilestone(day: 28, title: "Next Steps Planning", description: "How to continue?", action: "Create a plan to deepen exploration of top options"),
        DailyMilestone(day: 29, title: "Commitment to Growth", description: "Keep exploring", action: "Commit to continued discovery and growth"),
        DailyMilestone(day: 30, title: "Choose Your Next Path", description: "Pick a direction", action: "Choose one of the other 6 paths to explore next")
    ]
}

// MARK: - Political Party Guidance

struct PoliticalParty: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let emoji: String
    let color: String
    let tagline: String
    let coreValues: [String]
    let economicApproach: String
    let socialApproach: String
    let environmentalApproach: String
    let description: String
}

struct PoliticalPartyGuidance {
    static let parties: [PoliticalParty] = [
        PoliticalParty(
            name: "Democratic Party",
            emoji: "🔵",
            color: "blue",
            tagline: "Progress, Equality, Community",
            coreValues: ["Social equality", "Economic opportunity for all", "Environmental protection", "Government assistance for those in need", "Progressive taxation"],
            economicApproach: "Emphasizes regulation to protect workers and consumers. Supports progressive taxation, strong social safety net, and government programs. Advocates for raising minimum wage and worker protections.",
            socialApproach: "Supports civil rights, LGBTQ+ equality, reproductive rights, and diversity. Advocates for inclusive policies and equal access to opportunities.",
            environmentalApproach: "Strong environmental protection advocate. Supports climate change action, renewable energy investment, and environmental regulations.",
            description: "The Democratic Party generally advocates for a larger government role in social and economic issues, progressive taxation, environmental protection, and social justice initiatives."
        ),
        PoliticalParty(
            name: "Republican Party",
            emoji: "🔴",
            color: "red",
            tagline: "Liberty, Limited Government, Tradition",
            coreValues: ["Individual liberty", "Limited government", "Free market capitalism", "Traditional values", "Strong national defense"],
            economicApproach: "Emphasizes free market capitalism, lower taxes, less regulation, and individual responsibility. Supports business growth and entrepreneurship with minimal government interference.",
            socialApproach: "Generally conservative on social issues, emphasizing traditional family values and individual choice. Supports religious freedom and personal liberty.",
            environmentalApproach: "Balances economic growth with environmental concerns. Emphasizes market-based solutions and private sector innovation for environmental issues.",
            description: "The Republican Party generally advocates for limited government, free market economics, lower taxes, traditional values, and strong national defense."
        ),
        PoliticalParty(
            name: "Libertarian Party",
            emoji: "🟡",
            color: "yellow",
            tagline: "Maximum Freedom, Minimum Government",
            coreValues: ["Individual liberty", "Non-aggression principle", "Free market economy", "Personal responsibility", "Limited government"],
            economicApproach: "Strong free market advocate with minimal government regulation. Opposes taxation, supports ending most government programs and replacing them with private alternatives.",
            socialApproach: "Progressive on social freedoms - supports LGBTQ+ rights, drug legalization, and personal choice. Opposes both social and economic coercion.",
            environmentalApproach: "Market-based solutions to environmental problems. Supports property rights and private conservation efforts over government mandates.",
            description: "The Libertarian Party advocates for maximum individual liberty and minimal government intervention in both social and economic matters. Emphasizes personal responsibility and free market solutions."
        ),
        PoliticalParty(
            name: "Green Party",
            emoji: "🟢",
            color: "green",
            tagline: "Ecology, Social Justice, Democracy",
            coreValues: ["Environmental sustainability", "Social justice", "Grassroots democracy", "Peace", "Fair economics"],
            economicApproach: "Supports cooperative economics, fair wages, workers' rights, and local business. Advocates for sustainable practices over traditional GDP growth.",
            socialApproach: "Strongly progressive on social issues, supporting LGBTQ+ rights, immigrant rights, racial justice, and affordable housing.",
            environmentalApproach: "Primary focus on environmental protection and climate action. Advocates for renewable energy, sustainable agriculture, and strong environmental regulations.",
            description: "The Green Party prioritizes environmental sustainability and social justice. Advocates for grassroots democracy, fair economics, and holistic solutions to interconnected problems."
        ),
        PoliticalParty(
            name: "Independent / No Affiliation",
            emoji: "⚪",
            color: "gray",
            tagline: "Choose Issues, Not Labels",
            coreValues: ["Critical thinking", "Issue-based voting", "Pragmatism", "Independence", "Open-mindedness"],
            economicApproach: "Evaluates economic policies on individual merit rather than party doctrine. May support some market solutions and some government programs depending on effectiveness.",
            socialApproach: "Evaluates social policies on their individual merits. May support progressive and conservative positions on different issues.",
            environmentalApproach: "Environmental stance depends on individual priorities and beliefs about balance between ecology and other concerns.",
            description: "Independents choose not to affiliate with any party, evaluating candidates and issues on their individual merits. This path emphasizes critical thinking, pragmatism, and voting your values rather than party loyalty."
        )
    ]
}
