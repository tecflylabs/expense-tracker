//
//  AdvancedFilterSheet.swift 
//  ExpenseTracker
//

import SwiftUI

struct AdvancedFilterSheet: View {
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: TransactionFilters
    
    var body: some View {
        NavigationStack {
            Form {
                typeSection
                categorySection
                dateRangeSection
                amountRangeSection
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                        HapticManager.shared.impact(style: .light)
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear All") {
                        filters.reset()
                        HapticManager.shared.notification(type: .success)
                    }
                    .disabled(!filters.isFiltering)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    // MARK: - Type Section
    
    private var typeSection: some View {
        Section {
            Picker("Transaction Type", selection: $filters.type) {
                ForEach(TransactionFilterType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                Text("Type")
            }
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        Section {
            ForEach(Category.allCases, id: \.self) { category in
                Button {
                    toggleCategory(category)
                } label: {
                    HStack {
                        // ✅ FIXED: No Label binding, manual HStack
                        Image(systemName: category.systemImage)
                        Text(category.rawValue)
                        
                        Spacer()
                        
                        if filters.categories.contains(category) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.orange)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        } header: {
            HStack {
                Image(systemName: "square.grid.2x2")
                Text("Categories")
                Spacer()
                if !filters.categories.isEmpty {
                    Text("\(filters.categories.count) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Date Range Section
    
    private var dateRangeSection: some View {
        Section {
            Picker("Date Range", selection: $filters.dateRange) {
                ForEach(DateRangeFilter.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.menu)
            
            if filters.dateRange == .custom {
                DatePicker(
                    "From",
                    selection: Binding(
                        get: { filters.customStartDate ?? Date() },
                        set: { filters.customStartDate = $0 }
                    ),
                    displayedComponents: .date
                )
                
                DatePicker(
                    "To",
                    selection: Binding(
                        get: { filters.customEndDate ?? Date() },
                        set: { filters.customEndDate = $0 }
                    ),
                    displayedComponents: .date
                )
            }
        } header: {
            HStack {
                Image(systemName: "calendar")
                Text("Date Range")
            }
        } footer: {
            if let range = filters.dateRange.dateRange {
                Text("Showing transactions from \(range.start.formatted(date: .abbreviated, time: .omitted)) to \(range.end.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Amount Range Section
    
    private var amountRangeSection: some View {
        Section {
            HStack {
                Text("€")
                    .foregroundStyle(.secondary)
                TextField("Min", value: $filters.minAmount, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            HStack {
                Text("€")
                    .foregroundStyle(.secondary)
                TextField("Max", value: $filters.maxAmount, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            if filters.minAmount != nil || filters.maxAmount != nil {
                Button("Clear Amount Range") {
                    filters.minAmount = nil
                    filters.maxAmount = nil
                }
                .foregroundStyle(.red)
            }
        } header: {
            HStack {
                Image(systemName: "dollarsign.circle")
                Text("Amount Range")
            }
        } footer: {
            if let min = filters.minAmount, let max = filters.maxAmount {
                Text("Showing transactions between \(min.asCurrency(currencyCode: currencyCode)) and \(max.asCurrency(currencyCode: currencyCode))")
                    .font(.caption)
            } else if let min = filters.minAmount {
                Text("Showing transactions above \(min.asCurrency(currencyCode: currencyCode))")
                    .font(.caption)
            } else if let max = filters.maxAmount {
                Text("Showing transactions below \(max.asCurrency(currencyCode: currencyCode))")
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Methods
    
    private func toggleCategory(_ category: Category) {
        if filters.categories.contains(category) {
            filters.categories.remove(category)
        } else {
            filters.categories.insert(category)
        }
        HapticManager.shared.selection()
    }
}

#Preview {
    AdvancedFilterSheet(filters: .constant(TransactionFilters()))
}
