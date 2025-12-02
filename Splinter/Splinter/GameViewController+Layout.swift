//
//  GameViewController+Layout.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension GameViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sliceTrailView.frame = view.bounds
        adjustLayoutForCurrentDevice()
    }
    
    func adjustLayoutForCurrentDevice() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        
        if isPad {
            configurePadLayout(safeTop: safeTop)
        } else {
            configurePhoneLayout(safeTop: safeTop)
        }
    }
    
    func configurePadLayout(safeTop: CGFloat) {
        withdrawButton.frame = CGRect(x: 30, y: safeTop + 15, width: 55, height: 55)
        withdrawButton.layer.cornerRadius = 27.5
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        
        scoreLabel.frame = CGRect(x: 110, y: safeTop + 20, width: 200, height: 50)
        timerLabel.frame = CGRect(x: view.bounds.width - 240, y: safeTop + 20, width: 200, height: 50)
        
        if gameMode == .targeted {
            let displaySize: CGFloat = 65
            targetDisplayView.frame = CGRect(x: (view.bounds.width - displaySize) / 2, y: safeTop + 15, width: displaySize, height: displaySize * 1.45)
            targetImageView.frame = targetDisplayView.bounds
            targetHintLabel.frame = CGRect(x: (view.bounds.width - 220) / 2, y: targetDisplayView.frame.maxY + 12, width: 220, height: 40)
        }
    }
    
    func configurePhoneLayout(safeTop: CGFloat) {
        withdrawButton.frame = CGRect(x: 20, y: safeTop + 10, width: 50, height: 50)
        withdrawButton.layer.cornerRadius = 25
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        scoreLabel.frame = CGRect(x: 90, y: safeTop + 15, width: 150, height: 40)
        timerLabel.frame = CGRect(x: view.bounds.width - 160, y: safeTop + 15, width: 140, height: 40)
        
        if gameMode == .targeted {
            let displaySize: CGFloat = 55
            targetDisplayView.frame = CGRect(x: (view.bounds.width - displaySize) / 2, y: safeTop + 10, width: displaySize, height: displaySize * 1.45)
            targetImageView.frame = targetDisplayView.bounds
            targetHintLabel.frame = CGRect(x: (view.bounds.width - 220) / 2, y: targetDisplayView.frame.maxY + 10, width: 220, height: 32)
        }
    }
}

