//
//  Doube+Extensions.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//

import Foundation

extension Double {
    func asCurrency(currencyCode: String) -> String {
        CurrencyFormatting.format(self, currencyCode: currencyCode)
    }
    
    func asCurrency() -> String {
        let code = UserDefaults.standard.string(forKey: "currencyCode") ?? "EUR"
        return CurrencyFormatting.format(self, currencyCode: code)
    }
}


