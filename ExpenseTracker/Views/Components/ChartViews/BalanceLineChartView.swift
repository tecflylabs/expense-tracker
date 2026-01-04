import SwiftUI
import Charts

struct BalanceLineChartView: View {
    let data: [DailyBalanceData]
    @State private var selectedDate: Date?
    
    var selectedData: DailyBalanceData? {
        guard let selectedDate = selectedDate else { return nil }
        return data.min(by: { abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate)) })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Balance Over Time")
                    .font(.headline)
                
                Spacer()
                
                if let selected = selectedData {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(selected.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption.bold())
                        Text(selected.balance.asCurrency())
                            .font(.caption)
                            .foregroundStyle(selected.balance >= 0 ? .green : .red)
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
            LineMark(
                x: .value("Date", item.date),
                y: .value("Balance", item.balance)
            )
            .foregroundStyle(Color.blue.gradient)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Date", item.date),
                y: .value("Balance", item.balance)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
            
            if let selectedData = selectedData {
                RuleMark(x: .value("Selected", selectedData.date))
                    .foregroundStyle(.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                
                PointMark(
                    x: .value("Selected", selectedData.date),
                    y: .value("Balance", selectedData.balance)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(100)
            }
        }
        .frame(height: 250)
        .chartXSelection(value: $selectedDate)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    withAnimation(.smooth) {
                        selectedDate = nil
                    }
                }
        )
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Data",
            systemImage: "chart.xyaxis.line",
            description: Text("Add transactions to see balance trend")
        )
        .frame(height: 250)
    }
}

#Preview {
    BalanceLineChartView( data: [
        DailyBalanceData(date: Date().addingTimeInterval(-86400 * 30), balance: 1000),
        DailyBalanceData(date: Date().addingTimeInterval(-86400 * 20), balance: 1500),
        DailyBalanceData(date: Date().addingTimeInterval(-86400 * 10), balance: 1200),
        DailyBalanceData(date: Date(), balance: 1800)
    ])
}
