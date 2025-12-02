//
//  InstructionsViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class InstructionsViewController: UIViewController {
    
    let backgroundImageView = UIImageView()
    let overlayView = UIView()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let titleLabel = UILabel()
    let withdrawButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureScrollView()
        configureContent()
        configureWithdrawButton()
    }
    
    func configureBackground() {
        backgroundImageView.image = UIImage(named: "splinterImage")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = view.bounds
        view.addSubview(backgroundImageView)
        
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.frame = view.bounds
        view.addSubview(overlayView)
    }
    
    func configureScrollView() {
        scrollView.frame = CGRect(
            x: 20,
            y: 60,
            width: view.bounds.width - 40,
            height: view.bounds.height - 160
        )
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: 0)
        scrollView.addSubview(contentView)
    }
    
    func configureContent() {
        var yOffset: CGFloat = 20
        
        // 标题
        titleLabel.text = "How to Play"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: yOffset, width: contentView.bounds.width, height: 50)
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.5
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 4
        contentView.addSubview(titleLabel)
        yOffset += 70
        
        // 游戏介绍
        yOffset = appendSectionTitle("Game Objective", at: yOffset)
        yOffset = appendDescriptionText(
            "Slice the falling mahjong tiles with your finger to earn points. You have 60 seconds to achieve the highest score possible!",
            at: yOffset
        )
        
        // Classic Mode
        yOffset = appendSectionTitle("Slice Mode", at: yOffset)
        yOffset = appendDescriptionText(
            "• Slice any mahjong tile that falls\n• Each tile awards points equal to its face value (1-9)\n• ⚠️ Watch out for penalty tiles - they reduce your score!\n• Try to slice as many tiles as possible",
            at: yOffset
        )
        
        // Target Mode
        yOffset = appendSectionTitle("Target Mode", at: yOffset)
        yOffset = appendDescriptionText(
            "• A target mahjong is shown at the top\n• Only slice mahjong tiles that match the target type\n• ❌ Wrong tiles: -1 point\n• 💣 Penalty tiles: lose more points!\n• Target changes every 10 seconds\n• More challenging but higher rewards!",
            at: yOffset
        )
        
        // Tips
        yOffset = appendSectionTitle("Pro Tips", at: yOffset)
        yOffset = appendDescriptionText(
            "• Swipe quickly for better reactions\n• Watch the top of screen for new tiles\n• Plan your slicing path efficiently\n• In Target Mode, focus on the target type\n• Practice makes perfect!",
            at: yOffset
        )
        
        // Scoring
        yOffset = appendSectionTitle("Scoring System", at: yOffset)
        yOffset = appendDescriptionText(
            "Normal tiles (1-9) award their face value:\n• Low tiles (1-3): Easy but low points\n• Medium tiles (4-6): Balanced rewards\n• High tiles (7-9): Best scores!\n\n💣 Penalty Tiles:\n• Red tiles reduce your score\n• Avoid them or let them fall!\n\nChallenge yourself to beat your high score!",
            at: yOffset
        )
        
        contentView.frame.size.height = yOffset + 20
        scrollView.contentSize = contentView.frame.size
    }
    
    func appendSectionTitle(_ title: String, at yOffset: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor.compatibleCyan
        label.frame = CGRect(x: 20, y: yOffset, width: contentView.bounds.width - 40, height: 30)
        contentView.addSubview(label)
        return yOffset + 40
    }
    
    func appendDescriptionText(_ text: String, at yOffset: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.numberOfLines = 0
        label.frame = CGRect(x: 20, y: yOffset, width: contentView.bounds.width - 40, height: 0)
        label.sizeToFit()
        label.frame.size.width = contentView.bounds.width - 40
        contentView.addSubview(label)
        return yOffset + label.frame.height + 30
    }
    
    func configureWithdrawButton() {
        withdrawButton.frame = CGRect(
            x: (view.bounds.width - 150) / 2,
            y: view.bounds.height - 80,
            width: 150,
            height: 50
        )
        withdrawButton.setTitle("← Back", for: .normal)
        withdrawButton.setTitleColor(.white, for: .normal)
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        withdrawButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        withdrawButton.layer.cornerRadius = 12
        withdrawButton.layer.borderWidth = 2
        withdrawButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        withdrawButton.addTarget(self, action: #selector(withdrawFromView), for: .touchUpInside)
        view.addSubview(withdrawButton)
    }
    
    @objc func withdrawFromView() {
        dismiss(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

