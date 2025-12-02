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
        adjustLayoutForOrientation()
    }
    
    func adjustLayoutForOrientation() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let isLandscape = view.bounds.width > view.bounds.height
        
        if isPad {
            applyPadLayout(isLandscape: isLandscape)
        } else {
            applyPhoneLayout(isLandscape: isLandscape)
        }
    }
    
    func applyPadLayout(isLandscape: Bool) {
        let config = LayoutConfig(buttonWidth: isLandscape ? 450 : 500, buttonHeight: 75, utilityHeight: 60, startY: (isLandscape ? view.bounds.height * 0.25 : view.bounds.height * 0.30) - 50, spacing: 20)
        applyLayout(config)
        
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        tutorialResetButton.frame = CGRect(x: view.bounds.width - 70, y: safeTop + 10, width: 50, height: 50)
        tutorialResetButton.layer.cornerRadius = 25
    }
    
    func applyPhoneLayout(isLandscape: Bool) {
        let config = LayoutConfig(buttonWidth: min(view.bounds.width - 80, 400), buttonHeight: isLandscape ? 65 : 70, utilityHeight: isLandscape ? 50 : 55, startY: (isLandscape ? view.bounds.height * 0.15 : view.bounds.height * 0.35) - 50, spacing: isLandscape ? 15 : 18)
        applyLayout(config)
        
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        tutorialResetButton.frame = CGRect(x: view.bounds.width - 60, y: safeTop + 10, width: 40, height: 40)
        tutorialResetButton.layer.cornerRadius = 20
    }
    
    func applyLayout(_ config: LayoutConfig) {
        let baseY = config.startY
        let mainButtonSpacing = config.buttonHeight + config.spacing
        let utilityStartY = baseY + mainButtonSpacing * 2 + 10
        let utilitySpacing = config.utilityHeight + config.spacing - 5
        
        repositionButton(modeOneButton, width: config.buttonWidth, height: config.buttonHeight, yPosition: baseY)
        repositionButton(modeTwoButton, width: config.buttonWidth, height: config.buttonHeight, yPosition: baseY + mainButtonSpacing)
        repositionButton(recordsButton, width: config.buttonWidth, height: config.utilityHeight, yPosition: utilityStartY)
        repositionButton(instructionsButton, width: config.buttonWidth, height: config.utilityHeight, yPosition: utilityStartY + utilitySpacing)
        repositionButton(feedbackButton, width: config.buttonWidth, height: config.utilityHeight, yPosition: utilityStartY + utilitySpacing * 2)
        repositionButton(aboutButton, width: config.buttonWidth, height: config.utilityHeight, yPosition: utilityStartY + utilitySpacing * 3)
    }
    
    func repositionButton(_ button: UIButton, width: CGFloat, height: CGFloat, yPosition: CGFloat) {
        button.frame = CGRect(x: (view.bounds.width - width) / 2, y: yPosition, width: width, height: height)
        
        if let gradientLayer = button.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = button.bounds
        }
    }
    
    struct LayoutConfig {
        let buttonWidth: CGFloat
        let buttonHeight: CGFloat
        let utilityHeight: CGFloat
        let startY: CGFloat
        let spacing: CGFloat
    }
}

