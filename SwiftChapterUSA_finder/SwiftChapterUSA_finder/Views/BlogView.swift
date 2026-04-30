//
//  BlogView.swift
//  SwiftChapterUSA Finder
//
//  Created on November 15, 2025.
//

import SwiftUI

struct BlogView: View {
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingCreatePost = false
    @State private var selectedFilter = "All Posts"
    
    let filters = ["All Posts", "My Chapter", "My State"]
    
    var filteredPosts: [BlogPost] {
        switch selectedFilter {
        case "My Chapter":
            if let chapterId = authManager.currentUser?.chapterId {
                return chapterManager.blogPosts.filter { $0.chapterId == chapterId }
            }
            return []
        case "My State":
            if let userState = authManager.currentUser?.state {
                let stateChapterIds = chapterManager.chaptersInState(userState).map { $0.id }
                return chapterManager.blogPosts.filter { post in
                    if let chapterId = post.chapterId {
                        return stateChapterIds.contains(chapterId)
                    }
                    return true
                }
            }
            return chapterManager.blogPosts
        default:
            return chapterManager.blogPosts
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filters, id: \.self) { filter in
                        Text(filter).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(white: 0.98))
                
                // Posts List
                if filteredPosts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No posts yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Be the first to start a conversation!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredPosts) { post in
                                BlogPostCard(post: post)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Blog")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
            }
        }
        #if os(iOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

struct BlogPostCard: View {
    let post: BlogPost
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingReplies = false
    @State private var replyText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Info
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.headline)
                    Text(post.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Post Content
            Text(post.content)
                .font(.body)
            
            // Action Buttons
            HStack(spacing: 20) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "heart")
                        Text("\(post.likes)")
                    }
                    .foregroundColor(.secondary)
                }
                
                Button(action: {
                    withAnimation {
                        showingReplies.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("\(post.replies.count)")
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .font(.subheadline)
            
            // Replies Section
            if showingReplies {
                Divider()
                
                // Existing Replies
                if !post.replies.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(post.replies) { reply in
                            ReplyCard(reply: reply)
                        }
                    }
                }
                
                // Add Reply
                HStack {
                    TextField("Write a reply...", text: $replyText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        addReply()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(replyText.isEmpty)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func addReply() {
        guard let user = authManager.currentUser, !replyText.isEmpty else { return }
        
        let reply = BlogPost.Reply(
            authorId: user.id,
            authorName: user.fullName,
            content: replyText
        )
        
        chapterManager.addReplyToPost(postId: post.id, reply: reply)
        replyText = ""
    }
}

struct ReplyCard: View {
    let reply: BlogPost.Reply
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .font(.caption)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(reply.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(reply.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(reply.content)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(white: 0.98))
        .cornerRadius(10)
    }
}

struct CreatePostView: View {
    @EnvironmentObject var chapterManager: ChapterManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var postContent = ""
    @State private var postToChapter = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Post Content")) {
                    TextEditor(text: $postContent)
                        .frame(minHeight: 150)
                }
                
                Section {
                    Toggle("Post to my chapter only", isOn: $postToChapter)
                }
                
                Section {
                    Button(action: createPost) {
                        HStack {
                            Spacer()
                            Text("Post")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(postContent.isEmpty)
                }
            }
            .navigationTitle("Create Post")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #endif
            }
        }
    }
    
    private func createPost() {
        guard let user = authManager.currentUser else { return }
        
        let chapterId = postToChapter ? user.chapterId : nil
        
        let newPost = BlogPost(
            authorId: user.id,
            authorName: user.fullName,
            content: postContent,
            chapterId: chapterId
        )
        
        chapterManager.addBlogPost(newPost)
        presentationMode.wrappedValue.dismiss()
    }
}
