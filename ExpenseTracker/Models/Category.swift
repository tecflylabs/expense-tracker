//
//  Category.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//

import Foundation
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
    
    var primitivePlottable: String {
        self.rawValue
    }
    
    init?(primitivePlottable: String) {
        self.init(rawValue: primitivePlottable)
    }
}
