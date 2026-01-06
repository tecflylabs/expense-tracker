//
//  RecurringTransactionsView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 04.01.26.
//

import SwiftUI
import SwiftData

struct RecurringTransactionsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \RecurringTransaction.startDate, order: .reverse) private var recurringTransactions: [RecurringTransaction]
    
    @State private var showAddSheet = false
    @State private var recurringToEdit: RecurringTransaction?
    
    var body: some View {
        NavigationStack {
            Group {
                if recurringTransactions.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Recurring")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddRecurringTransactionView()
            }
            .sheet(item: $recurringToEdit) { recurring in
                AddRecurringTransactionView(recurringToEdit: recurring)
            }
        }
    }
    
    private var list: some View {
        List {
            ForEach(recurringTransactions) { recurring in
                RecurringRowView(recurring: recurring)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        recurringToEdit = recurring
                        HapticManager.shared.selection()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteRecurring(recurring)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            toggleActive(recurring)
                        } label: {
                            Label(
                                recurring.isActive ? "Pause" : "Resume",
                                systemImage: recurring.isActive ? "pause.fill" : "play.fill"
                            )
                        }
                        .tint(recurring.isActive ? .orange : .green)
                    }
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Recurring Transactions",
            systemImage: "repeat.circle",
            description: Text("Add recurring transactions like salary, subscriptions, or bills")
        )
    }
    
    private func deleteRecurring(_ recurring: RecurringTransaction) {
        context.delete(recurring)
        HapticManager.shared.notification(type: .success)
    }
    
    private func toggleActive(_ recurring: RecurringTransaction) {
        recurring.isActive.toggle()
        HapticManager.shared.impact(style: .medium)
    }
}

// MARK: - Recurring Row View

struct RecurringRowView: View {
    let recurring: RecurringTransaction
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: recurring.frequency.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(recurring.type == .income ? Color.green.gradient : Color.red.gradient)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recurring.title)
                        .font(.headline)
                    
                    if !recurring.isActive {
                        Image(systemName: "pause.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                HStack {
                    Text(recurring.frequency.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("·")
                        .foregroundStyle(.secondary)
                    
                    Text(recurring.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(recurring.type == .income ? "+" : "-")\(recurring.amount.asCurrency())")
                    .font(.headline)
                    .foregroundStyle(recurring.type == .income ? .green : .red)
                
                if recurring.isActive {
                    Text("Next: \(recurring.nextDueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Paused")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecurringTransactionsView()
        .modelContainer(previewContainer())
}
