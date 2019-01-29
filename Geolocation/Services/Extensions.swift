//
//  Extensions.swift
//  Geolocation
//
//  Created by Matt Johnson on 1/4/19.
//  Copyright © 2018 Matt Johnson. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import BigInt

extension UIViewController {
    
    class func displaySpinner(onView : UIView) -> UIView {
            let spinnerView = UIView.init(frame: onView.bounds)
            spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            let ai = UIActivityIndicatorView.init(style: .whiteLarge)
            ai.startAnimating()
            ai.center = spinnerView.center
            
            DispatchQueue.main.async {
                spinnerView.addSubview(ai)
                onView.addSubview(spinnerView)
            }
            
            return spinnerView
        }
        
    class func removeSpinner(spinner :UIView) {
            DispatchQueue.main.async {
                spinner.removeFromSuperview()
            }
        }
    
    func hideSelectionWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideSelection))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func hideSelection() {
        view.resignFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension MKMapView {
    
    func roundCorners() {
        self.layer.cornerRadius = (self.frame.height / 5)
        self.layer.masksToBounds = true
    }
}
extension UIButton {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.height / 2)
        self.layer.masksToBounds = true
    }
}

extension UIImageView {
    
    func makeSquare() {
        if self.frame.height > self.frame.width {
            self.frame.size = CGSize(width: self.frame.height, height: self.frame.height)
        }
        else{
            self.frame.size = CGSize(width: self.frame.width, height: self.frame.width)
        }
    }
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.height / 2)
        self.layer.masksToBounds = true
    }
    
}



extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    private var seconds: Int {
        return Int(self) % 60
    }
    
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    private var hours: Int {
        return Int(self) / 3600
    }
    
    var stringTime: String {
        if hours != 0 {
            return "\(hours)h \(minutes)m"// \(seconds)s"
        } else if minutes != 0 {
            return "\(minutes)m"// \(seconds)s"
        } else if milliseconds != 0 {
            return "\(seconds)s"// \(milliseconds)ms"
        } else {
            return "\(seconds)s"
        }
    }
}
extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    func localizedDescription(dateStyle: DateFormatter.Style = .medium,
                              timeStyle: DateFormatter.Style = .medium,
                              in timeZone : TimeZone = .current,
                              locale   : Locale = .current) -> String {
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }
    var localizedDescription: String { return localizedDescription() }
}

extension UIToolbar {
    
    func ToolbarPicker(select : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: select)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}

extension UIColor {
    
    static func gold() -> UIColor {
        return UIColor(red:0.79, green:0.62, blue:0.40, alpha:1.0)
    }

}

extension Double {
    
    /*
     decimal  degrees    distance
     places
     -------------------------------
     0        1.0        111 km
     1        0.1        11.1 km
     2        0.01       1.11 km
     3        0.001      111 m
     4        0.0001     11.1 m
     5        0.00001    1.11 m
     6        0.000001   0.111 m
     7        0.0000001  1.11 cm
     8        0.00000001 1.11 mm
     */
    func convertCoordinate(toDecimals decimals:Int) -> BigInt {
        let divisor = pow(10.0, Double(decimals))
        return BigInt((self * divisor).rounded())
    }
    
    func roundCoordinate(toDecimals decimals:Int) -> Double {
        let divisor = pow(10.0, Double(decimals))
        return (self * divisor).rounded() / divisor
    }
}
