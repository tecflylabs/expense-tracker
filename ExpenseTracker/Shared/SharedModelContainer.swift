import SwiftData
import Foundation

@MainActor
func sharedModelContainer() -> ModelContainer {
    let schema = Schema([
        Transaction.self,
        RecurringTransaction.self,
        BudgetGoal.self,
        Attachment.self
    ])
    
    guard let groupURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "group.com.hurricane.pennyflow"
    ) else {
        fatalError("❌ App Group 'group.com.hurricane.pennyflow' not found! Check Signing & Capabilities.")
    }
    
    let url = groupURL.appendingPathComponent("ExpenseTracker.sqlite")
    
#if DEBUG
    print("🔍 Main App Database URL: \(url.path)")
    print("🔍 App Group URL: \(groupURL.path)")
#endif
    
    let modelConfiguration = ModelConfiguration(
        schema: schema,
        url: url,
    )
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
