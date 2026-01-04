//
//  FilterSheetView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedType: TransactionFilterType
    @Binding var selectedCategories: Set<Category>
    
    var body: some View {
        NavigationStack {
            Form {
                typeSection
                categorySection
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear All") {
                        selectedType = .all
                        selectedCategories.removeAll()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Sections
    
    private var typeSection: some View {
        Section("Transaction Type") {
            ForEach(TransactionFilterType.allCases) { type in
                Button {
                    selectedType = type
                } label: {
                    HStack {
                        Text(type.rawValue)
                            .foregroundStyle(.orange)
                        
                        Spacer()
                        
                        if selectedType == type {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
    }
    
    private var categorySection: some View {
        Section {
            ForEach(Category.allCases, id: \.self) { category in
                Button {
                    toggleCategory(category)
                } label: {
                    HStack {
                        Label(category.rawValue, systemImage: category.systemImage)
                            .foregroundStyle(.orange)
                        
                        Spacer()
                        
                        if selectedCategories.contains(category) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.orange)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text("Categories")
                Spacer()
                if !selectedCategories.isEmpty {
                    Button("Clear") {
                        selectedCategories.removeAll()
                    }
                    .foregroundStyle(.orange)
                    .font(.caption)
                    .textCase(nil)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

#Preview {
    FilterSheetView(
        selectedType: .constant(.all),
        selectedCategories: .constant([.food, .transport])
    )
    .preferredColorScheme(.dark)
}
