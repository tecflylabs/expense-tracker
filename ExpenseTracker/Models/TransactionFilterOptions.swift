//
//  TransactionFilterOptions.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import Foundation

// MARK: - Filter Type

enum TransactionFilterType: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
    
    var id: String { rawValue }
}

// MARK: - Sort Option

enum SortOption: String, CaseIterable, Identifiable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case amountHighest = "Amount (Highest)"
    case amountLowest = "Amount (Lowest)"
    
    var id: String { rawValue }
    
    var sortDescriptor: SortDescriptor<Transaction> {
        switch self {
        case .dateNewest:
            return SortDescriptor(\Transaction.date, order: .reverse)
        case .dateOldest:
            return SortDescriptor(\Transaction.date, order: .forward)
        case .amountHighest:
            return SortDescriptor(\Transaction.amount, order: .reverse)
        case .amountLowest:
            return SortDescriptor(\Transaction.amount, order: .forward)
        }
    }
}

// MARK: - Date Range Filter 

enum DateRangeFilter: String, CaseIterable, Identifiable {
    case all = "All Time"
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    case custom = "Custom Range"
    
    var id: String { rawValue }
    
    var dateRange: (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return nil
            
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
            
        case .thisWeek:
            let start = calendar.dateInterval(of: .weekOfYear, for: now)!.start
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return (start, end)
            
        case .thisMonth:
            let start = calendar.dateInterval(of: .month, for: now)!.start
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
            
        case .lastMonth:
            let thisMonthStart = calendar.dateInterval(of: .month, for: now)!.start
            let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart)!
            return (lastMonthStart, thisMonthStart)
            
        case .thisYear:
            let start = calendar.dateInterval(of: .year, for: now)!.start
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
            
        case .custom:
            return nil // Custom dates set by user
        }
    }
}

// MARK: - Filter State

struct TransactionFilters {
    var searchText: String = ""
    var type: TransactionFilterType = .all
    var categories: Set<Category> = []
    var dateRange: DateRangeFilter = .all
    var customStartDate: Date? = nil
    var customEndDate: Date? = nil
    var minAmount: Double? = nil
    var maxAmount: Double? = nil
    var sortOption: SortOption = .dateNewest
    
    var isFiltering: Bool {
        type != .all ||
        !categories.isEmpty ||
        dateRange != .all ||
        customStartDate != nil ||
        customEndDate != nil ||
        minAmount != nil ||
        maxAmount != nil
    }
    
    var activeFilterCount: Int {
        var count = 0
        if type != .all { count += 1 }
        if !categories.isEmpty { count += categories.count }
        if dateRange != .all { count += 1 }
        if minAmount != nil || maxAmount != nil { count += 1 }
        return count
    }
    
    mutating func reset() {
        searchText = ""
        type = .all
        categories.removeAll()
        dateRange = .all
        customStartDate = nil
        customEndDate = nil
        minAmount = nil
        maxAmount = nil
    }
}
