//
//  ExportManager.swift
//  PennyFlow
//
//  Created by Manuel Zangl on 03.01.26.
//

import Foundation
import PDFKit
import SwiftUI

class ExportManager {
    static let shared = ExportManager()
    
    @AppStorage("currencyCode") private var currencyCode: String = "EUR"
    
    private init() {}
    
    // MARK: - CSV Export
    
    func generateCSV(transactions: [Transaction]) -> URL? {
        var csvString = "Date,Title,Category,Type,Amount,Notes\n"
        
        for transaction in transactions.sorted(by: { $0.date > $1.date }) {
            let date = transaction.date.formatted(style: .short)
            let title = transaction.title.replacingOccurrences(of: ",", with: ";")
            let category = transaction.category.rawValue
            let type = transaction.type.rawValue
            let amount = String(format: "%.2f", transaction.amount)
            let notes = (transaction.notes ?? "").replacingOccurrences(of: ",", with: ";")
            
            csvString += "\(date),\(title),\(category),\(type),\(amount),\(notes)\n"
        }
        
        let fileName = "PennyFlow_\(Date().ISO8601Format()).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Failed to create CSV file: \(error)")
            return nil
        }
    }
    
    // MARK: - PDF Export
    
    func generatePDF(
        transactions: [Transaction],
        totalIncome: Double,
        totalExpense: Double,
        balance: Double
    ) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "PennyFlow",
            kCGPDFContextAuthor: "PennyFlow App",
            kCGPDFContextTitle: "Financial Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0  // A4 width in points
        let pageHeight = 11 * 72.0  // A4 height in points
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var currentY: CGFloat = 60
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.label
            ]
            let title = "Financial Report"
            title.draw(at: CGPoint(x: 60, y: currentY), withAttributes: titleAttributes)
            currentY += 40
            
            // Date Range
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let dateString = "Generated on \(Date().formatted(date: .long, time: .shortened))"
            dateString.draw(at: CGPoint(x: 60, y: currentY), withAttributes: dateAttributes)
            currentY += 40
            
            // Summary Box
            drawSummaryBox(
                at: CGPoint(x: 60, y: currentY),
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                balance: balance
            )
            currentY += 120
            
            // Transactions Header
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ]
            "Transactions".draw(at: CGPoint(x: 60, y: currentY), withAttributes: headerAttributes)
            currentY += 30
            
            // Transactions List
            let transactionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.label
            ]
            
            for transaction in transactions.sorted(by: { $0.date > $1.date }).prefix(50) {
                if currentY > pageHeight - 100 {
                    context.beginPage()
                    currentY = 60
                }
                
                let dateStr = transaction.date.formatted(style: .short)
                let amountStr = transaction.amount.asCurrency(currencyCode: currencyCode)
                let typeSymbol = transaction.type == .income ? "+" : "-"
                
                let line = "\(dateStr)  \(transaction.title)  \(typeSymbol)\(amountStr)"
                line.draw(at: CGPoint(x: 60, y: currentY), withAttributes: transactionAttributes)
                currentY += 20
            }
        }
        
        let fileName = "PennyFlowReport_\(Date().ISO8601Format()).pdf"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: path)
            return path
        } catch {
            print("Failed to create PDF file: \(error)")
            return nil
        }
    }
    
    private func drawSummaryBox(
        at origin: CGPoint,
        totalIncome: Double,
        totalExpense: Double,
        balance: Double
    ) {
        let boxRect = CGRect(x: origin.x, y: origin.y, width: 480, height: 100)
        
        // Background
        UIColor.systemGray6.setFill()
        UIBezierPath(roundedRect: boxRect, cornerRadius: 12).fill()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label
        ]
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.label
        ]
        
        // Income
        "Total Income".draw(at: CGPoint(x: origin.x + 20, y: origin.y + 20), withAttributes: attributes)
        totalIncome.asCurrency(currencyCode: currencyCode).draw(at: CGPoint(x: origin.x + 20, y: origin.y + 40), withAttributes: boldAttributes)
        
        // Expense
        "Total Expense".draw(at: CGPoint(x: origin.x + 180, y: origin.y + 20), withAttributes: attributes)
        totalExpense.asCurrency(currencyCode: currencyCode).draw(at: CGPoint(x: origin.x + 180, y: origin.y + 40), withAttributes: boldAttributes)
        
        // Balance
        "Balance".draw(at: CGPoint(x: origin.x + 340, y: origin.y + 20), withAttributes: attributes)
        balance.asCurrency(currencyCode: currencyCode).draw(at: CGPoint(x: origin.x + 340, y: origin.y + 40), withAttributes: boldAttributes)
    }
}

