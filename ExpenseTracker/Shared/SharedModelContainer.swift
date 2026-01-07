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
    
    // ✅ CHANGED: Vereinfachte Konfiguration
    let modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
    )
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}
