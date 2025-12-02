//
//  UIColor+Extensions.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension UIColor {
    
    // iOS 14 兼容的系统颜色
    static var compatibleCyan: UIColor {
        if #available(iOS 15.0, *) {
            return .systemCyan
        } else {
            return UIColor(red: 0.20, green: 0.78, blue: 0.93, alpha: 1.0)
        }
    }
    
    static var compatiblePurple: UIColor {
        if #available(iOS 15.0, *) {
            return .systemPurple
        } else {
            return UIColor(red: 0.69, green: 0.32, blue: 0.87, alpha: 1.0)
        }
    }
    
    static var compatiblePink: UIColor {
        if #available(iOS 15.0, *) {
            return .systemPink
        } else {
            return UIColor(red: 1.0, green: 0.18, blue: 0.33, alpha: 1.0)
        }
    }
}

