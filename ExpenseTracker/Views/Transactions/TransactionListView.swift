import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var context
    
    // State für Filter
    @State private var searchText = ""
    @State private var selectedType: TransactionFilterType = .all
    @State private var selectedCategories: Set<Category> = []
    @State private var sortOption: SortOption = .dateNewest
    @State private var showFilterSheet = false
    @State private var showAddSheet = false
    
    // Dynamische Query
    @Query private var allTransactions: [Transaction]
    
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    
    // Gefilterte & sortierte Transactions
    private var filteredTransactions: [Transaction] {
        var result = allTransactions
        
        // Filter nach Type
        if selectedType != .all {
            result = result.filter { transaction in
                switch selectedType {
                case .income:
                    return transaction.type == .income
                case .expense:
                    return transaction.type == .expense
                case .all:
                    return true
                }
            }
        }
        
        // Filter nach Categories
        if !selectedCategories.isEmpty {
            result = result.filter { selectedCategories.contains($0.category) }
        }
        
        // Search
        if !searchText.isEmpty {
            result = result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Sort
        result.sort { first, second in
            switch sortOption {
            case .dateNewest:
                return first.date > second.date
            case .dateOldest:
                return first.date < second.date
            case .amountHighest:
                return first.amount > second.amount
            case .amountLowest:
                return first.amount < second.amount
            }
        }
        
        return result
    }
    
    private var activeFilterCount: Int {
        var count = 0
        if selectedType != .all { count += 1 }
        if !selectedCategories.isEmpty { count += selectedCategories.count }
        return count
    }
    
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
        .searchable(text: $searchText, prompt: "Search transactions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
            }
            
            // ← DIESER BLOCK FEHLT!
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showFilterSheet = true  // ← Filter Sheet öffnen!
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("Sort by", selection: $sortOption) {
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
            FilterSheetView(
                selectedType: $selectedType,
                selectedCategories: $selectedCategories
            )
        }
        .safeAreaInset(edge: .bottom) {
            if activeFilterCount > 0 {
                filterBadge
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
            if filteredTransactions.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your filters")
                )
            }
        }
    }
    
    private var filterBadge: some View {
        HStack {
            Button {
                showFilterSheet = true
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    Text("\(activeFilterCount) Active Filter\(activeFilterCount > 1 ? "s" : "")")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.orange.gradient)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            
            Button {
                clearFilters()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
        }
        .padding()
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
    }
    
    private func clearFilters() {
        selectedType = .all
        selectedCategories.removeAll()
        searchText = ""
    }
}

#Preview {
    NavigationStack {
        TransactionListView()
    }
    .modelContainer(previewContainer())
}
