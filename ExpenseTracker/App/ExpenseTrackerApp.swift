//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//

import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    
    private var colorScheme: ColorScheme? {
        let theme = AppTheme(rawValue: selectedThemeRaw) ?? .system
        switch theme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.brandOrange)
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(sharedModelContainer())
    }
}
