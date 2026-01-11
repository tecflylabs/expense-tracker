//
//  AddRecurringTransactionView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import SwiftUI
import SwiftData

struct AddRecurringTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    let recurringToEdit: RecurringTransaction?
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: Category = .other
    @State private var selectedType: TransactionType = .expense
    @State private var selectedFrequency: RecurringFrequency = .monthly
    @State private var startDate = Date()
    @State private var notes = ""
    @State private var showValidationError = false
    @State private var showPaywall = false
    
    init(recurringToEdit: RecurringTransaction? = nil) {
        self.recurringToEdit = recurringToEdit
        
        if let recurring = recurringToEdit {
            _title = State(initialValue: recurring.title)
            _amount = State(initialValue: String(recurring.amount))
            _selectedCategory = State(initialValue: recurring.category)
            _selectedType = State(initialValue: recurring.type)
            _selectedFrequency = State(initialValue: recurring.frequency)
            _startDate = State(initialValue: recurring.startDate)
            _notes = State(initialValue: recurring.notes ?? "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                frequencySection
                detailsSection
            }
            .navigationTitle(recurringToEdit == nil ? "New Recurring" : "Edit Recurring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecurring()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Invalid Input", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please fill in all required fields with valid values.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallSheet(feature: "Recurring Transactions")
            }
        }
    }
    
    // MARK: - Sections
    
    private var basicInfoSection: some View {
        Section("Basic Information") {
            TextField("Title", text: $title)
            
            HStack {
                Text("€")
                    .foregroundStyle(.secondary)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
            
            Picker("Type", selection: $selectedType) {
                ForEach(TransactionType.allCases) { type in
                    Label(type.rawValue, systemImage: type.systemImage)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(Category.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.systemImage)
                        .tag(category)
                }
            }
        }
    }
    
    private var frequencySection: some View {
        Section("Recurrence") {
            Picker("Frequency", selection: $selectedFrequency) {
                ForEach(RecurringFrequency.allCases, id: \.self) { frequency in
                    Label(frequency.rawValue, systemImage: frequency.systemImage)
                        .tag(frequency)
                }
            }
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            
            if recurringToEdit != nil {
                HStack {
                    Text("Next Due")
                    Spacer()
                    Text(nextDueDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    private var nextDueDate: Date {
        guard let recurring = recurringToEdit else { return startDate }
        return recurring.nextDueDate
    }
    
    // MARK: - Methods
    
    private func saveRecurring() {
        // Pro Check 
        if recurringToEdit == nil && !PurchaseManager.shared.hasPro {
            showPaywall = true
            return
        }
        
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              amountValue > 0 else {
            showValidationError = true
            HapticManager.shared.notification(type: .error)
            return
        }
        
        HapticManager.shared.notification(type: .success)
        
        if let recurring = recurringToEdit {
            recurring.title = title
            recurring.amount = amountValue
            recurring.category = selectedCategory
            recurring.type = selectedType
            recurring.frequency = selectedFrequency
            recurring.startDate = startDate
            recurring.notes = notes.isEmpty ? nil : notes
        } else {
            let newRecurring = RecurringTransaction(
                title: title,
                amount: amountValue,
                category: selectedCategory,
                type: selectedType,
                frequency: selectedFrequency,
                startDate: startDate,
                notes: notes.isEmpty ? nil : notes
            )
            context.insert(newRecurring)
        }
        
        dismiss()
    }
}

#Preview {
    AddRecurringTransactionView()
        .modelContainer(previewContainer())
}
