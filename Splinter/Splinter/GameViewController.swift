//
//  GameViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

enum GameMode {
    case classic
    case targeted
}

class GameViewController: BaseViewController {
    
    let gameMode: GameMode
    var accumulatedScore = 0
    var remainingDuration = 60
    var gameClock: Timer?
    var spawnClock: Timer?
    var targetRotationClock: Timer?
    var activeMahjongs: [MahjongView] = []
    var targetMahjongType: Int = 1
    
    let sliceTrailView: SliceTrailView
    let scoreLabel = UILabel()
    let timerLabel = UILabel()
    let targetDisplayView = UIView()
    let targetImageView = UIImageView()
    let targetHintLabel = UILabel()
    let withdrawButton: UIButton
    
    init(gameMode: GameMode) {
        self.gameMode = gameMode
        self.sliceTrailView = SliceTrailView()
        self.withdrawButton = UIButton()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "MahjongSplinter_HasSeenTutorial")
        if !hasSeenTutorial {
            exhibitTutorialAnimation()
        } else {
            initiateGameplay()
        }
    }
    
    func configureUI() {
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        
        withdrawButton.frame = CGRect(x: 20, y: safeTop + 10, width: 50, height: 50)
        withdrawButton.setTitle("←", for: .normal)
        withdrawButton.setTitleColor(.white, for: .normal)
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        withdrawButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        withdrawButton.layer.cornerRadius = 25
        withdrawButton.layer.borderWidth = 2
        withdrawButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        withdrawButton.addTarget(self, action: #selector(withdrawFromGame), for: .touchUpInside)
        view.addSubview(withdrawButton)
        
        configureLabelWithShadow(scoreLabel, text: "Score: 0", fontSize: 20, frame: CGRect(x: 90, y: safeTop + 15, width: 150, height: 40))
        configureLabelWithShadow(timerLabel, text: "60s", fontSize: 20, frame: CGRect(x: view.bounds.width - 160, y: safeTop + 15, width: 140, height: 40))
        timerLabel.textAlignment = .right
        
        if gameMode == .targeted {
            configureTargetDisplay()
        }
        
        sliceTrailView.frame = view.bounds
        view.addSubview(sliceTrailView)
    }
    
    func configureLabelWithShadow(_ label: UILabel, text: String, fontSize: CGFloat, frame: CGRect) {
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textColor = .white
        label.frame = frame
        AnimationHelper.applyShadowEffect(to: label.layer)
        view.addSubview(label)
    }
    
    func configureTargetDisplay() {
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        let displaySize: CGFloat = 55
        
        targetDisplayView.frame = CGRect(x: (view.bounds.width - displaySize) / 2, y: safeTop + 10, width: displaySize, height: displaySize * 1.45)
        targetDisplayView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        targetDisplayView.layer.cornerRadius = 6
        targetDisplayView.layer.borderWidth = 2
        targetDisplayView.layer.borderColor = UIColor.white.cgColor
        targetDisplayView.clipsToBounds = true
        view.addSubview(targetDisplayView)
        
        targetImageView.frame = targetDisplayView.bounds
        targetImageView.contentMode = .scaleAspectFill
        targetImageView.clipsToBounds = true
        targetImageView.layer.cornerRadius = 6
        targetDisplayView.addSubview(targetImageView)
        
        targetHintLabel.text = "Target changes every 10s"
        targetHintLabel.font = UIFont.boldSystemFont(ofSize: 14)
        targetHintLabel.textColor = .white
        targetHintLabel.textAlignment = .center
        targetHintLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        targetHintLabel.layer.cornerRadius = 8
        targetHintLabel.clipsToBounds = true
        targetHintLabel.frame = CGRect(x: (view.bounds.width - 200) / 2, y: targetDisplayView.frame.maxY + 10, width: 200, height: 32)
        AnimationHelper.applyShadowEffect(to: targetHintLabel.layer)
        targetHintLabel.alpha = 0
        view.addSubview(targetHintLabel)
        
        UIView.animate(withDuration: 0.5) { self.targetHintLabel.alpha = 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            UIView.animate(withDuration: 0.5) {
                self?.targetHintLabel.alpha = 0
                self?.targetDisplayView.alpha = 0
            }
        }
        
        randomizeTargetMahjong()
    }
    
    @objc func withdrawFromGame() {
        [gameClock, spawnClock, targetRotationClock].forEach { $0?.invalidate() }
        dismiss(animated: true)
    }
}

