import SwiftUI
import Charts

struct CategoryBarChartView: View {
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    let data: [CategoryChartData]
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
                        Text(selectedData.amount.asCurrency(currencyCode: currencyCode))
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
                LinearGradient(
                    colors: [
                        (selectedCategory == nil || selectedCategory == item.category) ? item.category.color : item.category.color.opacity(0.3),
                        (selectedCategory == nil || selectedCategory == item.category) ? item.category.color.opacity(0.7) : item.category.color.opacity(0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
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
                        HStack(spacing: 6) {
                            Image(systemName: cat.systemImage)
                                .font(.caption)
                                .foregroundStyle(cat.color)
                            Text(category)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
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
        CategoryChartData(category: .shopping, amount: 150, percentage: 15),
        CategoryChartData(category: .entertainment, amount: 100, percentage: 10)
    ])
    .padding()
}
