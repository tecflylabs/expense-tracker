//
//  AttachmentStore.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 07.01.26.
//

import Foundation
internal import UIKit

enum AttachmentStoreError: Error {
    case jpegEncodingFailed
}

struct AttachmentStore {
    static func attachmentsDirectoryURL() throws -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Attachments", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    static func saveJPEG(_ image: UIImage, compression: CGFloat = 0.85) throws -> (fileName: String, relativePath: String, url: URL) {
        guard let data = image.jpegData(compressionQuality: compression) else {
            throw AttachmentStoreError.jpegEncodingFailed
        }
        
        let fileName = "photo-\(UUID().uuidString).jpg"
        let dir = try attachmentsDirectoryURL()
        let url = dir.appendingPathComponent(fileName)
        
        try data.write(to: url, options: [.atomic])
        return (fileName, "Attachments/\(fileName)", url)
    }
    
    static func resolveURL(relativePath: String) -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent(relativePath)
    }
    
    static func deleteFile(relativePath: String) throws {
        let url = resolveURL(relativePath: relativePath)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
