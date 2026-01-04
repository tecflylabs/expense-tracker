//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var transactions: [Transaction]
    
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    
    private var selectedTheme: AppTheme {
        get {
            AppTheme(rawValue: selectedThemeRaw) ?? .system
        }
        nonmutating set {
            selectedThemeRaw = newValue.rawValue
        }
    }
    
    @State private var showDeleteAlert = false
    @State private var exportFileURL: URL?
    @State private var showShareSheet = false
    @State private var isExporting = false
    
    private var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    private var balance: Double {
        totalIncome - totalExpense
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                exportSection  // ← NEU!
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Delete All Data", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAllTransactions()
                }
            } message: {
                Text("This will permanently delete all \(transactions.count) transactions. This action cannot be undone.")
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportFileURL {
                    ShareSheet(items: [url])
                }
            }
            .overlay {
                if isExporting {
                    LoadingView()
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var exportSection: some View {
        Section {
            Button {
                exportAsCSV()
            } label: {
                Label("Export as CSV", systemImage: "tablecells")
            }
            .disabled(transactions.isEmpty)
            
            Button {
                exportAsPDF()
            } label: {
                Label("Export as PDF", systemImage: "doc.text")
            }
            .disabled(transactions.isEmpty)
        } header: {
            Label("Export", systemImage: "square.and.arrow.up")
        } footer: {
            Text("Export your transactions for backup or tax purposes.")
        }
    }
    
    private func exportAsCSV() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = ExportManager.shared.generateCSV(transactions: transactions) {
                DispatchQueue.main.async {
                    isExporting = false
                    exportFileURL = url
                    showShareSheet = true
                    HapticManager.shared.notification(type: .success)
                }
            } else {
                DispatchQueue.main.async {
                    isExporting = false
                    HapticManager.shared.notification(type: .error)
                }
            }
        }
    }
    
    private func exportAsPDF() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = ExportManager.shared.generatePDF(
                transactions: transactions,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                balance: balance
            ) {
                DispatchQueue.main.async {
                    isExporting = false
                    exportFileURL = url
                    showShareSheet = true
                    HapticManager.shared.notification(type: .success)
                }
            } else {
                DispatchQueue.main.async {
                    isExporting = false
                    HapticManager.shared.notification(type: .error)
                }
            }
        }
    }
    
    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: Binding(
                get: { selectedTheme },
                set: { newValue in
                    selectedThemeRaw = newValue.rawValue
                }
            )) {
                ForEach(AppTheme.allCases) { theme in
                    Label(theme.rawValue, systemImage: theme.icon)
                        .tag(theme)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Label("Appearance", systemImage: "paintbrush.fill")
        } footer: {
            Text("Choose between light, dark, or automatic theme based on system settings.")
        }
    }
    
    private var dataSection: some View {
        Section {
            HStack {
                Text("Total Transactions")
                Spacer()
                Text("\(transactions.count)")
                    .foregroundStyle(.secondary)
            }
            
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete All Data", systemImage: "trash")
            }
            .disabled(transactions.isEmpty)
        } header: {
            Label("Data Management", systemImage: "externaldrive.fill")
        }
    }
    
    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: "1.0.0")
            LabeledContent("Build", value: "1")
            
            Link(destination: URL(string: "https://github.com")!) {
                Label("GitHub Repository", systemImage: "link")
            }
        } header: {
            Label("About", systemImage: "info.circle.fill")
        } footer: {
            Text("Built with SwiftUI & SwiftData\n© 2026 Expense Tracker")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Methods
    
    private func deleteAllTransactions() {
        for transaction in transactions {
            context.delete(transaction)
        }
        HapticManager.shared.notification(type: .success)
    }
}

#Preview {
    SettingsView()
        .modelContainer(previewContainer())
}
