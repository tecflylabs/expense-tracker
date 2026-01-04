import SwiftData
import Foundation

@MainActor
func sharedModelContainer() -> ModelContainer {
    let schema = Schema([
        Transaction.self,
        RecurringTransaction.self
    ])
    
#if targetEnvironment(simulator)
    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
    )
#else
    let groupURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "group.com.hurricane.expensetracker"
    )!
    
    let url = groupURL.appendingPathComponent("ExpenseTracker.sqlite")
    
    let configuration = ModelConfiguration(
        url: url,
        allowsSave: true
    )
#endif
    
    do {
        return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
