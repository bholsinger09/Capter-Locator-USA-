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
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter.outputImage else {
            return nil
        }
        
        // Scale up the image
        let transform = CGAffineTransform(scaleX: size.width / ciImage.extent.size.width,
                                         y: size.height / ciImage.extent.size.height)
        let scaledImage = ciImage.transformed(by: transform)
        
        return UIImage(ciImage: scaledImage)
    }
    
    public static func generateReferralLink(for userId: UUID) -> String {
        // Format: tpusa-finder://join?referrer=USER_ID
        "tpusa-finder://join?referrer=\(userId.uuidString)"
    }
    
    public static func generateChapterReferralLink(for userId: UUID, chapterId: UUID) -> String {
        // Format: tpusa-finder://join?referrer=USER_ID&chapter=CHAPTER_ID
        "tpusa-finder://join?referrer=\(userId.uuidString)&chapter=\(chapterId.uuidString)"
    }
}
