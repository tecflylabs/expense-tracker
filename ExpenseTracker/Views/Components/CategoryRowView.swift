//
//  CategoryRowView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI

struct CategoryRowView: View {
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    let category: Category
    let amount: Double
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: category.systemImage)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(category.gradient)
                )
            
            // Category Name
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.headline)
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        // Progress - Category color
                        RoundedRectangle(cornerRadius: 4)
                            .fill(category.gradient)
                            .frame(width: geometry.size.width * (percentage / 100), height: 6)
                            .animation(.spring(duration: 0.3), value: percentage)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            // Amount & Percentage
            VStack(alignment: .trailing, spacing: 2) {
                Text(amount.asCurrency(currencyCode: currencyCode))
                    .font(.headline)
                
                Text("\(Int(percentage))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        CategoryRowView(category: .food, amount: 450.50, percentage: 35)
        CategoryRowView(category: .transport, amount: 200.00, percentage: 15)
        CategoryRowView(category: .shopping, amount: 600.00, percentage: 50)
        CategoryRowView(category: .entertainment, amount: 120.00, percentage: 10)
    }
}
