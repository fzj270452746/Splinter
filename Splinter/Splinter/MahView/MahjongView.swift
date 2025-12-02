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
    var descendingAnimation: (() -> Void)?
    var isSliced = false  // 防止重复切割
    
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
        // 设置图片视图
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        // 判断是否是减分麻将
        let isPenaltyTile = mahjongData.splinInt < 0
        
        // 圆角
        layer.cornerRadius = 6
        clipsToBounds = true
        
        // 只有普通麻将才有边框
        if !isPenaltyTile {
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        }
        
        // 阴影效果
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
    
    func commenceDescending(to destinationY: CGFloat, duration: TimeInterval, completion: @escaping () -> Void) {
        
        // 使用更简单的方案：CADisplayLink 手动更新位置
        let startY = self.frame.origin.y
        let startTime = CACurrentMediaTime()
        let endTime = startTime + duration
        
        let displayLink = CADisplayLink(target: self, selector: #selector(updateDescendingPosition))
        displayLink.add(to: .main, forMode: .common)
        
        // 存储动画参数
        self.layer.setValue(startY, forKey: "startY")
        self.layer.setValue(destinationY, forKey: "destinationY")
        self.layer.setValue(startTime, forKey: "startTime")
        self.layer.setValue(endTime, forKey: "endTime")
        self.layer.setValue(displayLink, forKey: "displayLink")
        self.layer.setValue(completion, forKey: "completion")
    }
    
    @objc func updateDescendingPosition() {
        guard let displayLink = self.layer.value(forKey: "displayLink") as? CADisplayLink,
              let startY = self.layer.value(forKey: "startY") as? CGFloat,
              let destinationY = self.layer.value(forKey: "destinationY") as? CGFloat,
              let startTime = self.layer.value(forKey: "startTime") as? CFTimeInterval,
              let endTime = self.layer.value(forKey: "endTime") as? CFTimeInterval,
              let completion = self.layer.value(forKey: "completion") as? (() -> Void) else {
            return
        }
        
        let currentTime = CACurrentMediaTime()
        
        if currentTime >= endTime {
            // 动画结束
            self.frame.origin.y = destinationY
            displayLink.invalidate()
            completion()
        } else {
            // 计算当前位置
            let progress = (currentTime - startTime) / (endTime - startTime)
            let currentY = startY + (destinationY - startY) * CGFloat(progress)
            self.frame.origin.y = currentY
        }
    }
    
    func triggerShatterAnimation(completion: @escaping () -> Void) {
        // 爆炸效果：放大+旋转+淡出
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform(scaleX: 1.8, y: 1.8).rotated(by: .pi / 4)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
            completion()
        }
        
        // 添加粒子效果
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
        
        // 根据麻将值判断粒子颜色（负分用红色）
        if mahjongData.splinInt < 0 {
            cell.contents = createParticleImage(color: .red).cgImage
        } else {
            cell.contents = createParticleImage(color: .white).cgImage
        }
        
        emitter.emitterCells = [cell]
        layer.addSublayer(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            emitter.removeFromSuperlayer()
        }
    }
    
    func createParticleImage(color: UIColor = .white) -> UIImage {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

