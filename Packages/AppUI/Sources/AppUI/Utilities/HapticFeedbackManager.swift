#if os(iOS)
import UIKit
#endif
import Foundation

/// Manager for haptic feedback interactions
public class HapticFeedbackManager {
    public static let shared = HapticFeedbackManager()
    
    private init() {}
    
    /// Provide light tap feedback
    public func tapFeedback() {
        #if os(iOS)
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        #endif
    }
    
    /// Provide medium tap feedback
    public func mediumTapFeedback() {
        #if os(iOS)
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
        #endif
    }
    
    /// Provide heavy tap feedback
    public func heavyTapFeedback() {
        #if os(iOS)
        let feedback = UIImpactFeedbackGenerator(style: .heavy)
        feedback.impactOccurred()
        #endif
    }
    
    /// Provide success feedback (notification style)
    public func successFeedback() {
        #if os(iOS)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        #endif
    }
    
    /// Provide warning feedback (notification style)
    public func warningFeedback() {
        #if os(iOS)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.warning)
        #endif
    }
    
    /// Provide error feedback (notification style)
    public func errorFeedback() {
        #if os(iOS)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
        #endif
    }
    
    /// Provide selection feedback
    public func selectionFeedback() {
        #if os(iOS)
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
        #endif
    }
}
