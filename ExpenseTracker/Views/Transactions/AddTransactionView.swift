//
//  AddTransactionView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddTransactionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var transactionToEdit: Transaction?
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: Category = .food
    @State private var selectedType: TransactionType = .expense
    @State private var date: Date = Date()
    @State private var notes: String = ""
    
    @State private var showValidationError: Bool = false
    
    private var isEditMode: Bool {
        transactionToEdit != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                categorySection
                dateSection
                notesSection
            }
            .navigationTitle(isEditMode ? "Edit Transaction" : "New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "Update" : "Save") {
                        saveTransaction()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadTransactionData()
            }
            .alert("Validation Error", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please fill in title and a valid amount.")
            }
        }
    }
    
    private var basicInfoSection: some View {
        Section("Basic Information") {
            TextField("Title", text: $title)
                .autocorrectionDisabled()
            
            HStack {
                Text("€")
                    .foregroundStyle(.secondary)
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
            }
            
            Picker("Type", selection: $selectedType) {
                ForEach([TransactionType.income, .expense], id: \.self) { type in
                    Label(type.rawValue, systemImage: type.systemImage)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // ✨ ENHANCED: Visual category picker with colors
    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: $selectedCategory) {
                ForEach(Category.allCases, id: \.self) { category in
                    HStack {
                        Image(systemName: category.systemImage)
                            .foregroundStyle(category.color)
                        Text(category.rawValue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .tag(category)
                }
            }
            .pickerStyle(.menu)
            .tint(.orange)
            
            // ✨ Visual preview of selected category
            HStack {
                Spacer()
                Image(systemName: selectedCategory.systemImage)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(selectedCategory.gradient)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(selectedCategory.rawValue)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
    }
    
    private var dateSection: some View {
        Section("Date") {
            DatePicker(
                "Transaction Date",
                selection: $date,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
        }
    }
    
    private var notesSection: some View {
        Section("Notes (Optional)") {
            TextField("Add notes...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    private func loadTransactionData() {
        guard let transaction = transactionToEdit else { return }
        
        title = transaction.title
        amount = String(format: "%.2f", transaction.amount)
        selectedCategory = transaction.category
        selectedType = transaction.type
        date = transaction.date
        notes = transaction.notes ?? ""
    }
    
    private func saveTransaction() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
              amountValue > 0 else {
            showValidationError = true
            HapticManager.shared.notification(type: .error)
            return
        }
        
        HapticManager.shared.notification(type: .success)
        
        if let transaction = transactionToEdit {
            transaction.title = title
            transaction.amount = amountValue
            transaction.category = selectedCategory
            transaction.type = selectedType
            transaction.date = date
            transaction.notes = notes.isEmpty ? nil : notes
        } else {
            let newTransaction = Transaction(
                title: title,
                amount: amountValue,
                date: date,
                category: selectedCategory,
                type: selectedType,
                notes: notes.isEmpty ? nil : notes
            )
            context.insert(newTransaction)
        }
        WidgetCenter.shared.reloadAllTimelines()
        
        withAnimation(.smooth) {
            dismiss()
        }
    }
}

#Preview("New Transaction") {
    AddTransactionView()
        .modelContainer(previewContainer())
}

#Preview("Edit Transaction") {
    AddTransactionView(transactionToEdit: .preview)
        .modelContainer(previewContainer())
}
