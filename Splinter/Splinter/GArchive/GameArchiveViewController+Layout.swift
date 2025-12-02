//
//  GameArchiveViewController+Layout.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension GameArchiveViewController {
    
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
    }
    
    func configurePadLayout(safeTop: CGFloat, safeBottom: CGFloat) {
        let maxWidth: CGFloat = 700
        let horizontalInset = (view.bounds.width - maxWidth) / 2
        
        titleLabel.frame = CGRect(
            x: horizontalInset,
            y: safeTop + 20,
            width: maxWidth,
            height: 50
        )
        
        tableView.frame = CGRect(
            x: horizontalInset,
            y: safeTop + 90,
            width: maxWidth,
            height: view.bounds.height - safeTop - safeBottom - 280
        )
        
        emptyStateLabel.frame = tableView.frame
        
        obliterateAllButton.frame = CGRect(
            x: horizontalInset,
            y: view.bounds.height - safeBottom - 160,
            width: maxWidth,
            height: 55
        )
        
        withdrawButton.frame = CGRect(
            x: horizontalInset,
            y: view.bounds.height - safeBottom - 90,
            width: 150,
            height: 55
        )
    }
    
    func configurePhoneLayout(safeTop: CGFloat, safeBottom: CGFloat) {
        titleLabel.frame = CGRect(
            x: 20,
            y: safeTop + 10,
            width: view.bounds.width - 40,
            height: 50
        )
        
        tableView.frame = CGRect(
            x: 20,
            y: safeTop + 80,
            width: view.bounds.width - 40,
            height: view.bounds.height - safeTop - safeBottom - 250
        )
        
        emptyStateLabel.frame = tableView.frame
        
        obliterateAllButton.frame = CGRect(
            x: 20,
            y: view.bounds.height - safeBottom - 150,
            width: view.bounds.width - 40,
            height: 50
        )
        
        withdrawButton.frame = CGRect(
            x: 20,
            y: view.bounds.height - safeBottom - 85,
            width: 120,
            height: 50
        )
    }
}

