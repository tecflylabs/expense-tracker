//
//  TransactionRowView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//


import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.category.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(transaction.type == .income ? Color.incomeGradient : Color.expenseGradient)
                )
                .scaleEffect(appeared ? 1.0 : 0.5)
                .animation(.bouncy.delay(0.1), value: appeared)
                .overlay(alignment: .topTrailing) {
                    if transaction.isRecurring {  // ← NEU!
                        Image(systemName: "repeat.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .background(Circle().fill(Color.brandOrange))
                            .offset(x: 8, y: -8)
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                
                HStack {
                    Text(transaction.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if let notes = transaction.notes, !notes.isEmpty {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.type == .income ? "+" : "-" + transaction.amount.asCurrency())
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
        .accessibilityLabel("\(transaction.type.rawValue): \(transaction.title), \(transaction.amount.asCurrency()), \(transaction.category.rawValue)")
        .accessibilityHint("Double tap to view details")
    }
}

#Preview {
    List {
        TransactionRowView(transaction: .preview)
        TransactionRowView(transaction: Transaction(
            title: "Netflix",
            amount: 15.99,
            date: Date.now,
            category: .entertainment,
            type: .expense,
            isRecurring: true
        ))
    }
}

