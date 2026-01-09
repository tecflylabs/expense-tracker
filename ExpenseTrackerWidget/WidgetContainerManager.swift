//
//  WidgetContainerManager.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 09.01.26.
//

import Foundation
import SwiftData

@MainActor
final class WidgetContainerManager {
    static let shared = WidgetContainerManager()
    
    let container: ModelContainer
    
    private init() {
        print("🏗️ [WIDGET CONTAINER] Initializing...")
        
        
        let schema = Schema([
            Transaction.self,
            RecurringTransaction.self,
            BudgetGoal.self,
            Attachment.self
        ])
        
       
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.hurricane.pennyflow"
        ) else {
            print("❌ [WIDGET CONTAINER] App Group not found!")
            fatalError("App Group 'group.com.hurricane.pennyflow' not accessible. Check Signing & Capabilities.")
        }
        
        let url = groupURL.appendingPathComponent("ExpenseTracker.sqlite")
        
        print("🔍 [WIDGET CONTAINER] Database URL: \(url.path)")
        print("🔍 [WIDGET CONTAINER] File exists: \(FileManager.default.fileExists(atPath: url.path))")
        
        
        if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
           let fileSize = attrs[.size] as? Int64 {
            print("📊 [WIDGET CONTAINER] Database size: \(fileSize) bytes")
        }
        
  
        let configuration = ModelConfiguration(
            schema: schema,
            url: url,
            allowsSave: true
        )
        
        do {
            self.container = try ModelContainer(for: schema, configurations: [configuration])
            print("✅ [WIDGET CONTAINER] ModelContainer created successfully")
        } catch {
            print("❌ [WIDGET CONTAINER] Failed to create container: \(error)")
            print("❌ [WIDGET CONTAINER] Error details: \(error.localizedDescription)")
            fatalError("Could not create ModelContainer for widget: \(error)")
        }
    }
}
