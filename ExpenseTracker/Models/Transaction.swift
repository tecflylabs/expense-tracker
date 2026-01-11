//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var title: String
    var amount: Double
    var date: Date
    var category: Category
    var type: TransactionType
    var notes: String?
    var isRecurring: Bool
    
    var tags: [String] {
        guard let notes = notes else { return [] }
        return extractTags(from: notes)
    }
    
    
    init(title: String, amount: Double, date: Date, category: Category, type: TransactionType, notes: String? = nil, isRecurring: Bool = false) {
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.type = type
        self.notes = notes
        self.isRecurring = isRecurring
    }
    
    private func extractTags(from text: String) -> [String] {
        let pattern = "#[a-zA-Z0-9_]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let tag = String(text[range])
            return tag.dropFirst().lowercased() 
        }
    }
    
    @Relationship(deleteRule: .cascade)
    var attachments: [Attachment] = []

}


