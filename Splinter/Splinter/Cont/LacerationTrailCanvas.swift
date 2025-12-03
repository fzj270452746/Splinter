//
//  LacerationTrailCanvas.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class LacerationTrailCanvas: UIView {
    
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
        
        gradientLayer.colors = [
            UIColor.compatibleCyan.withAlphaComponent(0.9).cgColor,
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.compatibleCyan.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
        
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
    
    func detectIntersection(with tileView: TileSpecimen) -> Bool {
        guard let superView = tileView.superview else { return false }
        
        let tileFrameInTrailView = superView.convert(tileView.frame, to: self)
        let expandedFrame = tileFrameInTrailView.insetBy(dx: -20, dy: -20)
        
        for point in extractPathPoints() where expandedFrame.contains(point) {
            return true
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

