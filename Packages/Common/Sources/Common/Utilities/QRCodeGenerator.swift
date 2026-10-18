//
//  QRCodeGenerator.swift
//  Common
//
//  Created on October 18, 2026.
//

import Foundation
import CoreImage
import UIKit

public class QRCodeGenerator {
    public static func generateQRCode(from string: String, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let data = string.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            print("DEBUG QRCodeGenerator: CIQRCodeGenerator filter failed")
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter.outputImage else {
            print("DEBUG QRCodeGenerator: outputImage is nil")
            return nil
        }
        
        // Scale up the image
        let transform = CGAffineTransform(scaleX: size.width / ciImage.extent.size.width,
                                         y: size.height / ciImage.extent.size.height)
        let scaledImage = ciImage.transformed(by: transform)
        
        // Convert CIImage to CGImage and then to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            print("DEBUG QRCodeGenerator: createCGImage failed")
            return nil
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        print("DEBUG QRCodeGenerator: Successfully created QR code image")
        return uiImage
    }
    
    public static func generateReferralLink(for userId: UUID) -> String {
        // Format: Link that opens App Store for ChapterFinderUSA
        // App ID: 6755359527
        "https://apps.apple.com/app/id6755359527?referrer=\(userId.uuidString)"
    }
    
    public static func generateChapterReferralLink(for userId: UUID, chapterId: UUID) -> String {
        // Format: Link with referrer and chapter info
        "https://apps.apple.com/app/id6755359527?referrer=\(userId.uuidString)&chapter=\(chapterId.uuidString)"
    }
}
