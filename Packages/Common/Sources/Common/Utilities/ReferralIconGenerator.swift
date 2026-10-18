//
//  ReferralIconGenerator.swift
//  Common
//
//  Created on October 18, 2026.
//

import UIKit

public class ReferralIconGenerator {
    /// Generates a professional "TP" icon for the referral share sheet (512x512)
    public static func generateTPIcon() -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Professional blue gradient background
            for y in 0..<Int(size.height) {
                let ratio = CGFloat(y) / size.height
                let red: CGFloat = 0.0
                let green = 0.48 - (ratio * 0.13)
                let blue = 1.0 - (ratio * 0.2)
                
                context.cgContext.setFillColor(UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor)
                context.cgContext.fill(CGRect(x: 0, y: y, width: Int(size.width), height: 1))
            }
            
            // White "TP" text - TURNING POINT
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 200, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let text = "TP"
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    /// Generates a professional referral/share icon (1024x1024)
    public static func generateReferralIcon() -> UIImage {
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background - Professional blue gradient
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            gradientLayer.colors = [
                UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0).cgColor,
                UIColor(red: 0.0, green: 0.35, blue: 0.8, alpha: 1.0).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            
            // Draw gradient background manually
            for y in 0..<Int(size.height) {
                let ratio = CGFloat(y) / size.height
                let red: CGFloat = 0.0
                let green = 0.48 - (ratio * 0.13)
                let blue = 1.0 - (ratio * 0.2)
                
                context.cgContext.setFillColor(UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor)
                context.cgContext.fill(CGRect(x: 0, y: y, width: Int(size.width), height: 1))
            }
            
            // White outer circle
            context.cgContext.setFillColor(UIColor.white.cgColor)
            let outerCircle = UIBezierPath(
                arcCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2 - 50,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            outerCircle.fill()
            
            // Blue inner circle
            context.cgContext.setFillColor(UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0).cgColor)
            let innerCircle = UIBezierPath(
                arcCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2 - 100,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            innerCircle.fill()
            
            // White share arrow/network symbol
            let path = UIBezierPath()
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(60)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            
            // Vertical line upward
            path.move(to: CGPoint(x: size.width / 2, y: 300))
            path.addLine(to: CGPoint(x: size.width / 2, y: 550))
            
            // Arrow branches downward
            path.move(to: CGPoint(x: size.width / 2, y: 550))
            path.addLine(to: CGPoint(x: 300, y: 700))
            
            path.move(to: CGPoint(x: size.width / 2, y: 550))
            path.addLine(to: CGPoint(x: 724, y: 700))
            
            path.stroke()
            
            // Arrow head circles
            context.cgContext.setFillColor(UIColor.white.cgColor)
            let arrowHeadRadius: CGFloat = 40
            
            let leftArrow = UIBezierPath(
                arcCenter: CGPoint(x: 300, y: 700),
                radius: arrowHeadRadius,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            leftArrow.fill()
            
            let rightArrow = UIBezierPath(
                arcCenter: CGPoint(x: 724, y: 700),
                radius: arrowHeadRadius,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            rightArrow.fill()
        }
    }
}
