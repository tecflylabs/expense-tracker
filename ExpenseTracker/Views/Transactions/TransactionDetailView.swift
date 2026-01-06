//
//  TransactionDetailView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let transaction: Transaction
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            amountSection
            detailsSection
            dateSection
            
            if let notes = transaction.notes, !notes.isEmpty {
                notesSection(notes)
            }
            
            deleteSection
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddTransactionView(transactionToEdit: transaction)
        }
        .alert("Delete Transaction", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTransaction()
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
    }
    
    // MARK: - Sections
    
    private var amountSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(transaction.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Label(transaction.type.rawValue, systemImage: transaction.type.systemImage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(transaction.type == .income ? "+" : "-")\(transaction.amount.asCurrency())")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(transaction.type == .income ? .green : .red)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            LabeledContent {
                HStack {
                    Image(systemName: transaction.category.systemImage)
                    Text(transaction.category.rawValue)
                }
            } label: {
                Text("Category")
            }
        }
    }
    
    private var dateSection: some View {
        Section("Date") {
            LabeledContent("Transaction Date", value: transaction.date.formatted(style: .long))
            LabeledContent("Added", value: transaction.date.formattedRelative())
        }
    }
    
    // Notes section with tags
    private func notesSection(_ notes: String) -> some View {
        Section {
            Text(notes)
                .font(.body)
            
            // Show tags if available
            if !transaction.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    TagListView(tags: transaction.tags) { tag in
                        // Future: Filter by tag in parent view
                        print("Tapped tag: \(tag)")
                    }
                }
                .padding(.top, 8)
            }
        } header: {
            Label("Notes", systemImage: "note.text")
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete Transaction", systemImage: "trash")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // MARK: - Methods
    
    private func deleteTransaction() {
        context.delete(transaction)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(transaction: .preview)
    }
    .modelContainer(previewContainer())
}
