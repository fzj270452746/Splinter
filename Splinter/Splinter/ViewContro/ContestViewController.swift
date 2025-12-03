//
//  ContestViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

enum ContestMode {
    case arcade
    case targeted
}

class ContestViewController: VantageViewController {
    
    let gameMode: ContestMode
    var accumulatedScore = 0
    var remainingDuration = 60
    var gameClock: Timer?
    var spawnClock: Timer?
    var targetRotationClock: Timer?
    var activeMahjongs: [TileSpecimen] = []
    var targetMahjongType: Int = 1
    
    let sliceTrailView: LacerationTrailCanvas
    let scoreLabel = UILabel()
    let timerLabel = UILabel()
    let targetDisplayView = UIView()
    let targetImageView = UIImageView()
    let targetHintLabel = UILabel()
    let withdrawButton: UIButton
    
    init(gameMode: ContestMode) {
        self.gameMode = gameMode
        self.sliceTrailView = LacerationTrailCanvas()
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
        KineticOrchestrator.applyShadowEffect(to: label.layer)
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
        KineticOrchestrator.applyShadowEffect(to: targetHintLabel.layer)
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
    
    // MARK: - Gameplay
    
    func initiateGameplay() {
        generateMahjong()
        
        gameClock = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.decrementTimer()
        }
        
        spawnClock = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.generateMahjong()
        }
        
        if gameMode == .targeted {
            targetRotationClock = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
                self?.rotateTargetMahjong()
            }
        }
    }
    
    func decrementTimer() {
        remainingDuration -= 1
        timerLabel.text = "\(remainingDuration)s"
        
        if remainingDuration <= 0 {
            concludeGameplay()
        }
    }
    
    func generateMahjong() {
        guard activeMahjongs.count < 5 else { return }
        
        let mahjongWidth: CGFloat = 60
        let mahjongHeight: CGFloat = mahjongWidth * 1.45
        let randomX = CGFloat.random(in: 40...(view.bounds.width - mahjongWidth - 40))
        let randomMahjong = selectRandomMahjong()
        
        let startY = view.bounds.height + 20
        let topY: CGFloat = 150
        let bottomY = view.bounds.height + 20
        
        let mahjongView = TileSpecimen(
            mahjongData: randomMahjong,
            frame: CGRect(x: randomX, y: startY, width: mahjongWidth, height: mahjongHeight)
        )
        
        view.insertSubview(mahjongView, belowSubview: sliceTrailView)
        activeMahjongs.append(mahjongView)
        
        let totalDuration = TimeInterval.random(in: 4.0...5.5)
        mahjongView.commenceBouncingAndDescending(topY: topY, bottomY: bottomY, totalDuration: totalDuration) { [weak self] in
            self?.removeMahjong(mahjongView)
        }
    }
    
    func selectRandomMahjong() -> TileEntity {
        let shouldSpawnPenalty = Int.random(in: 1...100) <= 20
        return shouldSpawnPenalty ? TileEntity.penaltyTiles.randomElement()! : TileEntity.allNormalTiles.randomElement()!
    }
    
    func removeMahjong(_ mahjong: TileSpecimen) {
        activeMahjongs.removeAll { $0 === mahjong }
        mahjong.removeFromSuperview()
    }
    
    func randomizeTargetMahjong() {
        targetMahjongType = Int.random(in: 1...3)
        updateTargetImage()
    }
    
    func rotateTargetMahjong() {
        randomizeTargetMahjong()
        
        UIView.animate(withDuration: 0.2) {
            self.targetDisplayView.alpha = 1
            self.targetDisplayView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.targetDisplayView.transform = .identity
            } completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 0.3) {
                        self.targetDisplayView.alpha = 0
                    }
                }
            }
        }
    }
    
    func updateTargetImage() {
        let targetMahjongs: [TileEntity]
        switch targetMahjongType {
        case 1: targetMahjongs = TileEntity.allTypeTiles
        case 2: targetMahjongs = TileEntity.ballTypeTiles
        default: targetMahjongs = TileEntity.callTypeTiles
        }
        targetImageView.image = targetMahjongs.randomElement()?.splinImage
    }
    
    func concludeGameplay() {
        [gameClock, spawnClock, targetRotationClock].forEach { $0?.invalidate() }
        
        let modeText = gameMode == .arcade ? "Arcade Mode" : "Target Mode"
        let archive = ContestMemorandum(obtainedScore: accumulatedScore, gameMode: modeText)
        MemorandumVault.shared.persistArchive(archive)
        
        exhibitGameOverDialog()
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: sliceTrailView)
        sliceTrailView.initiateNewTrail(at: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: sliceTrailView)
        sliceTrailView.appendToTrail(point: location)
        evaluateSliceCollisions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sliceTrailView.animateFadeOut { }
    }
    
    func evaluateSliceCollisions() {
        for mahjong in activeMahjongs where !mahjong.isSliced {
            if sliceTrailView.detectIntersection(with: mahjong) {
                mahjong.isSliced = true
                processMahjongSlice(mahjong)
            }
        }
    }
    
    func processMahjongSlice(_ mahjong: TileSpecimen) {
        removeMahjong(mahjong)
        
        let isPenaltyTile = mahjong.mahjongData.splinInt < 0
        var pointsAwarded = 0
        
        switch gameMode {
        case .arcade:
            pointsAwarded = mahjong.mahjongData.splinInt
            
        case .targeted:
            if isPenaltyTile {
                pointsAwarded = mahjong.mahjongData.splinInt
            } else {
                let currentType = determineMahjongType(mahjong: mahjong.mahjongData)
                pointsAwarded = currentType == targetMahjongType ? mahjong.mahjongData.splinInt : -1
            }
        }
        
        accumulatedScore = max(0, accumulatedScore + pointsAwarded)
        scoreLabel.text = "Score: \(accumulatedScore)"
        KineticOrchestrator.animateFloatingScore(pointsAwarded, at: mahjong.center, in: view)
        mahjong.triggerShatterAnimation { }
    }
    
    func determineMahjongType(mahjong: TileEntity) -> Int {
        if TileEntity.allTypeTiles.contains(where: { $0.splinImage === mahjong.splinImage }) { return 1 }
        if TileEntity.ballTypeTiles.contains(where: { $0.splinImage === mahjong.splinImage }) { return 2 }
        return 3
    }
    
    // MARK: - UI
    
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
    
    // MARK: - Tutorial
    
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
    
    func createTutorialComponents() -> (mahjong: TileSpecimen, finger: UILabel, instruction: UILabel, scoreHint: UILabel, trail: LacerationTrailCanvas, skipButton: UIButton) {
        let mahjongWidth: CGFloat = 80
        let mahjongHeight: CGFloat = mahjongWidth * 1.45
        
        let mahjong = TileSpecimen(mahjongData: all5, frame: CGRect(x: (view.bounds.width - mahjongWidth) / 2, y: view.bounds.height / 2 - mahjongHeight / 2, width: mahjongWidth, height: mahjongHeight))
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
        KineticOrchestrator.applyShadowEffect(to: scoreHint.layer)
        scoreHint.layer.shadowOpacity = 0.8
        scoreHint.frame = CGRect(x: (view.bounds.width - 100) / 2, y: mahjong.center.y - 18, width: 100, height: 50)
        scoreHint.alpha = 0
        
        let trail = LacerationTrailCanvas(frame: view.bounds)
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
    
    func addTutorialComponents(_ components: (mahjong: TileSpecimen, finger: UILabel, instruction: UILabel, scoreHint: UILabel, trail: LacerationTrailCanvas, skipButton: UIButton), to overlay: UIView) {
        overlay.addSubview(components.mahjong)
        overlay.addSubview(components.finger)
        overlay.addSubview(components.instruction)
        overlay.addSubview(components.scoreHint)
        overlay.addSubview(components.trail)
        overlay.addSubview(components.skipButton)
    }
    
    func performSwipeDemo(components: (mahjong: TileSpecimen, finger: UILabel, instruction: UILabel, scoreHint: UILabel, trail: LacerationTrailCanvas, skipButton: UIButton)) {
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
    
    func animateSwipeStep(step: Int, totalSteps: Int, finger: UILabel, trail: LacerationTrailCanvas, from start: CGPoint, to end: CGPoint, onComplete: @escaping () -> Void) {
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
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sliceTrailView.frame = view.bounds
        adjustLayoutForCurrentDevice()
    }
    
    func adjustLayoutForCurrentDevice() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        
        if isPad {
            configurePadLayout(safeTop: safeTop)
        } else {
            configurePhoneLayout(safeTop: safeTop)
        }
    }
    
    func configurePadLayout(safeTop: CGFloat) {
        withdrawButton.frame = CGRect(x: 30, y: safeTop + 15, width: 55, height: 55)
        withdrawButton.layer.cornerRadius = 27.5
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        
        scoreLabel.frame = CGRect(x: 110, y: safeTop + 20, width: 200, height: 50)
        timerLabel.frame = CGRect(x: view.bounds.width - 240, y: safeTop + 20, width: 200, height: 50)
        
        if gameMode == .targeted {
            let displaySize: CGFloat = 65
            targetDisplayView.frame = CGRect(x: (view.bounds.width - displaySize) / 2, y: safeTop + 15, width: displaySize, height: displaySize * 1.45)
            targetImageView.frame = targetDisplayView.bounds
            targetHintLabel.frame = CGRect(x: (view.bounds.width - 220) / 2, y: targetDisplayView.frame.maxY + 12, width: 220, height: 40)
        }
    }
    
    func configurePhoneLayout(safeTop: CGFloat) {
        withdrawButton.frame = CGRect(x: 20, y: safeTop + 10, width: 50, height: 50)
        withdrawButton.layer.cornerRadius = 25
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        scoreLabel.frame = CGRect(x: 90, y: safeTop + 15, width: 150, height: 40)
        timerLabel.frame = CGRect(x: view.bounds.width - 160, y: safeTop + 15, width: 140, height: 40)
        
        if gameMode == .targeted {
            let displaySize: CGFloat = 55
            targetDisplayView.frame = CGRect(x: (view.bounds.width - displaySize) / 2, y: safeTop + 10, width: displaySize, height: displaySize * 1.45)
            targetImageView.frame = targetDisplayView.bounds
            targetHintLabel.frame = CGRect(x: (view.bounds.width - 220) / 2, y: targetDisplayView.frame.maxY + 10, width: 220, height: 32)
        }
    }
}
