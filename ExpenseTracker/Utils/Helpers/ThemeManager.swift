//
//  ThemeManager.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI

class ThemeManager {
    static let shared = ThemeManager()
    
    @AppStorage("selectedTheme") var selectedThemeRaw: String = AppTheme.system.rawValue
    
    var selectedTheme: AppTheme {
        get {
            AppTheme(rawValue: selectedThemeRaw) ?? .system
        }
        set {
            selectedThemeRaw = newValue.rawValue
        }
    }
    
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    private init() {}
}
