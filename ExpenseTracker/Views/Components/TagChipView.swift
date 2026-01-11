//
//  TagChipView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI

struct TagChipView: View {
    let tag: String
    let onTap: (() -> Void)?
    
    init(tag: String, onTap: (() -> Void)? = nil) {
        self.tag = tag
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            onTap?()
            HapticManager.shared.impact(style: .light)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "number")
                    .font(.caption2)
                
                Text(tag)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.orange.opacity(0.15))
            .foregroundStyle(.orange)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }
}


struct TagListView: View {
    let tags: [String]
    let onTagTap: ((String) -> Void)?
    
    init(tags: [String], onTagTap: ((String) -> Void)? = nil) {
        self.tags = tags
        self.onTagTap = onTagTap
    }
    
    var body: some View {
        if !tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagChipView(tag: tag) {
                            onTagTap?(tag)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TagChipView(tag: "groceries")
        
        TagListView(tags: ["weekly", "essentials", "food", "spar"]) { tag in
            print("Tapped: \(tag)")
        }
    }
    .padding()
}
