//
//  Category.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 30.12.25.
//

import Foundation
import SwiftUI
import Charts

enum Category: String, Codable, CaseIterable, Plottable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case health = "Health"
    case bills = "Bills"
    case salary = "Salary"
    case other = "Other"
    
    var systemImage: String {
        switch self {
        case .food:
            return "fork.knife"
        case .transport:
            return "car.fill"
        case .shopping:
            return "cart.fill"
        case .entertainment:
            return "tv.fill"
        case .health:
            return "cross.case.fill"
        case .bills:
            return "doc.text.fill"
        case .salary:
            return "banknote.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
    
    // ✨ NEW: Category Colors
    var color: Color {
        switch self {
        case .food:
            return .orange
        case .transport:
            return .blue
        case .shopping:
            return .purple
        case .entertainment:
            return .pink
        case .health:
            return .red
        case .bills:
            return .gray
        case .salary:
            return .green
        case .other:
            return .gray
        }
    }
    
    // Gradient for visual richness
    var gradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var primitivePlottable: String {
        self.rawValue
    }
    
    init?(primitivePlottable: String) {
        self.init(rawValue: primitivePlottable)
    }
}
