//
//  Color+Theme.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI

extension Color {
    // MARK: - App Brand Colors
    
    static let brandOrange = Color.orange
    static let brandGreen = Color.green
    static let brandRed = Color.red
    
    // MARK: - Semantic Colors
    
    static let income = Color.green
    static let expense = Color.red
    static let balance = Color.blue
    
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    
    // MARK: - Gradient Colors
    
    static var incomeGradient: LinearGradient {
        LinearGradient(
            colors: [.green, .green.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var expenseGradient: LinearGradient {
        LinearGradient(
            colors: [.red, .red.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var balanceGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var orangeGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .orange.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
