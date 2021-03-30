 
 
 import Foundation
 import UIKit
 extension UIView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
 }
 
 
 extension UIView {
    
    public enum FillingMode {
        case full(padding:Int = 0)
        case aspectFit(ratio:CGFloat)
        // case aspectFill ...
    }
    
    public func addSubview(_ newView:UIView, withFillingMode fillingMode:FillingMode) {
        newView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newView)
        
        switch fillingMode {
        case let .full(padding):
            let cgPadding = CGFloat(padding)
            
            NSLayoutConstraint.activate([
                newView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: cgPadding),
                newView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -cgPadding),
                newView.topAnchor.constraint(equalTo: topAnchor, constant: cgPadding),
                newView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -cgPadding)
            ])
        case let .aspectFit(ratio):
            guard ratio != 0 else { return }
            
            NSLayoutConstraint.activate([
                newView.centerXAnchor.constraint(equalTo: centerXAnchor),
                newView.centerYAnchor.constraint(equalTo: centerYAnchor),
                
                newView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
                newView.leadingAnchor.constraint(equalTo: leadingAnchor).usingPriority(900),
                
                newView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
                newView.trailingAnchor.constraint(equalTo: trailingAnchor).usingPriority(900),
                
                newView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                newView.topAnchor.constraint(equalTo: topAnchor).usingPriority(900),
                
                newView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
                newView.bottomAnchor.constraint(equalTo: bottomAnchor).usingPriority(900),
                
                newView.heightAnchor.constraint(equalTo: newView.widthAnchor, multiplier: CGFloat(ratio)),
            ])
        }
    }
 }
 
 extension NSLayoutConstraint {
    /// Returns the constraint sender with the passed priority.
    ///
    /// - Parameter priority: The priority to be set.
    /// - Returns: The sended constraint adjusted with the new priority.
    func usingPriority(_ priority: Int) -> NSLayoutConstraint {
        self.priority = UILayoutPriority( (1...1000 ~= priority) ? Float(priority) : 1000 )
        return self
    }
 }
