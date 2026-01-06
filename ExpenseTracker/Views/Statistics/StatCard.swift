//
//  StatCard.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 06.01.26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    let subtitle: String?
    let trend: TrendIndicator?
    
    init(
        title: String,
        value: String,
        icon: String,
        iconColor: Color = .blue,
        subtitle: String? = nil,
        trend: TrendIndicator? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
        self.subtitle = subtitle
        self.trend = trend
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [iconColor, iconColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary.opacity(0.7))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Trend
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .font(.caption)
                    Text(trend.text)
                        .font(.caption2.bold())
                }
                .foregroundStyle(trend.color)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.cardBackground, Color.cardBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Trend Indicator
struct TrendIndicator {
    let text: String
    let isPositive: Bool
    
    var icon: String {
        isPositive ? "arrow.up.right" : "arrow.down.right"
    }
    
    var color: Color {
        isPositive ? .green : .red
    }
}

#Preview {
    VStack(spacing: 12) {
        StatCard(
            title: "Balance",
            value: "€ 3,467.21",
            icon: "dollarsign.circle.fill",
            iconColor: .green,
            subtitle: "This month"
        )
        
        StatCard(
            title: "Income",
            value: "€ 3,500.00",
            icon: "arrow.down.circle.fill",
            iconColor: .green,
            trend: TrendIndicator(text: "+12.5%", isPositive: true)
        )
        
        StatCard(
            title: "Most Used",
            value: "Transport",
            icon: "car.fill",
            iconColor: .blue,
            subtitle: "1 transactions"
        )
    }
    .padding()
    .background(Color.black)
}
