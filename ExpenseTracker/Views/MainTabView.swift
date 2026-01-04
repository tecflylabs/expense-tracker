import SwiftUI
import SwiftData

struct MainTabView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    
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
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }
            
            NavigationStack {
                TransactionListView()
            }
            .tabItem {
                Label("Transactions", systemImage: "list.bullet")
            }
            
            RecurringTransactionsView()
                .tabItem {
                    Label("Recurring", systemImage: "repeat.circle")
                }
            
            ChartsView()
                .tabItem {
                    Label("Charts", systemImage: "chart.xyaxis.line")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    MainTabView()
        .modelContainer(previewContainer())
}
