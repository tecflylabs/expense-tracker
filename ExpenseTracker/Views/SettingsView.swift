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
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @AppStorage("lockTimeout") private var lockTimeout = 1
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    private let supportedCurrencies: [String] = ["EUR", "USD", "GBP", "CHF", "JPY"]
    
    private let authManager = BiometricAuthManager.shared
    
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
                if authManager.isBiometricAvailable {
                    securitySection
                }
                Section("Currency") {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(supportedCurrencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                }
                appearanceSection
                supportSection  
                exportSection
                dataSection
                aboutSection
                
#if DEBUG
                debugSection
#endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .tint(.brandOrange)  // ✅ Global orange tint
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
    
    // MARK: - Security Section
    
    private var securitySection: some View {
        Section {
            Toggle(isOn: $biometricLockEnabled) {
                Label("\(authManager.biometricType.displayName) Lock", systemImage: authManager.biometricType.icon)
            }
            .tint(.brandOrange)
            
            if biometricLockEnabled {
                Picker("Auto-lock after", selection: $lockTimeout) {
                    Text("Immediately").tag(0)
                    Text("1 minute").tag(1)
                    Text("5 minutes").tag(5)
                    Text("15 minutes").tag(15)
                }
            }
        } header: {
            Text("Security")
        } footer: {
            Text("Require \(authManager.biometricType.displayName) to unlock the app after being in background.")
        }
    }
    
    // MARK: - Appearance Section
    
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
    
    // MARK: - Support Section (Combined)
    
    private var supportSection: some View {
        Section {
            // Send Feedback
            Link(destination: URL(string: "mailto:zangl.manuel@gmail.com?subject=PennyFlow Feedback")!) {
                HStack {
                    Label("Send Feedback", systemImage: "envelope.fill")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Buy Me a Coffee
            Link(destination: URL(string: "https://buymeacoffee.com/yourname")!) {
                HStack {
                    Label("Buy Me a Coffee", systemImage: "cup.and.saucer.fill")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Label("Support", systemImage: "heart.fill")
        } footer: {
            Text("Have feedback or want to support PennyFlow? We'd love to hear from you!")
        }
    }
    
    // MARK: - Export Section
    
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
    
    // MARK: - Data Section
    
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
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: "1.0.0")
            LabeledContent("Build", value: "1")
            
            Link(destination: URL(string: "https://github.com/yourusername")!) {
                HStack {
                    Label("GitHub Repository", systemImage: "link")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Label("About", systemImage: "info.circle.fill")
        } footer: {
            Text("Built with SwiftUI & SwiftData\n© 2026 PennyFlow")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Debug Section
    
#if DEBUG
    private var debugSection: some View {
        Section {
            Button("Reset Onboarding") {
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                HapticManager.shared.notification(type: .success)
            }
            .foregroundStyle(.orange)
        } header: {
            Label("Debug", systemImage: "ladybug.fill")
        }
    }
#endif
    
    // MARK: - Methods
    
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



