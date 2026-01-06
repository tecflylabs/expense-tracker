//
//  TransactionListView.swift 
//  ExpenseTracker
//

import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var context
    @Query private var allTransactions: [Transaction]
    
    @State private var filters = TransactionFilters()
    @State private var showFilterSheet = false
    @State private var showAddSheet = false
    
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    
    // MARK: - Filtered Transactions
    
    private var filteredTransactions: [Transaction] {
        var result = allTransactions
        
        // Search (Title + Notes)
        if !filters.searchText.isEmpty {
            result = result.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(filters.searchText) ||
                (transaction.notes?.localizedCaseInsensitiveContains(filters.searchText) ?? false)
            }
        }
        
        // Filter by Type
        if filters.type != .all {
            result = result.filter { transaction in
                switch filters.type {
                case .income: return transaction.type == .income
                case .expense: return transaction.type == .expense
                case .all: return true
                }
            }
        }
        
        // Filter by Categories
        if !filters.categories.isEmpty {
            result = result.filter { filters.categories.contains($0.category) }
        }
        
        // Filter by Date Range
        if let range = filters.dateRange.dateRange {
            result = result.filter { $0.date >= range.start && $0.date < range.end }
        } else if filters.dateRange == .custom {
            if let start = filters.customStartDate {
                result = result.filter { $0.date >= start }
            }
            if let end = filters.customEndDate {
                result = result.filter { $0.date <= end }
            }
        }
        
        // Filter by Amount Range
        if let min = filters.minAmount {
            result = result.filter { $0.amount >= min }
        }
        if let max = filters.maxAmount {
            result = result.filter { $0.amount <= max }
        }
        
        // Sort
        result.sort { first, second in
            switch filters.sortOption {
            case .dateNewest: return first.date > second.date
            case .dateOldest: return first.date < second.date
            case .amountHighest: return first.amount > second.amount
            case .amountLowest: return first.amount < second.amount
            }
        }
        
        return result
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if allTransactions.isEmpty {
                emptyState
            } else {
                transactionList
            }
        }
        .id(selectedThemeRaw)
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $filters.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search transactions"
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                    HapticManager.shared.impact(style: .light)
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showFilterSheet = true
                    HapticManager.shared.impact(style: .light)
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        
                        if filters.isFiltering {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("Sort by", selection: $filters.sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView()
        }
        .sheet(isPresented: $showFilterSheet) {
            AdvancedFilterSheet(filters: $filters)
        }
        .safeAreaInset(edge: .bottom) {
            if filters.isFiltering {
                activeFiltersBar
            }
        }
    }
    
    // MARK: - Views
    
    private var transactionList: some View {
        List {
            ForEach(filteredTransactions) { transaction in
                NavigationLink {
                    TransactionDetailView(transaction: transaction)
                } label: {
                    TransactionRowView(transaction: transaction)
                }
            }
            .onDelete(perform: deleteTransactions)
        }
        .listStyle(.plain)
        .overlay {
            if filteredTransactions.isEmpty && !allTransactions.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your filters or search terms")
                )
            }
        }
    }
    
    private var activeFiltersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Filter Chips
                if filters.type != .all {
                    FilterChip(
                        title: filters.type.rawValue,
                        icon: "arrow.left.arrow.right"
                    ) {
                        filters.type = .all
                    }
                }
                
                ForEach(Array(filters.categories), id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        icon: category.systemImage
                    ) {
                        filters.categories.remove(category)
                    }
                }
                
                if filters.dateRange != .all {
                    FilterChip(
                        title: filters.dateRange.rawValue,
                        icon: "calendar"
                    ) {
                        filters.dateRange = .all
                        filters.customStartDate = nil
                        filters.customEndDate = nil
                    }
                }
                
                if filters.minAmount != nil || filters.maxAmount != nil {
                    FilterChip(
                        title: "Amount Range",
                        icon: "dollarsign.circle"
                    ) {
                        filters.minAmount = nil
                        filters.maxAmount = nil
                    }
                }
                
                // Clear All Button
                Button {
                    withAnimation {
                        filters.reset()
                    }
                    HapticManager.shared.notification(type: .success)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Clear All")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Transactions",
            systemImage: "list.bullet.rectangle",
            description: Text("Tap the + button to add your first transaction")
        )
    }
    
    // MARK: - Methods
    
    private func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            let transaction = filteredTransactions[index]
            context.delete(transaction)
        }
        HapticManager.shared.notification(type: .success)
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    let icon: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.15)) // ✅ FIXED: .orange instead of .brandOrange
        .foregroundStyle(.orange) // ✅ FIXED
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        TransactionListView()
    }
    .modelContainer(previewContainer())
}
