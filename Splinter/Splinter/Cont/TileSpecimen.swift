//
//  TileSpecimen.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class TileSpecimen: UIView {
    
    let mahjongData: TileEntity
    let imageView: UIImageView
    var isSliced = false
    
    init(mahjongData: TileEntity, frame: CGRect) {
        self.mahjongData = mahjongData
        self.imageView = UIImageView(image: mahjongData.splinImage)
        
        super.init(frame: frame)
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance() {
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        layer.cornerRadius = 6
        clipsToBounds = true
        
        // 只有普通麻将才有边框
        if mahjongData.splinInt >= 0 {
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        }
        
        KineticOrchestrator.applyShadowEffect(to: layer)
    }
    
    func commenceBouncingAndDescending(topY: CGFloat, bottomY: CGFloat, totalDuration: TimeInterval, completion: @escaping () -> Void) {
        let startY = self.frame.origin.y
        let startTime = CACurrentMediaTime()
        let bounceUpDuration = totalDuration * 0.35
        let bounceEndTime = startTime + bounceUpDuration
        let endTime = startTime + totalDuration
        
        let displayLink = CADisplayLink(target: self, selector: #selector(updateBouncingPosition))
        displayLink.add(to: .main, forMode: .common)
        
        layer.setValue(startY, forKey: "startY")
        layer.setValue(topY, forKey: "topY")
        layer.setValue(bottomY, forKey: "bottomY")
        layer.setValue(startTime, forKey: "startTime")
        layer.setValue(bounceEndTime, forKey: "bounceEndTime")
        layer.setValue(endTime, forKey: "endTime")
        layer.setValue(displayLink, forKey: "displayLink")
        layer.setValue(completion, forKey: "completion")
    }
    
    @objc func updateBouncingPosition() {
        guard let displayLink = layer.value(forKey: "displayLink") as? CADisplayLink,
              let startY = layer.value(forKey: "startY") as? CGFloat,
              let topY = layer.value(forKey: "topY") as? CGFloat,
              let bottomY = layer.value(forKey: "bottomY") as? CGFloat,
              let startTime = layer.value(forKey: "startTime") as? CFTimeInterval,
              let bounceEndTime = layer.value(forKey: "bounceEndTime") as? CFTimeInterval,
              let endTime = layer.value(forKey: "endTime") as? CFTimeInterval,
              let completion = layer.value(forKey: "completion") as? (() -> Void) else {
            return
        }
        
        let currentTime = CACurrentMediaTime()
        
        if currentTime >= endTime {
            frame.origin.y = bottomY
            displayLink.invalidate()
            completion()
        } else if currentTime < bounceEndTime {
            let progress = (currentTime - startTime) / (bounceEndTime - startTime)
            let easedProgress = 1 - pow(1 - progress, 3)
            let currentY = startY + (topY - startY) * CGFloat(easedProgress)
            frame.origin.y = currentY
        } else {
            let progress = (currentTime - bounceEndTime) / (endTime - bounceEndTime)
            let easedProgress = pow(progress, 2)
            let currentY = topY + (bottomY - topY) * CGFloat(easedProgress)
            frame.origin.y = currentY
        }
    }
    
    func triggerShatterAnimation(completion: @escaping () -> Void) {
        addExplosionFlash()
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
                self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3).rotated(by: .pi / 3)
                self.alpha = 0
            } completion: { _ in
                self.removeFromSuperview()
                completion()
            }
        }
        
        generateShatterParticles()
        generateExplosionRing()
    }
    
    func addExplosionFlash() {
        let flashView = UIView(frame: bounds)
        flashView.backgroundColor = .white
        flashView.layer.cornerRadius = 6
        flashView.alpha = 0.8
        addSubview(flashView)
        
        UIView.animate(withDuration: 0.2) {
            flashView.alpha = 0
        } completion: { _ in
            flashView.removeFromSuperview()
        }
    }
    
    func generateExplosionRing() {
        let ringLayer = CAShapeLayer()
        let ringPath = UIBezierPath(ovalIn: CGRect(x: bounds.width / 2 - 5, y: bounds.height / 2 - 5, width: 10, height: 10))
        ringLayer.path = ringPath.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = (mahjongData.splinInt < 0 ? UIColor.red : UIColor.yellow).withAlphaComponent(0.8).cgColor
        ringLayer.lineWidth = 3
        layer.addSublayer(ringLayer)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 8
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = 0.4
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        ringLayer.add(group, forKey: "explosionRing")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            ringLayer.removeFromSuperlayer()
        }
    }
    
    func generateShatterParticles() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        emitter.emitterSize = bounds.size
        emitter.emitterShape = .circle
        emitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.birthRate = 80
        cell.lifetime = 1.0
        cell.velocity = 150
        cell.velocityRange = 80
        cell.emissionRange = .pi * 2
        cell.scale = 0.15
        cell.scaleRange = 0.08
        cell.alphaSpeed = -1.0
        cell.contents = createParticleImage(isPenalty: mahjongData.splinInt < 0).cgImage
        
        emitter.emitterCells = [cell]
        layer.addSublayer(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            emitter.birthRate = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            emitter.removeFromSuperlayer()
        }
    }
    
    func createParticleImage(isPenalty: Bool) -> UIImage {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor((isPenalty ? UIColor.red : UIColor.white).cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

