//
//  TransactionRowView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 30.12.25.
//

import SwiftUI

struct TransactionRowView: View {
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    let transaction: Transaction
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon - WITH CATEGORY COLORS
            Image(systemName: transaction.category.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(transaction.category.gradient)
                )
                .scaleEffect(appeared ? 1.0 : 0.5)
                .animation(.bouncy.delay(0.1), value: appeared)
                .overlay(alignment: .topTrailing) {
                    if transaction.isRecurring {
                        Image(systemName: "repeat.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .background(Circle().fill(Color.brandOrange))
                            .offset(x: 8, y: -8)
                    }
                }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(transaction.title)
                    .font(.headline)
                
                
                HStack(spacing: 6) {
                    // Color indicator
                    Circle()
                        .fill(transaction.category.color)
                        .frame(width: 8, height: 8)
                    
                    // Show tags OR category name
                    if !transaction.tags.isEmpty {
                        Text(transaction.tags.prefix(2).map { "#\($0)" }.joined(separator: "   "))
                            .font(.caption)
                            .foregroundStyle(.orange.opacity(0.7))
                            .lineLimit(1)
                        
                        if transaction.tags.count > 2 {
                            Text("+\(transaction.tags.count - 2)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        // No tags? Show category name
                        Text(transaction.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Amount + Date
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .income ? "+" : "-")\(transaction.amount.asCurrency(currencyCode: currencyCode))")
                    .font(.headline)
                    .foregroundStyle(transaction.type == .income ? Color.income : Color.expense)
                
                Text(transaction.date.formattedRelative())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onAppear {
            appeared = true
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.type.rawValue): \(transaction.title), \(transaction.amount.asCurrency(currencyCode: currencyCode)), \(transaction.category.rawValue)")
        .accessibilityHint("Double tap to view details")
    }
}

#Preview {
    List {
        TransactionRowView(transaction: Transaction(
            title: "Hose",
            amount: 24.00,
            date: Date.now,
            category: .shopping,
            type: .expense,
            notes: "",
            isRecurring: false
        ))
        
        TransactionRowView(transaction: Transaction(
            title: "Salary",
            amount: 2000.00,
            date: Date.now,
            category: .salary,
            type: .income,
            notes: "#salary",
            isRecurring: false
        ))
        
        TransactionRowView(transaction: Transaction(
            title: "Auto",
            amount: 50.00,
            date: Date.now,
            category: .transport,
            type: .expense,
            notes: "#teuer2 #gut",
            isRecurring: false
        ))
        
        TransactionRowView(transaction: Transaction(
            title: "Kebab",
            amount: 5.00,
            date: Date.now,
            category: .food,
            type: .expense,
            notes: "#food #nice",
            isRecurring: false
        ))
    }
}
