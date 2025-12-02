//
//  SplinterModel.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit


struct SplinterModel {
    var splinImage: UIImage
    var splinInt: Int //麻将的值，即大小
}

// 切中会减分的特殊麻将（炸弹）
let penaltyTile1 = SplinterModel(splinImage: UIImage(named: "ot 1")!, splinInt: -5)
let penaltyTile2 = SplinterModel(splinImage: UIImage(named: "ot 2")!, splinInt: -3)
let penaltyTile3 = SplinterModel(splinImage: UIImage(named: "ot 3")!, splinInt: -2)


let all1 = SplinterModel(splinImage: UIImage(named: "all 1")!, splinInt: 1)
let all2 = SplinterModel(splinImage: UIImage(named: "all 2")!, splinInt: 2)
let all3 = SplinterModel(splinImage: UIImage(named: "all 3")!, splinInt: 3)
let all4 = SplinterModel(splinImage: UIImage(named: "all 4")!, splinInt: 4)
let all5 = SplinterModel(splinImage: UIImage(named: "all 5")!, splinInt: 5)
let all6 = SplinterModel(splinImage: UIImage(named: "all 6")!, splinInt: 6)
let all7 = SplinterModel(splinImage: UIImage(named: "all 7")!, splinInt: 7)
let all8 = SplinterModel(splinImage: UIImage(named: "all 8")!, splinInt: 8)
let all9 = SplinterModel(splinImage: UIImage(named: "all 9")!, splinInt: 9)



let bll1 = SplinterModel(splinImage: UIImage(named: "ball 1")!, splinInt: 1)
let bll2 = SplinterModel(splinImage: UIImage(named: "ball 2")!, splinInt: 2)
let bll3 = SplinterModel(splinImage: UIImage(named: "ball 3")!, splinInt: 3)
let bll4 = SplinterModel(splinImage: UIImage(named: "ball 4")!, splinInt: 4)
let bll5 = SplinterModel(splinImage: UIImage(named: "ball 5")!, splinInt: 5)
let bll6 = SplinterModel(splinImage: UIImage(named: "ball 6")!, splinInt: 6)
let bll7 = SplinterModel(splinImage: UIImage(named: "ball 7")!, splinInt: 7)
let bll8 = SplinterModel(splinImage: UIImage(named: "ball 8")!, splinInt: 8)
let bll9 = SplinterModel(splinImage: UIImage(named: "ball 9")!, splinInt: 9)


let cll1 = SplinterModel(splinImage: UIImage(named: "call 1")!, splinInt: 1)
let cll2 = SplinterModel(splinImage: UIImage(named: "call 2")!, splinInt: 2)
let cll3 = SplinterModel(splinImage: UIImage(named: "call 3")!, splinInt: 3)
let cll4 = SplinterModel(splinImage: UIImage(named: "call 4")!, splinInt: 4)
let cll5 = SplinterModel(splinImage: UIImage(named: "call 5")!, splinInt: 5)
let cll6 = SplinterModel(splinImage: UIImage(named: "call 6")!, splinInt: 6)
let cll7 = SplinterModel(splinImage: UIImage(named: "call 7")!, splinInt: 7)
let cll8 = SplinterModel(splinImage: UIImage(named: "call 8")!, splinInt: 8)
let cll9 = SplinterModel(splinImage: UIImage(named: "call 9")!, splinInt: 9)


// MARK: - iOS 14 兼容的颜色扩展
extension UIColor {
    
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
