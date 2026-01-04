//
//  ChartModels.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 03.01.26.
//

import Foundation

struct CategoryChartData: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
    let percentage: Double
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: String
    let income: Double
    let expense: Double
    
    var monthDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.date(from: month) ?? Date()
    }
}

struct DailyBalanceData: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Double
}
