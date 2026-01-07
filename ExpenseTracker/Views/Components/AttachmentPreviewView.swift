//
//  AttachmentPreviewView.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 07.01.26.
//

import SwiftUI
internal import UIKit

struct AttachmentPreviewView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage( data: data) {
                    ScrollView([.vertical, .horizontal]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                } else {
                    ContentUnavailableView("Preview not available", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle("Attachment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
