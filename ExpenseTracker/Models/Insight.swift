//
//  Insight.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 07.01.26.
//

import Foundation
import SwiftUI

struct Insight: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case positive
        case neutral
        case warning
    }
    
    let id: UUID
    let kind: Kind
    let title: String
    let message: String
    let systemImage: String
    let priority: Int
    
    init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        message: String,
        systemImage: String,
        priority: Int
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.priority = priority
    }
}

#Preview("Insight Model") {
    VStack(alignment: .leading, spacing: 8) {
        Text("Sample Insight:")
        Text(
            Insight(
                kind: .warning,
                title: "Budget exceeded",
                message: "Food is over limit by €12.00.",
                systemImage: "xmark.circle.fill",
                priority: 100
            ).message
        )
    }
    .padding()
}
