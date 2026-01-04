//
//  ChartsView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 03.01.26.
//

import SwiftUI
import SwiftData

struct ChartsView: View {
    @Query private var transactions: [Transaction]
    @State private var viewModel = ChartsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.hasData {
                    VStack(spacing: 20) {
                        BalanceLineChartView( data: viewModel.balanceOverTimeData)
                        
                        CategoryBarChartView( data: viewModel.categoryChartData)
                        
                        CategoryPieChartView( data: viewModel.categoryChartData)
                        
                        MonthlyComparisonChartView( data: viewModel.monthlyChartData)
                    }
                    .padding()
                } else {
                    emptyState
                }
            }
            .navigationTitle("Charts")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: transactions.count) { oldValue, newValue in
                viewModel.transactions = transactions
            }
            .onAppear {
                viewModel.transactions = transactions
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Charts Available",
            systemImage: "chart.bar.xaxis",
            description: Text("Add transactions to see visual insights")
        )
    }
}

#Preview {
    ChartsView()
        .modelContainer(previewContainer())
}
