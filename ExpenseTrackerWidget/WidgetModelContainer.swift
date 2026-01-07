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
    let schema = Schema([Transaction.self, Attachment.self])

    
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
        fatalError("Could not create ModelContainer for widget: \(error)")
    }
}

