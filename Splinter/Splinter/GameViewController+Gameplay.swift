//
//  GameViewController+Gameplay.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension GameViewController {
    
    func initiateGameplay() {
        generateMahjong()
        
        gameClock = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.decrementTimer()
        }
        
        spawnClock = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.generateMahjong()
        }
        
        if gameMode == .targeted {
            targetRotationClock = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
                self?.rotateTargetMahjong()
            }
        }
    }
    
    func decrementTimer() {
        remainingDuration -= 1
        timerLabel.text = "\(remainingDuration)s"
        
        if remainingDuration <= 0 {
            concludeGameplay()
        }
    }
    
    func generateMahjong() {
        guard activeMahjongs.count < 5 else { return }
        
        let mahjongWidth: CGFloat = 60
        let mahjongHeight: CGFloat = mahjongWidth * 1.45
        let randomX = CGFloat.random(in: 40...(view.bounds.width - mahjongWidth - 40))
        let randomMahjong = selectRandomMahjong()
        
        let mahjongView = MahjongView(
            mahjongData: randomMahjong,
            frame: CGRect(x: randomX, y: -mahjongHeight - 20, width: mahjongWidth, height: mahjongHeight)
        )
        
        view.insertSubview(mahjongView, belowSubview: sliceTrailView)
        activeMahjongs.append(mahjongView)
        
        let descendDuration = TimeInterval.random(in: 3.5...5.0)
        mahjongView.commenceDescending(to: view.bounds.height + 20, duration: descendDuration) { [weak self] in
            self?.removeMahjong(mahjongView)
        }
    }
    
    func selectRandomMahjong() -> SplinterModel {
        let shouldSpawnPenalty = Int.random(in: 1...100) <= 20
        return shouldSpawnPenalty ? SplinterModel.penaltyTiles.randomElement()! : SplinterModel.allNormalTiles.randomElement()!
    }
    
    func removeMahjong(_ mahjong: MahjongView) {
        activeMahjongs.removeAll { $0 === mahjong }
        mahjong.removeFromSuperview()
    }
    
    func randomizeTargetMahjong() {
        targetMahjongType = Int.random(in: 1...3)
        updateTargetImage()
    }
    
    func rotateTargetMahjong() {
        randomizeTargetMahjong()
        
        UIView.animate(withDuration: 0.2) {
            self.targetDisplayView.alpha = 1
            self.targetDisplayView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.targetDisplayView.transform = .identity
            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 0.3) {
                        self.targetDisplayView.alpha = 0
                    }
                }
            }
        }
    }
    
    func updateTargetImage() {
        let targetMahjongs: [SplinterModel]
        switch targetMahjongType {
        case 1: targetMahjongs = SplinterModel.allTypeTiles
        case 2: targetMahjongs = SplinterModel.ballTypeTiles
        default: targetMahjongs = SplinterModel.callTypeTiles
        }
        targetImageView.image = targetMahjongs.randomElement()?.splinImage
    }
    
    func concludeGameplay() {
        [gameClock, spawnClock, targetRotationClock].forEach { $0?.invalidate() }
        
        let modeText = gameMode == .classic ? "Arcade Mode" : "Target Mode"
        let archive = GameArchive(obtainedScore: accumulatedScore, gameMode: modeText)
        GameArchiveRepository.shared.persistArchive(archive)
        
        exhibitGameOverDialog()
    }
}

