//
//  GameViewController+UI.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension GameViewController {
    
    func exhibitGameOverDialog() {
        let dialogView = UIView()
        dialogView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        dialogView.layer.cornerRadius = 20
        dialogView.frame = CGRect(x: 40, y: view.bounds.height / 2 - 120, width: view.bounds.width - 80, height: 240)
        dialogView.alpha = 0
        dialogView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        view.addSubview(dialogView)
        
        addLabel(to: dialogView, text: "Game Over", fontSize: 32, color: .white, frame: CGRect(x: 20, y: 30, width: dialogView.bounds.width - 40, height: 40))
        addLabel(to: dialogView, text: "Final Score: \(accumulatedScore)", fontSize: 24, color: .compatibleCyan, frame: CGRect(x: 20, y: 85, width: dialogView.bounds.width - 40, height: 30))
        
        let closeButton = UIButton()
        closeButton.setTitle("Back to Menu", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closeButton.backgroundColor = UIColor.compatibleCyan
        closeButton.layer.cornerRadius = 12
        closeButton.frame = CGRect(x: 40, y: 150, width: dialogView.bounds.width - 80, height: 50)
        closeButton.addTarget(self, action: #selector(withdrawFromGame), for: .touchUpInside)
        dialogView.addSubview(closeButton)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            dialogView.alpha = 1
            dialogView.transform = .identity
        }
    }
    
    func addLabel(to containerView: UIView, text: String, fontSize: CGFloat, color: UIColor, frame: CGRect) {
        let label = UILabel()
        label.text = text
        label.font = fontSize == 32 ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.textColor = color
        label.textAlignment = .center
        label.frame = frame
        containerView.addSubview(label)
    }
}

