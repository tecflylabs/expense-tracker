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
    @Environment(\.openURL) private var openURL
    
    @Query private var transactions: [Transaction]
    
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @AppStorage("lockTimeout") private var lockTimeout = 1
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    private let supportedCurrencies: [String] = ["EUR", "USD", "GBP", "CHF", "JPY"]
    
    private let authManager = BiometricAuthManager.shared
    
    // MARK: - URLs
    private let supportEmail = "zangl.manuel@gmail.com"
    private let githubPagesBaseURL = "https://tecflylabs.github.io/expense-tracker"
    private let githubRepoURL = "https://github.com/tecflylabs/expense-tracker"
    
    private var privacyPolicyURL: URL? {
        URL(string: "\(githubPagesBaseURL)/privacy.html")
    }
    
    private var supportURL: URL? {
        URL(string: "\(githubPagesBaseURL)/support.html")
    }
    
    private var mailtoURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: "PennyFlow Support"),
        ]
        return components.url
    }
    
    private var selectedTheme: AppTheme {
        get { AppTheme(rawValue: selectedThemeRaw) ?? .system }
        nonmutating set { selectedThemeRaw = newValue.rawValue }
    }
    
    @State private var showDeleteAlert = false
    @State private var exportFileURL: URL?
    @State private var showShareSheet = false
    @State private var isExporting = false
    @State private var showPaywallSheet = false
    
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
                
                proStatusSection
                
                Section("Currency") {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(supportedCurrencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                }
                
                appearanceSection
                exportSection
                dataSection
                supportSection
                aboutSection
                
#if DEBUG
                //                debugSection
#endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .tint(.brandOrange)
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
            .sheet(isPresented: $showPaywallSheet) {
                PaywallSheet(feature: "Pro Features")
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
    
    // MARK: - Pro Status Section
    
    private var proStatusSection: some View {
        Section {
            if PurchaseManager.shared.hasPro {
                Label("Pro Version Active", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            } else {
                Button {
                    showPaywallSheet = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unlock Pro Features")
                                .font(.headline)
                            Text("Lifetime access for just €4.99")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                    }
                }
            }
        } header: {
            Label("Pro Features", systemImage: "star.fill")
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
    
    // MARK: - Support Section
    
    private var supportSection: some View {
        Section {
            
            
            if let supportURL {
                Link(destination: supportURL) {
                    HStack {
                        Label("Support Website", systemImage: "questionmark.circle.fill")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }.tint(.primary)
            } else {
                HStack {
                    Label("Support Website", systemImage: "questionmark.circle.fill")
                    Spacer()
                    Text("Coming soon")
                        .foregroundStyle(.secondary)
                }.tint(.primary)
            }
            
            if let privacyPolicyURL {
                Link(destination: privacyPolicyURL) {
                    HStack {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }.tint(.primary)
            } else {
                HStack {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                    Spacer()
                    Text("Coming soon")
                        .foregroundStyle(.secondary)
                }.tint(.primary)
            }
        } header: {
            Label("Support", systemImage: "heart.fill")
        } footer: {
            Text("Questions or feedback? Visit the support site.")
        }
    }
    
    
    // MARK: - Export Section
    
    private var exportSection: some View {
        Section {
            Button {
                exportAsCSV()
            } label: {
                Label("Export as CSV", systemImage: "tablecells")
                    .tint(.primary)
            }
            .disabled(transactions.isEmpty)
            
            Button {
                exportAsPDF()
            } label: {
                Label("Export as PDF", systemImage: "doc.text")
                    .tint(.primary)
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
            
            Link(destination: URL(string: githubRepoURL)!) {
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
        guard PurchaseManager.shared.hasPro else {
            showPaywallSheet = true
            return
        }
        
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
