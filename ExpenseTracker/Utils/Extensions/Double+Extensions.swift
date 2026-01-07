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
}


