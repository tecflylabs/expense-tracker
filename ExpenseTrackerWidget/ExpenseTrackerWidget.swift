//
//  ExpenseTrackerWidget.swift
//  ExpenseTrackerWidget
//
//  Created by Manuel Zangl on 04.01.26.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry

struct WidgetEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let recentTransactions: [Transaction]
    let monthlyIncome: Double
    let monthlyExpense: Double
}

// MARK: - Timeline Provider

@MainActor
struct Provider: TimelineProvider {
    
    
    
    @MainActor
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(
            date: Date(),
            balance: 1250.50,
            recentTransactions: [],
            monthlyIncome: 3500,
            monthlyExpense: 2249.50
        )
    }
    
    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let entry = fetchData()
        completion(entry)
    }
    
    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = fetchData()
        
        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    @MainActor
    private func fetchData() -> WidgetEntry {
        let container = widgetModelContainer()
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        guard let transactions = try? context.fetch(descriptor) else {
            return WidgetEntry(
                date: Date(),
                balance: 0,
                recentTransactions: [],
                monthlyIncome: 0,
                monthlyExpense: 0
            )
        }
        
        let totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let balance = totalIncome - totalExpense
        
        // Current month data
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        let monthlyTransactions = transactions.filter { $0.date >= monthStart }
        let monthlyIncome = monthlyTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let monthlyExpense = monthlyTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        return WidgetEntry(
            date: Date(),
            balance: balance,
            recentTransactions: Array(transactions.prefix(5)),
            monthlyIncome: monthlyIncome,
            monthlyExpense: monthlyExpense
        )
    }
}

// MARK: - Small Widget (Balance)

struct SmallWidgetView: View {
    let entry: WidgetEntry
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: entry.balance >= 0
                ? [Color.blue, Color.purple]
                : [Color.orange, Color.red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                
                Text("Balance")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(entry.balance.asCurrency(currencyCode: currencyCode))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .padding()
        }
    }
}

// MARK: - Medium Widget (Recent Transactions)

struct MediumWidgetView: View {
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    let entry: WidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Recent", systemImage: "clock.fill")
                    .font(.headline)
                Spacer()
                Text(entry.balance.asCurrency(currencyCode: currencyCode))
                    .font(.subheadline.bold())
                    .foregroundStyle(entry.balance >= 0 ? .green : .red)
            }
            
            if entry.recentTransactions.isEmpty {
                Spacer()
                Text("No transactions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(entry.recentTransactions.prefix(3)) { transaction in
                    HStack(spacing: 8) {
                        Image(systemName: transaction.category.systemImage)
                            .font(.caption)
                            .foregroundStyle(transaction.type == .income ? .green : .red)
                            .frame(width: 24)
                        
                        Text(transaction.title)
                            .font(.caption)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text((transaction.type == .income ? "+" : "-") + transaction.amount.asCurrency(currencyCode: currencyCode))
                            .font(.caption.bold())
                            .foregroundStyle(transaction.type == .income ? .green : .red)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Large Widget (Monthly Stats)

struct LargeWidgetView: View {
    let entry: WidgetEntry
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("This Month", systemImage: "calendar")
                    .font(.headline)
                Spacer()
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Balance Card
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry.balance.asCurrency(currencyCode: currencyCode))
                        .font(.title2.bold())
                        .foregroundStyle(entry.balance >= 0 ? .green : .red)
                }
                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Monthly Stats
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Income", systemImage: "arrow.down.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Text(entry.monthlyIncome.asCurrency(currencyCode: currencyCode))
                        .font(.subheadline.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Label("Expense", systemImage: "arrow.up.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Text(entry.monthlyExpense.asCurrency(currencyCode: currencyCode))
                        .font(.subheadline.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Recent Transactions
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Transactions")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                
                if entry.recentTransactions.isEmpty {
                    Text("No transactions yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(entry.recentTransactions.prefix(4)) { transaction in
                        HStack(spacing: 8) {
                            Image(systemName: transaction.category.systemImage)
                                .font(.caption2)
                                .foregroundStyle(transaction.type == .income ? .green : .red)
                                .frame(width: 20)
                            
                            Text(transaction.title)
                                .font(.caption)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text((transaction.type == .income ? "+" : "-") + transaction.amount.asCurrency(currencyCode: currencyCode))
                                .font(.caption2.bold())
                                .foregroundStyle(transaction.type == .income ? .green : .red)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Widget Configuration

struct ExpenseTrackerWidget: Widget {
    let kind: String = "ExpenseTrackerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Expense Tracker")
        .description("Track your finances at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget View Router

struct WidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: WidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ExpenseTrackerWidget()
} timeline: {
    WidgetEntry(
        date: Date(),
        balance: 1250.50,
        recentTransactions: [],
        monthlyIncome: 3500,
        monthlyExpense: 2249.50
    )
}

#Preview(as: .systemMedium) {
    ExpenseTrackerWidget()
} timeline: {
    WidgetEntry(
        date: Date(),
        balance: 1250.50,
        recentTransactions: [
            Transaction(title: "Groceries", amount: 50, date: Date.now, category: .food, type: .expense),
            Transaction(title: "Salary", amount: 3000, date: Date.now, category: .salary, type: .income),
            Transaction(title: "Coffee", amount: 5, date: Date.now, category: .food, type: .expense)
        ],
        monthlyIncome: 3500,
        monthlyExpense: 2249.50
    )
}

#Preview(as: .systemLarge) {
    ExpenseTrackerWidget()
} timeline: {
    WidgetEntry(
        date: Date(),
        balance: 1250.50,
        recentTransactions: [
            Transaction(title: "Groceries", amount: 50, date: Date.now, category: .food, type: .expense),
            Transaction(title: "Salary", amount: 3000, date: Date.now, category: .salary, type: .income),
            Transaction(title: "Coffee", amount: 5, date: Date.now, category: .food, type: .expense),
            Transaction(title: "Transport", amount: 30, date: Date.now, category: .transport, type: .expense)
        ],
        monthlyIncome: 3500,
        monthlyExpense: 2249.50
    )
}
