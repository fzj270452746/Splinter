//
//  GameViewController+Touch.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension GameViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: sliceTrailView)
        sliceTrailView.initiateNewTrail(at: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: sliceTrailView)
        sliceTrailView.appendToTrail(point: location)
        evaluateSliceCollisions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sliceTrailView.animateFadeOut { }
    }
    
    func evaluateSliceCollisions() {
        for mahjong in activeMahjongs where !mahjong.isSliced {
            if sliceTrailView.detectIntersection(with: mahjong) {
                mahjong.isSliced = true
                processMahjongSlice(mahjong)
            }
        }
    }
    
    func processMahjongSlice(_ mahjong: MahjongView) {
        removeMahjong(mahjong)
        
        let isPenaltyTile = mahjong.mahjongData.splinInt < 0
        var pointsAwarded = 0
        
        switch gameMode {
        case .classic:
            pointsAwarded = mahjong.mahjongData.splinInt
            
        case .targeted:
            if isPenaltyTile {
                pointsAwarded = mahjong.mahjongData.splinInt
            } else {
                let currentType = determineMahjongType(mahjong: mahjong.mahjongData)
                pointsAwarded = currentType == targetMahjongType ? mahjong.mahjongData.splinInt : -1
            }
        }
        
        accumulatedScore = max(0, accumulatedScore + pointsAwarded)
        scoreLabel.text = "Score: \(accumulatedScore)"
        AnimationHelper.animateFloatingScore(pointsAwarded, at: mahjong.center, in: view)
        mahjong.triggerShatterAnimation { }
    }
    
    func determineMahjongType(mahjong: SplinterModel) -> Int {
        if SplinterModel.allTypeTiles.contains(where: { $0.splinImage === mahjong.splinImage }) { return 1 }
        if SplinterModel.ballTypeTiles.contains(where: { $0.splinImage === mahjong.splinImage }) { return 2 }
        return 3
    }
}

