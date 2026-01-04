import SwiftUI
import Charts

struct MonthlyComparisonChartView: View {
    let data: [MonthlyData]
    @State private var selectedMonth: String?
    
    var selectedData: MonthlyData? {
        guard let selectedMonth = selectedMonth else { return nil }
        return data.first(where: { $0.month == selectedMonth })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Monthly Income vs Expenses")
                    .font(.headline)
                
                Spacer()
                
                if let selected = selectedData {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(selected.month)
                            .font(.caption.bold())
                        HStack(spacing: 8) {
                            Label(selected.income.asCurrency(), systemImage: "arrow.down.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Label(selected.expense.asCurrency(), systemImage: "arrow.up.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            
            if data.isEmpty {
                emptyState
            } else {
                chart
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var chart: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Month", item.month),
                y: .value("Income", item.income)
            )
            .foregroundStyle(
                selectedMonth == nil || selectedMonth == item.month
                ? Color.green.gradient
                : Color.green.opacity(0.3).gradient
            )
            .position(by: .value("Type", "Income"))
            
            BarMark(
                x: .value("Month", item.month),
                y: .value("Expense", item.expense)
            )
            .foregroundStyle(
                selectedMonth == nil || selectedMonth == item.month
                ? Color.red.gradient
                : Color.red.opacity(0.3).gradient
            )
            .position(by: .value("Type", "Expense"))
        }
        .frame(height: 250)
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let month = value.as(String.self) {
                        Text(month)
                            .font(.caption)
                    }
                }
            }
        }
        .chartXSelection(value: $selectedMonth)
        .chartForegroundStyleScale([
            "Income": Color.green.gradient,
            "Expense": Color.red.gradient
        ])
        .gesture(
            TapGesture()
                .onEnded { _ in
                    withAnimation(.smooth) {
                        selectedMonth = nil
                    }
                }
        )
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Monthly Data",
            systemImage: "calendar",
            description: Text("Add transactions across months")
        )
        .frame(height: 250)
    }
}

#Preview {
    MonthlyComparisonChartView( data: [
        MonthlyData(month: "Jan 2026", income: 3000, expense: 1500),
        MonthlyData(month: "Feb 2026", income: 3200, expense: 1800),
        MonthlyData(month: "Mar 2026", income: 2800, expense: 1400)
    ])
}
