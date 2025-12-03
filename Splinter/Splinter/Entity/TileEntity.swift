//
//  TileEntity.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

struct TileEntity {
    let splinImage: UIImage
    let splinInt: Int
    
    enum TileType: String {
        case all, ball, call, penalty
        
        var imageName: String {
            switch self {
            case .all: return "all"
            case .ball: return "ball"
            case .call: return "call"
            case .penalty: return "ot"
            }
        }
    }
    
    static func createTile(type: TileType, value: Int) -> TileEntity {
        let imageName = type == .penalty ? "\(type.imageName) \(abs(value / 2))" : "\(type.imageName) \(value)"
        return TileEntity(splinImage: UIImage(named: imageName)!, splinInt: value)
    }
    
    static let allTypeTiles: [TileEntity] = (1...9).map { createTile(type: .all, value: $0) }
    static let ballTypeTiles: [TileEntity] = (1...9).map { createTile(type: .ball, value: $0) }
    static let callTypeTiles: [TileEntity] = (1...9).map { createTile(type: .call, value: $0) }
    
    static let penaltyTiles: [TileEntity] = [
        createTile(type: .penalty, value: -5),
        createTile(type: .penalty, value: -3),
        createTile(type: .penalty, value: -2)
    ]
    
    static let allNormalTiles: [TileEntity] = allTypeTiles + ballTypeTiles + callTypeTiles
}

// MARK: - Backward Compatibility
let all1 = TileEntity.allTypeTiles[0]
let all2 = TileEntity.allTypeTiles[1]
let all3 = TileEntity.allTypeTiles[2]
let all4 = TileEntity.allTypeTiles[3]
let all5 = TileEntity.allTypeTiles[4]
let all6 = TileEntity.allTypeTiles[5]
let all7 = TileEntity.allTypeTiles[6]
let all8 = TileEntity.allTypeTiles[7]
let all9 = TileEntity.allTypeTiles[8]

let bll1 = TileEntity.ballTypeTiles[0]
let bll2 = TileEntity.ballTypeTiles[1]
let bll3 = TileEntity.ballTypeTiles[2]
let bll4 = TileEntity.ballTypeTiles[3]
let bll5 = TileEntity.ballTypeTiles[4]
let bll6 = TileEntity.ballTypeTiles[5]
let bll7 = TileEntity.ballTypeTiles[6]
let bll8 = TileEntity.ballTypeTiles[7]
let bll9 = TileEntity.ballTypeTiles[8]

let cll1 = TileEntity.callTypeTiles[0]
let cll2 = TileEntity.callTypeTiles[1]
let cll3 = TileEntity.callTypeTiles[2]
let cll4 = TileEntity.callTypeTiles[3]
let cll5 = TileEntity.callTypeTiles[4]
let cll6 = TileEntity.callTypeTiles[5]
let cll7 = TileEntity.callTypeTiles[6]
let cll8 = TileEntity.callTypeTiles[7]
let cll9 = TileEntity.callTypeTiles[8]

let penaltyTile1 = TileEntity.penaltyTiles[0]
let penaltyTile2 = TileEntity.penaltyTiles[1]
let penaltyTile3 = TileEntity.penaltyTiles[2]
