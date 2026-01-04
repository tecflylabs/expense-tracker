//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 30.12.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        MainTabView()
            .task {
                // Process recurring transactions on app start
                await processRecurringTransactions()
            }
    }
    
    private func processRecurringTransactions() async {
        RecurringTransactionManager.shared.processRecurringTransactions(context: context)
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer())
}
