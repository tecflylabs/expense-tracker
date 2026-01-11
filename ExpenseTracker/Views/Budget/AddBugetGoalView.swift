//
//  AddBudgetGoalView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import SwiftUI
import SwiftData

struct AddBudgetGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var existingBudgets: [BudgetGoal]
    
    @State private var selectedCategory: Category = .food
    @State private var monthlyLimit: String = ""
    @State private var showPaywall = false
    
    private let freeBudgetLimit = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Monthly Budget Limit") {
                    HStack {
                        Text("€")
                            .foregroundStyle(.secondary)
                        TextField("Amount", text: $monthlyLimit)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section {
                    Text("Set a monthly spending limit for \(selectedCategory.rawValue). You'll receive warnings when you reach 75% and 90% of your budget.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if !PurchaseManager.shared.hasPro && existingBudgets.count >= freeBudgetLimit {
                    Section {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            Text("Upgrade to Pro for unlimited budget goals")
                                .font(.caption)
                        }
                        .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("New Budget Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBudgetGoal()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallSheet(feature: "Unlimited Budget Goals")
            }
        }
    }
    
    private var isValid: Bool {
        guard let amount = Double(monthlyLimit), amount > 0 else {
            return false
        }
        return true
    }
    
    private func saveBudgetGoal() {
        
        if !PurchaseManager.shared.hasPro && existingBudgets.count >= freeBudgetLimit {
            showPaywall = true
            return
        }
        
        guard let amount = Double(monthlyLimit) else { return }
        
        let newBudget = BudgetGoal(
            category: selectedCategory,
            monthlyLimit: amount
        )
        
        modelContext.insert(newBudget)
        
        HapticManager.shared.notification(type: .success)
        dismiss()
    }
}

#Preview {
    AddBudgetGoalView()
        .modelContainer(for: BudgetGoal.self, inMemory: true)
}
