//
//  TransactionDetailView.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 02.01.26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct TransactionDetailView: View {
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let transaction: Transaction
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var attachmentToPreview: Attachment?
    @State private var attachmentToDelete: Attachment?
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showPaywallSheet = false
    
    var body: some View {
        List {
            amountSection
            detailsSection
            dateSection
            
            if let notes = transaction.notes, !notes.isEmpty {
                notesSection(notes)
            }
            
            attachmentsSection
            deleteSection
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showEditSheet = true }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddTransactionView(transactionToEdit: transaction)
        }
        .sheet(item: $attachmentToPreview) { attachment in
            AttachmentPreviewView(url: AttachmentStore.resolveURL(relativePath: attachment.relativePath))
        }
        .sheet(isPresented: $showPaywallSheet) {
            PaywallSheet(feature: "Photo Attachments")
        }
        .alert(item: $attachmentToDelete) { attachment in
            Alert(
                title: Text("Delete Attachment"),
                message: Text("This will remove the file from this device."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteAttachment(attachment)
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Delete Transaction", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTransaction()
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
    }
    
    // MARK: - Sections
    
    private var amountSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(transaction.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Label(transaction.type.rawValue, systemImage: transaction.type.systemImage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(transaction.type == .income ? "+" : "-")\(transaction.amount.asCurrency(currencyCode: currencyCode))")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(transaction.type == .income ? .green : .red)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            LabeledContent {
                HStack {
                    Image(systemName: transaction.category.systemImage)
                    Text(transaction.category.rawValue)
                }
            } label: {
                Text("Category")
            }
        }
    }
    
    private var dateSection: some View {
        Section("Date") {
            LabeledContent("Transaction Date", value: transaction.date.formatted(style: .long))
            LabeledContent("Added", value: transaction.date.formattedRelative())
        }
    }
    
    private func notesSection(_ notes: String) -> some View {
        Section {
            Text(notes)
                .font(.body)
            
            if !transaction.tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    TagListView(tags: transaction.tags) { tag in
                        print("Tapped tag: \(tag)")
                    }
                }
                .padding(.top, 8)
            }
        } header: {
            Label("Notes", systemImage: "note.text")
        }
    }
    
    private var attachmentsSection: some View {
        Section("Receipts") {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("Add photo", systemImage: "paperclip")
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                
                // Pro Check
                if PurchaseManager.shared.hasPro {
                    Task { await addAttachment(from: newItem) }
                } else {
                    showPaywallSheet = true
                    selectedPhotoItem = nil
                }
            }
            
            if transaction.attachments.isEmpty {
                Text("No attachments yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(transaction.attachments) { attachment in
                    Button {
                        attachmentToPreview = attachment
                    } label: {
                        HStack {
                            Image(systemName: "photo")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Receipt photo")
                                    .lineLimit(1)
                                
                                Text(attachment.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            attachmentToDelete = attachment
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete Transaction", systemImage: "trash")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // MARK: - Methods
    
    @MainActor
    private func addAttachment(from item: PhotosPickerItem) async {
        defer { selectedPhotoItem = nil }
        
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage( data: data) else { return }
            
            let saved = try AttachmentStore.saveJPEG(uiImage)
            let attachment = Attachment(type: .photo, fileName: saved.fileName, relativePath: saved.relativePath)
            attachment.transaction = transaction
            
            transaction.attachments.append(attachment)
            context.insert(attachment)
        } catch {
#if DEBUG
            print("Add attachment failed:", error)
#endif
        }
    }
    
    @MainActor
    private func deleteAttachment(_ attachment: Attachment) {
        do {
            try AttachmentStore.deleteFile(relativePath: attachment.relativePath)
        } catch {
#if DEBUG
            print("Delete file failed:", error)
#endif
        }
        
        if let idx = transaction.attachments.firstIndex(where: { $0.id == attachment.id }) {
            transaction.attachments.remove(at: idx)
        }
        context.delete(attachment)
        attachmentToDelete = nil
    }
    
    private func deleteTransaction() {
        for attachment in transaction.attachments {
            try? AttachmentStore.deleteFile(relativePath: attachment.relativePath)
        }
        
        context.delete(transaction)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(transaction: .preview)
    }
    .modelContainer(previewContainer())
}
