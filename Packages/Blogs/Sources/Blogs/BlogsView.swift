import SwiftUI
import Common
import AppUI

public struct BlogsView: View {
    @State private var blogs: [BlogPost] = BlogPost.samplePosts
    @State private var selectedBlog: BlogPost?
    @State private var searchText = ""
    @State private var showCreateSheet = false
    let currentUserId = "current_user" // Replace with actual current user ID
    
    public init() {}
    
    public var filteredBlogs: [BlogPost] {
        if searchText.isEmpty {
            return blogs
        }
        return blogs.filter { blog in
            blog.title.localizedCaseInsensitiveContains(searchText) ||
            blog.excerpt.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.black : UIColor.white })
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header with Add Button
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Blogs")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Read and share stories from the community")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { showCreateSheet = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search blogs...", text: $searchText)
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)
                        
                        // Blog Posts
                        VStack(spacing: 12) {
                            if filteredBlogs.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "book.closed")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    
                                    Text("No blogs found")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Check back soon for new content")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                            } else {
                                ForEach(filteredBlogs) { blog in
                                    NavigationLink(destination: BlogDetailView(blog: blog, blogs: $blogs, currentUserId: currentUserId)) {
                                        BlogCardView(blog: blog, isAuthor: blog.isAuthor(currentUserId), onDelete: {
                                            blogs.removeAll { $0.id == blog.id }
                                        }, onEdit: {
                                            showCreateSheet = true
                                        })
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Blogs")
            .sheet(isPresented: $showCreateSheet) {
                BlogEditorView(blogs: $blogs, currentUserId: currentUserId)
            }
        }
    }
}

public struct BlogCardView: View {
    public let blog: BlogPost
    public let isAuthor: Bool
    public var onDelete: () -> Void = {}
    public var onEdit: () -> Void = {}
    @State private var showDeleteConfirm = false
    
    public init(blog: BlogPost, isAuthor: Bool, onDelete: @escaping () -> Void = {}, onEdit: @escaping () -> Void = {}) {
        self.blog = blog
        self.isAuthor = isAuthor
        self.onDelete = onDelete
        self.onEdit = onEdit
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Badge with Author Info
            HStack(spacing: 8) {
                Text(blog.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(12)
                
                Spacer()
                
                if isAuthor {
                    Menu {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Text(blog.dateFormatted)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Title
            Text(blog.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Excerpt
            Text(blog.excerpt)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Author & Read Time
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    Text(blog.author)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    Text("\(blog.readTime) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
        .cornerRadius(12)
        .alert("Delete Blog", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this blog? This cannot be undone.")
        }
    }
}

public struct BlogDetailView: View {
    public let blog: BlogPost
    @Binding public var blogs: [BlogPost]
    public let currentUserId: String
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirm = false
    @State private var showEditSheet = false
    
    public init(blog: BlogPost, blogs: Binding<[BlogPost]>, currentUserId: String) {
        self.blog = blog
        self._blogs = blogs
        self.currentUserId = currentUserId
    }
    
    var isAuthor: Bool {
        blog.isAuthor(currentUserId)
    }
    
    public var body: some View {
        ZStack {
            Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.black : UIColor.white })
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                // Category
                                Text(blog.category)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                
                                // Title
                                Text(blog.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            if isAuthor {
                                Menu {
                                    Button {
                                        showEditSheet = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        showDeleteConfirm = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        // Metadata
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                Text(blog.author)
                                    .font(.caption)
                            }
                            
                            Text(blog.dateFormatted)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(blog.readTime) min read")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
                    .cornerRadius(12)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(blog.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1) }))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Blog")
        .navigationBarBackButtonHidden(false)
        .alert("Delete Blog", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                blogs.removeAll { $0.id == blog.id }
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this blog? This cannot be undone.")
        }
        .sheet(isPresented: $showEditSheet) {
            BlogEditorView(blogs: $blogs, currentUserId: currentUserId, editingBlog: blog)
        }
    }
}

public struct BlogPost: Identifiable {
    public let id: UUID
    public var title: String
    public var excerpt: String
    public var content: String
    public let author: String
    public let authorId: String // User ID of the author
    public var category: String
    public let date: Date
    public var readTime: Int
    
    public init(id: UUID = UUID(), title: String, excerpt: String, content: String, author: String, authorId: String, category: String, date: Date = Date(), readTime: Int = 5) {
        self.id = id
        self.title = title
        self.excerpt = excerpt
        self.content = content
        self.author = author
        self.authorId = authorId
        self.category = category
        self.date = date
        self.readTime = readTime
    }
    
    public var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Check if current user is the author
    public func isAuthor(_ currentUserId: String) -> Bool {
        return authorId == currentUserId
    }
    
    public static let samplePosts: [BlogPost] = [
        BlogPost(
            title: "Turning Point USA: Expanding Conservative Voices on Campus",
            excerpt: "Learn how Turning Point USA is growing its presence across American universities with new chapters and initiatives.",
            content: """
            Turning Point USA continues to expand its mission to cultivate leadership and foster intellectual discourse on college campuses across America. With chapters now in over 500 universities, the organization is making significant strides in providing students with platforms to engage with conservative and libertarian ideas.

            The growth of TPUSA is driven by passionate student leaders and dedicated advisors who believe in the power of free speech and open debate. Through events, conferences, and educational programs, students are equipped with the knowledge and skills needed to articulate conservative principles in a modern context.

            As more students seek alternatives to mainstream narrative, Turning Point USA offers a vibrant community where ideas can be challenged, defended, and discussed in respectful environments. The organization's commitment to liberty and constitutional principles resonates with an increasingly diverse student body.
            """,
            author: "Jennifer Wellenstein",
            authorId: "user_jennifer_1",
            category: "Organization",
            date: Date(timeIntervalSince1970: 1693526400),
            readTime: 5
        ),
        BlogPost(
            title: "The Importance of Free Speech on College Campuses",
            excerpt: "Exploring the vital role of free speech in academic environments and why it matters for our nation's future.",
            content: """
            Free speech is the cornerstone of a functioning democracy and nowhere is this more important than on college campuses. Universities have traditionally served as institutions where ideas are tested, challenged, and refined through open discourse.

            However, in recent years, there has been growing concern about the erosion of free speech principles on campuses. Self-censorship, canceled speakers, and limits on intellectual exploration threaten the very mission of higher education.

            Students need spaces where they can develop critical thinking skills by encountering diverse viewpoints. When we limit speech or shield students from ideas we disagree with, we do them a disservice. The marketplace of ideas thrives when all perspectives can be heard and debated.

            Supporting organizations that defend free speech and facilitate open dialogue is essential for maintaining the integrity of our educational institutions and the health of our democracy.
            """,
            author: "Padraig Flanary",
            authorId: "user_padraig_1",
            category: "Education",
            date: Date(timeIntervalSince1970: 1693440000),
            readTime: 6
        ),
        BlogPost(
            title: "Getting Involved: How to Start or Join a TPUSA Chapter",
            excerpt: "A guide for students interested in becoming part of the Turning Point USA community on their campus.",
            content: """
            Interested in bringing Turning Point USA to your campus or joining an existing chapter? Here's everything you need to know about getting involved:

            **Starting a New Chapter**
            Contact the national organization for resources and guidance. You'll need committed co-founders who share the mission of promoting conservative values and free speech. TPUSA provides training, materials, and ongoing support to help your chapter thrive.

            **Joining an Existing Chapter**
            If your campus already has a TPUSA chapter, attending events is the best way to get involved. Most chapters hold regular meetings, speaker events, and social activities where you can connect with like-minded students.

            **What You'll Do**
            Chapter members engage in diverse activities including hosting speakers, organizing debates, participating in community outreach, attending leadership conferences, and collaborating on campus initiatives.

            **Leadership Development**
            TPUSA places a strong emphasis on developing student leaders. Through conferences, training sessions, and mentorship, members gain skills in public speaking, organization, and advocacy.

            Whether you're looking to make friends, develop leadership skills, or simply find a community aligned with your values, TPUSA chapters offer meaningful engagement opportunities.
            """,
            author: "Owen Girard",
            authorId: "user_owen_1",
            category: "Community",
            date: Date(timeIntervalSince1970: 1693353600),
            readTime: 4
        ),
    ]
}

public struct BlogEditorView: View {
    @Binding public var blogs: [BlogPost]
    public let currentUserId: String
    public var editingBlog: BlogPost?
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var excerpt = ""
    @State private var content = ""
    @State private var category = "General"
    @State private var author = ""
    
    let categories = ["General", "Organization", "Education", "Community", "News", "Opinion"]
    
    public init(blogs: Binding<[BlogPost]>, currentUserId: String, editingBlog: BlogPost? = nil) {
        self._blogs = blogs
        self.currentUserId = currentUserId
        self.editingBlog = editingBlog
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.black : UIColor.white })
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter blog title", text: $title)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal, 8)
                        }
                        .padding(.horizontal)
                        
                        // Author
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Author Name")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Your name", text: $author)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal, 8)
                        }
                        .padding(.horizontal)
                        
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Picker("Category", selection: $category) {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                        }
                        .padding(.horizontal, 8)
                        
                        // Excerpt
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Excerpt")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextEditor(text: $excerpt)
                                .frame(height: 80)
                                .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white }))
                                .cornerRadius(8)
                                .padding(.horizontal, 8)
                        }
                        .padding(.horizontal)
                        
                        // Content
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextEditor(text: $content)
                                .frame(height: 200)
                                .background(Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white }))
                                .cornerRadius(8)
                                .padding(.horizontal, 8)
                        }
                        .padding(.horizontal)
                        
                        // Publish Button
                        Button(action: saveBlog) {
                            Text(editingBlog != nil ? "Update Blog" : "Publish Blog")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(editingBlog != nil ? "Edit Blog" : "Create Blog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let blog = editingBlog {
                    title = blog.title
                    excerpt = blog.excerpt
                    content = blog.content
                    category = blog.category
                    author = blog.author
                }
            }
        }
    }
    
    private func saveBlog() {
        guard !title.isEmpty, !content.isEmpty, !author.isEmpty else { return }
        
        if let blog = editingBlog, let index = blogs.firstIndex(where: { $0.id == blog.id }) {
            // Update existing blog
            blogs[index].title = title
            blogs[index].excerpt = excerpt
            blogs[index].content = content
            blogs[index].category = category
        } else {
            // Create new blog
            let newBlog = BlogPost(
                title: title,
                excerpt: excerpt,
                content: content,
                author: author,
                authorId: currentUserId,
                category: category,
                date: Date(),
                readTime: max(1, content.split(separator: " ").count / 200)
            )
            blogs.insert(newBlog, at: 0)
        }
        
        dismiss()
    }
}

#Preview {
    BlogsView()
}
