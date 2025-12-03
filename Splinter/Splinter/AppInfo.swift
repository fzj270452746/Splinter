//
//  AppInfo.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import Foundation

struct AppInfo {
    static let version = "1.0.0"
    static let buildNumber = "1"
    static let appName = "Splinter Mahjong"
    static let developer = "Your Name"
    static let copyright = "© 2025 \(developer). All rights reserved."
    
    static var fullVersion: String {
        return "Version \(version) (Build \(buildNumber))"
    }
}

