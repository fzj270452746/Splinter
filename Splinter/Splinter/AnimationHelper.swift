//
//  AnimationHelper.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class AnimationHelper {
    
    static func animateButtonPress(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = .identity
            }) { _ in
                completion()
            }
        }
    }
    
    static func animateFloatingScore(_ points: Int, at position: CGPoint, in view: UIView) {
        let floatingLabel = UILabel()
        
        if points > 0 {
            floatingLabel.text = "+\(points)"
            floatingLabel.textColor = .yellow
        } else {
            floatingLabel.text = "\(points)"
            floatingLabel.textColor = .red
        }
        
        floatingLabel.font = UIFont.boldSystemFont(ofSize: 28)
        floatingLabel.sizeToFit()
        floatingLabel.center = position
        floatingLabel.layer.shadowColor = UIColor.black.cgColor
        floatingLabel.layer.shadowOpacity = 0.8
        floatingLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        floatingLabel.layer.shadowRadius = 3
        view.addSubview(floatingLabel)
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut) {
            floatingLabel.center.y -= 60
            floatingLabel.alpha = 0
        } completion: { _ in
            floatingLabel.removeFromSuperview()
        }
    }
    
    static func applyShadowEffect(to layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
}

