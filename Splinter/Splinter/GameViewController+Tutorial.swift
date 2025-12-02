//
//  GameViewController+Tutorial.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

extension GameViewController {
    
    func exhibitTutorialAnimation() {
        let tutorialOverlay = createTutorialOverlay()
        let components = createTutorialComponents()
        
        addTutorialComponents(components, to: tutorialOverlay)
        
        UIView.animate(withDuration: 0.5) {
            tutorialOverlay.alpha = 1
            components.skipButton.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut) {
                components.mahjong.alpha = 1
                components.instruction.alpha = 1
            } completion: { _ in
                self.performSwipeDemo(components: components)
            }
        }
    }
    
    func createTutorialOverlay() -> UIView {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        overlay.frame = view.bounds
        overlay.alpha = 0
        overlay.tag = 9999
        view.addSubview(overlay)
        return overlay
    }
    
    func createTutorialComponents() -> (mahjong: MahjongView, finger: UILabel, instruction: UILabel, scoreHint: UILabel, trail: SliceTrailView, skipButton: UIButton) {
        let mahjongWidth: CGFloat = 80
        let mahjongHeight: CGFloat = mahjongWidth * 1.45
        
        let mahjong = MahjongView(mahjongData: all5, frame: CGRect(x: (view.bounds.width - mahjongWidth) / 2, y: view.bounds.height / 2 - mahjongHeight / 2, width: mahjongWidth, height: mahjongHeight))
        mahjong.alpha = 0
        
        let finger = UILabel()
        finger.text = "👆"
        finger.font = UIFont.systemFont(ofSize: 60)
        finger.frame = CGRect(x: mahjong.frame.minX - 80, y: mahjong.frame.minY - 30, width: 80, height: 80)
        finger.alpha = 0
        
        let instruction = UILabel()
        instruction.text = "Swipe across the mahjong!"
        instruction.font = UIFont.boldSystemFont(ofSize: 24)
        instruction.textColor = .white
        instruction.textAlignment = .center
        instruction.frame = CGRect(x: 40, y: mahjong.frame.minY - 100, width: view.bounds.width - 80, height: 40)
        instruction.alpha = 0
        
        let scoreHint = UILabel()
        scoreHint.text = "+5"
        scoreHint.font = UIFont.boldSystemFont(ofSize: 36)
        scoreHint.textColor = .yellow
        scoreHint.textAlignment = .center
        AnimationHelper.applyShadowEffect(to: scoreHint.layer)
        scoreHint.layer.shadowOpacity = 0.8
        scoreHint.frame = CGRect(x: (view.bounds.width - 100) / 2, y: mahjong.center.y - 18, width: 100, height: 50)
        scoreHint.alpha = 0
        
        let trail = SliceTrailView(frame: view.bounds)
        trail.alpha = 0
        
        let skipButton = UIButton()
        skipButton.setTitle("Skip Tutorial", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        skipButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        skipButton.layer.cornerRadius = 10
        skipButton.layer.borderWidth = 1
        skipButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        skipButton.frame = CGRect(x: view.bounds.width - 140, y: view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top + 10 : 40, width: 120, height: 40)
        skipButton.alpha = 0
        skipButton.addTarget(self, action: #selector(dismissTutorialAndStart), for: .touchUpInside)
        
        return (mahjong, finger, instruction, scoreHint, trail, skipButton)
    }
    
    func addTutorialComponents(_ components: (mahjong: MahjongView, finger: UILabel, instruction: UILabel, scoreHint: UILabel, trail: SliceTrailView, skipButton: UIButton), to overlay: UIView) {
        overlay.addSubview(components.mahjong)
        overlay.addSubview(components.finger)
        overlay.addSubview(components.instruction)
        overlay.addSubview(components.scoreHint)
        overlay.addSubview(components.trail)
        overlay.addSubview(components.skipButton)
    }
    
    func performSwipeDemo(components: (mahjong: MahjongView, finger: UILabel, instruction: UILabel, scoreHint: UILabel, trail: SliceTrailView, skipButton: UIButton)) {
        let startPoint = CGPoint(x: components.mahjong.frame.minX - 40, y: components.mahjong.center.y)
        let endPoint = CGPoint(x: components.mahjong.frame.maxX + 40, y: components.mahjong.center.y)
        
        UIView.animate(withDuration: 0.3, delay: 0.5) {
            components.finger.alpha = 1
        } completion: { _ in
            components.trail.initiateNewTrail(at: startPoint)
            UIView.animate(withDuration: 0.2) { components.trail.alpha = 1 }
            
            self.animateSwipeStep(step: 0, totalSteps: 20, finger: components.finger, trail: components.trail, from: startPoint, to: endPoint) {
                components.mahjong.triggerShatterAnimation {
                    UIView.animate(withDuration: 0.3) {
                        components.scoreHint.alpha = 1
                    } completion: { _ in
                        UIView.animate(withDuration: 0.8) {
                            components.scoreHint.center.y -= 60
                            components.scoreHint.alpha = 0
                        } completion: { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.dismissTutorialAndStart()
                            }
                        }
                    }
                }
                
                UIView.animate(withDuration: 0.3, delay: 0.2) {
                    components.trail.alpha = 0
                    components.finger.alpha = 0
                }
            }
        }
    }
    
    func animateSwipeStep(step: Int, totalSteps: Int, finger: UILabel, trail: SliceTrailView, from start: CGPoint, to end: CGPoint, onComplete: @escaping () -> Void) {
        guard step <= totalSteps else {
            onComplete()
            return
        }
        
        let progress = CGFloat(step) / CGFloat(totalSteps)
        let current = CGPoint(x: start.x + (end.x - start.x) * progress, y: start.y + (end.y - start.y) * progress)
        
        finger.center = CGPoint(x: current.x + 40, y: current.y - 30)
        trail.appendToTrail(point: current)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            self.animateSwipeStep(step: step + 1, totalSteps: totalSteps, finger: finger, trail: trail, from: start, to: end, onComplete: onComplete)
        }
    }
    
    @objc func dismissTutorialAndStart() {
        UserDefaults.standard.set(true, forKey: "MahjongSplinter_HasSeenTutorial")
        
        if let tutorialOverlay = view.viewWithTag(9999) {
            UIView.animate(withDuration: 0.5) {
                tutorialOverlay.alpha = 0
            } completion: { _ in
                tutorialOverlay.removeFromSuperview()
                self.initiateGameplay()
            }
        } else {
            initiateGameplay()
        }
    }
}

