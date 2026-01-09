//
//  WidgetModelContainer.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import SwiftData
import Foundation

@MainActor
func widgetModelContainer() -> ModelContainer {
    
    let schema = Schema([
        Transaction.self,
        RecurringTransaction.self,
        BudgetGoal.self,
        Attachment.self
    ])
    
    guard let groupURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "group.com.hurricane.pennyflow"
    ) else {
        fatalError("App Group container not found!")
    }
    
    let url = groupURL.appendingPathComponent("ExpenseTracker.sqlite")
    
#if DEBUG
    print("🔍 [WIDGET] Database URL: \(url.path)")
    print("🔍 [WIDGET] App Group URL: \(groupURL.path)")
    print("🔍 [WIDGET] File exists: \(FileManager.default.fileExists(atPath: url.path))")
#endif
    
    let configuration = ModelConfiguration(
        schema: schema,
        url: url,
        allowsSave: true
    )
    
    do {
        return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
        fatalError("Could not create ModelContainer for widget: \(error)")
    }
}
