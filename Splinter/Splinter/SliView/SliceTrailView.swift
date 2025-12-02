//
//  SliceTrailView.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class SliceTrailView: UIView {
    
    var trajectoryPath = UIBezierPath()
    var trajectoryLayer = CAShapeLayer()
    var gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTrailAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTrailAppearance() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        // 配置渐变层
        gradientLayer.colors = [
            UIColor.compatibleCyan.withAlphaComponent(0.9).cgColor,
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.compatibleCyan.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
        
        // 配置路径层
        trajectoryLayer.strokeColor = UIColor.white.cgColor
        trajectoryLayer.fillColor = UIColor.clear.cgColor
        trajectoryLayer.lineWidth = 8
        trajectoryLayer.lineCap = .round
        trajectoryLayer.lineJoin = .round
        gradientLayer.mask = trajectoryLayer
    }
    
    func initiateNewTrail(at point: CGPoint) {
        trajectoryPath = UIBezierPath()
        trajectoryPath.move(to: point)
        updateTrailPath()
    }
    
    func appendToTrail(point: CGPoint) {
        trajectoryPath.addLine(to: point)
        updateTrailPath()
    }
    
    func updateTrailPath() {
        trajectoryLayer.path = trajectoryPath.cgPath
        gradientLayer.frame = bounds
    }
    
    func clearTrail() {
        trajectoryPath.removeAllPoints()
        trajectoryLayer.path = nil
    }
    
    func animateFadeOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { _ in
            self.clearTrail()
            self.alpha = 1
            completion()
        }
    }
    
    func detectIntersection(with mahjongView: MahjongView) -> Bool {
        guard let superView = mahjongView.superview else {
            return false
        }
        
        // 获取麻将在sliceTrailView坐标系中的frame
        let mahjongFrameInTrailView = superView.convert(mahjongView.frame, to: self)
        
        // 扩大检测区域，让切割更容易触发
        let expandedFrame = mahjongFrameInTrailView.insetBy(dx: -20, dy: -20)
        
        let pathPoints = extractPathPoints()

        
        // 检测路径上的点是否与麻将区域相交
        for point in pathPoints {
            if expandedFrame.contains(point) {
                return true
            }
        }
        
        return false
    }
    
    func extractPathPoints() -> [CGPoint] {
        var points: [CGPoint] = []
        trajectoryPath.cgPath.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint, .addLineToPoint:
                points.append(element.pointee.points[0])
            default:
                break
            }
        }
        return points
    }
}

