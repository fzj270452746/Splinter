//
//  FeedbackViewController+Layout.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension FeedbackViewController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForDevice()
    }
    
    func adjustLayoutForDevice() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        
        if isPad {
            applyPadLayout(safeTop: safeTop)
        } else {
            applyPhoneLayout(safeTop: safeTop)
        }
    }
    
    func applyPadLayout(safeTop: CGFloat) {
        let maxWidth: CGFloat = 600
        let horizontalInset = (view.bounds.width - maxWidth) / 2
        
        titleLabel.frame = CGRect(x: horizontalInset, y: safeTop + 20, width: maxWidth, height: 50)
        
        let ratingLabel = view.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "How do you like this game?" } as? UILabel
        ratingLabel?.frame = CGRect(x: horizontalInset, y: safeTop + 90, width: maxWidth, height: 30)
        
        starRatingView.frame = CGRect(x: (view.bounds.width - 300) / 2, y: safeTop + 135, width: 300, height: 60)
        
        let feedbackLabel = view.subviews.first { $0 is UILabel && ($0 as! UILabel).text?.contains("thoughts") == true } as? UILabel
        feedbackLabel?.frame = CGRect(x: horizontalInset + 10, y: safeTop + 220, width: maxWidth - 20, height: 25)
        
        feedbackTextView.frame = CGRect(x: horizontalInset + 10, y: safeTop + 255, width: maxWidth - 20, height: 200)
        placeholderLabel.frame = CGRect(x: horizontalInset + 26, y: safeTop + 267, width: maxWidth - 52, height: 25)
        
        submitButton.frame = CGRect(x: horizontalInset + 10, y: safeTop + 480, width: maxWidth - 20, height: 60)
        
        withdrawButton.frame = CGRect(x: horizontalInset, y: safeTop + 10, width: 55, height: 55)
        withdrawButton.layer.cornerRadius = 27.5
    }
    
    func applyPhoneLayout(safeTop: CGFloat) {
        titleLabel.frame = CGRect(x: 20, y: safeTop + 20, width: view.bounds.width - 40, height: 50)
        
        let ratingLabel = view.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "How do you like this game?" } as? UILabel
        ratingLabel?.frame = CGRect(x: 20, y: safeTop + 90, width: view.bounds.width - 40, height: 30)
        
        starRatingView.frame = CGRect(x: (view.bounds.width - 250) / 2, y: safeTop + 135, width: 250, height: 50)
        
        let feedbackLabel = view.subviews.first { $0 is UILabel && ($0 as! UILabel).text?.contains("thoughts") == true } as? UILabel
        feedbackLabel?.frame = CGRect(x: 30, y: safeTop + 210, width: view.bounds.width - 60, height: 25)
        
        feedbackTextView.frame = CGRect(x: 30, y: safeTop + 245, width: view.bounds.width - 60, height: 180)
        placeholderLabel.frame = CGRect(x: 46, y: safeTop + 257, width: view.bounds.width - 92, height: 25)
        
        submitButton.frame = CGRect(x: 30, y: safeTop + 450, width: view.bounds.width - 60, height: 55)
        
        withdrawButton.frame = CGRect(x: 20, y: safeTop + 10, width: 50, height: 50)
        withdrawButton.layer.cornerRadius = 25
    }
}

