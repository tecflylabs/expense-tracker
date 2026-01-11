//
//  CurrencyFormatting.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 07.01.26.
//

import Foundation

enum CurrencyFormatting {
    static func format(_ value: Double, currencyCode: String, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = currencyCode      
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}


