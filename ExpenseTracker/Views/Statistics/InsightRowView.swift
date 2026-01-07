//
//  InsightRowView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 07.01.26.
//

import SwiftUI

struct InsightRowView: View {
    let insight: Insight
    
    private var tint: Color {
        switch insight.kind {
        case .positive: return .green
        case .neutral: return .blue
        case .warning: return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.systemImage)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(tint.gradient))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(insight.title)
                    .font(.subheadline.weight(.semibold))
                
                Text(insight.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

#Preview("Insight Row") {
    VStack(spacing: 12) {
        InsightRowView(
            insight: Insight(
                kind: .positive,
                title: "Spending down",
                message: "You spent 12.3% less than last month.",
                systemImage: "arrow.down.right.circle.fill",
                priority: 70
            )
        )
        
        InsightRowView(
            insight: Insight(
                kind: .neutral,
                title: "Top spending category",
                message: "Food accounts for 34.5% of your expenses (€123.45).",
                systemImage: "chart.pie.fill",
                priority: 60
            )
        )
        
        InsightRowView(
            insight: Insight(
                kind: .warning,
                title: "Budget almost used",
                message: "Transport is at 92% (€18.00 remaining).",
                systemImage: "exclamationmark.triangle.fill",
                priority: 90
            )
        )
    }
    .padding()
    .background(Color.black)
}
