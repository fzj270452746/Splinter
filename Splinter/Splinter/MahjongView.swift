//
//  MahjongView.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class MahjongView: UIView {
    
    let mahjongData: SplinterModel
    let imageView: UIImageView
    var isSliced = false
    
    init(mahjongData: SplinterModel, frame: CGRect) {
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
        
        AnimationHelper.applyShadowEffect(to: layer)
    }
    
    func commenceDescending(to destinationY: CGFloat, duration: TimeInterval, completion: @escaping () -> Void) {
        let startY = self.frame.origin.y
        let startTime = CACurrentMediaTime()
        let endTime = startTime + duration
        
        let displayLink = CADisplayLink(target: self, selector: #selector(updateDescendingPosition))
        displayLink.add(to: .main, forMode: .common)
        
        layer.setValue(startY, forKey: "startY")
        layer.setValue(destinationY, forKey: "destinationY")
        layer.setValue(startTime, forKey: "startTime")
        layer.setValue(endTime, forKey: "endTime")
        layer.setValue(displayLink, forKey: "displayLink")
        layer.setValue(completion, forKey: "completion")
    }
    
    @objc func updateDescendingPosition() {
        guard let displayLink = layer.value(forKey: "displayLink") as? CADisplayLink,
              let startY = layer.value(forKey: "startY") as? CGFloat,
              let destinationY = layer.value(forKey: "destinationY") as? CGFloat,
              let startTime = layer.value(forKey: "startTime") as? CFTimeInterval,
              let endTime = layer.value(forKey: "endTime") as? CFTimeInterval,
              let completion = layer.value(forKey: "completion") as? (() -> Void) else {
            return
        }
        
        let currentTime = CACurrentMediaTime()
        
        if currentTime >= endTime {
            frame.origin.y = destinationY
            displayLink.invalidate()
            completion()
        } else {
            let progress = (currentTime - startTime) / (endTime - startTime)
            let currentY = startY + (destinationY - startY) * CGFloat(progress)
            frame.origin.y = currentY
        }
    }
    
    func triggerShatterAnimation(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform(scaleX: 1.8, y: 1.8).rotated(by: .pi / 4)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
            completion()
        }
        
        generateShatterParticles()
    }
    
    func generateShatterParticles() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        emitter.emitterSize = bounds.size
        emitter.emitterShape = .circle
        emitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.birthRate = 50
        cell.lifetime = 0.8
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.alphaSpeed = -1.25
        cell.contents = createParticleImage(isPenalty: mahjongData.splinInt < 0).cgImage
        
        emitter.emitterCells = [cell]
        layer.addSublayer(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
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

