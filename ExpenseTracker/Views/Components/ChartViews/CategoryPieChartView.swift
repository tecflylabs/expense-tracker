import SwiftUI
import Charts

struct CategoryPieChartView: View {
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    let data: [CategoryChartData]
    @State private var selectedCategory: Category?
    
    // Farben für Kategorien
    private func colorForCategory(_ category: Category) -> Color {
        switch category {
        case .food:
            return .orange
        case .transport:
            return .blue
        case .shopping:
            return .pink
        case .entertainment:
            return .purple
        case .health:
            return .red
        case .bills:
            return .yellow
        case .salary:
            return .green
        case .other:
            return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Distribution")
                .font(.headline)
            
            if data.isEmpty {
                emptyState
            } else {
                chart
                legend
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var chart: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .cornerRadius(5)
            .foregroundStyle(item.category.gradient)
            .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.3)
        }
        .frame(height: 250)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                if let selectedCategory = selectedCategory,
                   let selectedData = data.first(where: { $0.category == selectedCategory }) {
                    VStack(spacing: 4) {
                        Image(systemName: selectedData.category.systemImage)
                            .font(.title)
                            .foregroundStyle(colorForCategory(selectedData.category))
                        Text(selectedData.amount.asCurrency(currencyCode: currencyCode))
                            .font(.title2.bold())
                        Text("\(Int(selectedData.percentage))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("Tap below")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
        }
    }
    
    private var legend: some View {
        VStack(spacing: 8) {
            ForEach(data) { item in
                Button {
                    withAnimation(.smooth) {
                        if selectedCategory == item.category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = item.category
                        }
                    }
                    HapticManager.shared.selection()
                } label: {
                    HStack {
                        Circle()
                            .fill(colorForCategory(item.category))
                            .frame(width: 12, height: 12)
                        
                        Image(systemName: item.category.systemImage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(item.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text(item.amount.asCurrency(currencyCode: currencyCode))
                            .font(.caption.bold())
                            .foregroundStyle(.primary)
                        
                        Text("(\(Int(item.percentage))%)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        selectedCategory == item.category
                        ? colorForCategory(item.category).opacity(0.1)
                        : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.5)
            }
        }
        .padding(.top, 8)
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Categories",
            systemImage: "chart.pie",
            description: Text("Add expenses to see distribution")
        )
        .frame(height: 300)
    }
}

#Preview {
    CategoryPieChartView( data: [
        CategoryChartData(category: .food, amount: 450, percentage: 45),
        CategoryChartData(category: .transport, amount: 300, percentage: 30),
        CategoryChartData(category: .shopping, amount: 250, percentage: 25)
    ])
    .padding()
}
