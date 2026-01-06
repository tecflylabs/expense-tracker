//
//  MainTabView.swift
//  PennyFlow
//
//  Created by Manuel Zangl
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    @Environment(\.modelContext) private var modelContext
    
    private var colorScheme: ColorScheme? {
        let theme = AppTheme(rawValue: selectedThemeRaw) ?? .system
        switch theme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: some View {
        TabView {
            // Dashboard
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            
            // Transactions (with Recurring access inside)
            NavigationStack {
                TransactionListView()
            }
            .tabItem {
                Label("Transactions", systemImage: "list.bullet")
            }
            
            // ✨ NEW: Insights (Statistics + Charts)
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            // Settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .preferredColorScheme(colorScheme)
        .id(colorScheme)
    }
}

#Preview {
    MainTabView()
        .modelContainer(previewContainer())
}
