//
//  Attachment.swift
//  ExpenseTracker
//
//  Created by Manuel Zangl on 07.01.26.
//

import Foundation
import SwiftData

enum AttachmentType: String, Codable {
    case photo
}

@Model
final class Attachment {
    var id: UUID
    var typeRaw: String
    var fileName: String
    var relativePath: String
    var createdAt: Date
    
    @Relationship(inverse: \Transaction.attachments)
    var transaction: Transaction?
    
    init(
        type: AttachmentType,
        fileName: String,
        relativePath: String,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.fileName = fileName
        self.relativePath = relativePath
        self.createdAt = createdAt
    }
    
    var type: AttachmentType { AttachmentType(rawValue: typeRaw) ?? .photo }
}
