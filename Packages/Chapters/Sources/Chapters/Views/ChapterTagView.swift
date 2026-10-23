//
//  ChapterTagView.swift
//  Chapters
//
//  Created on October 23, 2026.
//

import SwiftUI

struct ChapterTagView: View {
    let tag: ChapterTag
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag.displayName)
                .font(.system(.caption2, design: .default))
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tagBackgroundColor)
        .foregroundColor(.white)
        .cornerRadius(6)
    }
    
    private var tagBackgroundColor: Color {
        switch tag {
        case .new:
            return Color.green
        case .popular:
            return Color.orange
        }
    }
}

struct ChapterTagsView: View {
    let chapter: Chapter
    
    var tags: [ChapterTag] {
        chapter.getTags()
    }
    
    var body: some View {
        if !tags.isEmpty {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    ChapterTagView(tag: tag)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ChapterTagView(tag: .new)
        ChapterTagView(tag: .popular)
        
        HStack(spacing: 6) {
            ChapterTagView(tag: .new)
            ChapterTagView(tag: .popular)
            Spacer()
        }
    }
    .padding()
}
