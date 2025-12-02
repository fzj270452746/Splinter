//
//  MainMenuViewController+Layout.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension MainMenuViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForCurrentOrientation()
    }
    
    func adjustLayoutForCurrentOrientation() {
        backgroundImageView.frame = view.bounds
        overlayView.frame = view.bounds
        
        let isLandscape = view.bounds.width > view.bounds.height
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        if isPad {
            configureLayoutForPad(isLandscape: isLandscape)
        } else {
            configureLayoutForPhone(isLandscape: isLandscape)
        }
    }
    
    func configureLayoutForPad(isLandscape: Bool) {
        let buttonWidth: CGFloat = isLandscape ? 450 : 500
        let buttonHeight: CGFloat = 75  // 统一高度
        let utilityHeight: CGFloat = 60
        
        let startY = isLandscape ? view.bounds.height * 0.25 : view.bounds.height * 0.30
        let spacing: CGFloat = 20
        
        repositionButton(modeOneButton, width: buttonWidth, height: buttonHeight, yPosition: startY)
        repositionButton(modeTwoButton, width: buttonWidth, height: buttonHeight, yPosition: startY + buttonHeight + spacing)
        repositionButton(recordsButton, width: buttonWidth, height: utilityHeight, yPosition: startY + (buttonHeight + spacing) * 2 + 15)
        repositionButton(instructionsButton, width: buttonWidth, height: utilityHeight, yPosition: startY + (buttonHeight + spacing) * 2 + utilityHeight + spacing + 20)
        
        // 重置教程按钮
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        tutorialResetButton.frame = CGRect(x: view.bounds.width - 70, y: safeTop + 10, width: 50, height: 50)
        tutorialResetButton.layer.cornerRadius = 25
    }
    
    func configureLayoutForPhone(isLandscape: Bool) {
        let buttonWidth: CGFloat = min(view.bounds.width - 80, 400)
        let buttonHeight: CGFloat = isLandscape ? 65 : 70  // 统一缩小
        let utilityHeight: CGFloat = isLandscape ? 50 : 55
        
        let startY = isLandscape ? view.bounds.height * 0.15 : view.bounds.height * 0.35
        let spacing: CGFloat = isLandscape ? 15 : 18
        
        repositionButton(modeOneButton, width: buttonWidth, height: buttonHeight, yPosition: startY)
        repositionButton(modeTwoButton, width: buttonWidth, height: buttonHeight, yPosition: startY + buttonHeight + spacing)
        repositionButton(recordsButton, width: buttonWidth, height: utilityHeight, yPosition: startY + (buttonHeight + spacing) * 2 + 12)
        repositionButton(instructionsButton, width: buttonWidth, height: utilityHeight, yPosition: startY + (buttonHeight + spacing) * 2 + utilityHeight + spacing + 17)
        
        // 重置教程按钮
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        tutorialResetButton.frame = CGRect(x: view.bounds.width - 60, y: safeTop + 10, width: 40, height: 40)
        tutorialResetButton.layer.cornerRadius = 20
    }
    
    func repositionButton(_ button: UIButton, width: CGFloat, height: CGFloat, yPosition: CGFloat) {
        button.frame = CGRect(
            x: (view.bounds.width - width) / 2,
            y: yPosition,
            width: width,
            height: height
        )
        
        // 更新渐变层大小
        if let gradientLayer = button.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = button.bounds
        }
    }
}

