//
//  StatCardView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let gradientColors: [Color]
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: isPressed)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: gradientColors[0].opacity(0.3), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.bouncy, value: isPressed)
        .onTapGesture {
            isPressed = true
            HapticManager.shared.impact(style: .light)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
        .sensoryFeedback(.selection, trigger: isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        StatCardView(
            title: "Total Income",
            value: "€3,500.00",
            icon: "arrow.down.circle.fill",
            gradientColors: [.green, .green.opacity(0.7)]
        )
        
        StatCardView(
            title: "Total Expenses",
            value: "€1,250.50",
            icon: "arrow.up.circle.fill",
            gradientColors: [.red, .red.opacity(0.7)]
        )
    }
    .padding()
}
