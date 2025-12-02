//
//  InstructionsViewController+Layout.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension InstructionsViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForCurrentDevice()
    }
    
    func adjustLayoutForCurrentDevice() {
        backgroundImageView.frame = view.bounds
        overlayView.frame = view.bounds
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        let safeBottom = view.safeAreaInsets.bottom > 0 ? view.safeAreaInsets.bottom : 20
        
        if isPad {
            configurePadLayout(safeTop: safeTop, safeBottom: safeBottom)
        } else {
            configurePhoneLayout(safeTop: safeTop, safeBottom: safeBottom)
        }
        
        // 重新计算内容高度
        recalculateContentHeight()
    }
    
    func configurePadLayout(safeTop: CGFloat, safeBottom: CGFloat) {
        let maxWidth: CGFloat = 700
        let horizontalInset = (view.bounds.width - maxWidth) / 2
        
        scrollView.frame = CGRect(
            x: horizontalInset,
            y: safeTop + 20,
            width: maxWidth,
            height: view.bounds.height - safeTop - safeBottom - 120
        )
        
        contentView.frame.size.width = maxWidth
        
        withdrawButton.frame = CGRect(
            x: (view.bounds.width - 180) / 2,
            y: view.bounds.height - safeBottom - 80,
            width: 180,
            height: 55
        )
    }
    
    func configurePhoneLayout(safeTop: CGFloat, safeBottom: CGFloat) {
        scrollView.frame = CGRect(
            x: 20,
            y: safeTop + 20,
            width: view.bounds.width - 40,
            height: view.bounds.height - safeTop - safeBottom - 120
        )
        
        contentView.frame.size.width = view.bounds.width - 40
        
        withdrawButton.frame = CGRect(
            x: (view.bounds.width - 150) / 2,
            y: view.bounds.height - safeBottom - 70,
            width: 150,
            height: 50
        )
    }
    
    func recalculateContentHeight() {
        var maxY: CGFloat = 0
        for subview in contentView.subviews {
            let bottom = subview.frame.maxY
            if bottom > maxY {
                maxY = bottom
            }
        }
        contentView.frame.size.height = maxY + 20
        scrollView.contentSize = contentView.frame.size
    }
}

