import SwiftUI
import Charts

struct CategoryBarChartView: View {
    let data:  [CategoryChartData]
    @State private var selectedCategory: Category?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Spending by Category")
                    .font(.headline)
                
                Spacer()
                
                if let selected = selectedCategory,
                   let selectedData = data.first(where: { $0.category == selected }) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(selectedData.category.rawValue)
                            .font(.caption.bold())
                        Text(selectedData.amount.asCurrency())
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
                x: .value("Amount", item.amount),
                y: .value("Category", item.category.rawValue)
            )
            .foregroundStyle(
                selectedCategory == nil || selectedCategory == item.category
                ? Color.brandOrange.gradient
                : Color.brandOrange.opacity(0.3).gradient
            )
            .cornerRadius(8)
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let category = value.as(String.self),
                       let cat = Category(rawValue: category) {
                        HStack(spacing: 4) {
                            Image(systemName: cat.systemImage)
                                .font(.caption)
                            Text(category)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .frame(height: CGFloat(data.count) * 50)
        .chartYSelection(value: $selectedCategory)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    withAnimation(.smooth) {
                        selectedCategory = nil
                    }
                }
        )
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Expenses",
            systemImage: "chart.bar",
            description: Text("Add some expenses to see breakdown")
        )
        .frame(height: 200)
    }
}

#Preview {
    CategoryBarChartView( data: [
        CategoryChartData(category: .food, amount: 450, percentage: 45),
        CategoryChartData(category: .transport, amount: 300, percentage: 30),
        CategoryChartData(category: .shopping, amount: 150, percentage: 15)
    ])
}
