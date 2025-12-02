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

class GameViewController: UIViewController {
    
    let gameMode: GameMode
    var accumulatedScore = 0
    var remainingDuration = 60
    var gameClock: Timer?
    var spawnClock: Timer?
    var targetRotationClock: Timer?  // Target Mode目标轮换计时器
    var activeMahjongs: [MahjongView] = []
    var targetMahjongType: Int = 1 // 1=all, 2=ball, 3=call
    var hasShownTutorial = false  // 是否已显示新手引导
    
    let backgroundImageView = UIImageView()
    let overlayView = UIView()
    let sliceTrailView: SliceTrailView
    let scoreLabel = UILabel()
    let timerLabel = UILabel()
    let targetDisplayView = UIView()
    let targetImageView = UIImageView()
    let targetHintLabel = UILabel()
    let withdrawButton = UIButton()
    
    init(gameMode: GameMode) {
        self.gameMode = gameMode
        self.sliceTrailView = SliceTrailView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureUI()
        
        // 检查是否需要显示新手引导
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "MahjongSplinter_HasSeenTutorial")
        if !hasSeenTutorial {
            exhibitTutorialAnimation()
        } else {
            initiateGameplay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 如果还没显示引导，在这里显示
        if !hasShownTutorial && !UserDefaults.standard.bool(forKey: "MahjongSplinter_HasSeenTutorial") {
            hasShownTutorial = true
        }
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
    
    func configureUI() {
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        
        // 得分标签 (避开左上角的返回按钮)
        scoreLabel.frame = CGRect(x: 90, y: safeTop + 15, width: 150, height: 40)
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.textColor = .white
        scoreLabel.layer.shadowColor = UIColor.black.cgColor
        scoreLabel.layer.shadowOpacity = 0.5
        scoreLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        scoreLabel.layer.shadowRadius = 4
        view.addSubview(scoreLabel)
        
        // 计时器标签
        timerLabel.frame = CGRect(x: view.bounds.width - 160, y: safeTop + 15, width: 140, height: 40)
        timerLabel.text = "60s"
        timerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        timerLabel.textColor = .white
        timerLabel.textAlignment = .right
        timerLabel.layer.shadowColor = UIColor.black.cgColor
        timerLabel.layer.shadowOpacity = 0.5
        timerLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        timerLabel.layer.shadowRadius = 4
        view.addSubview(timerLabel)
        
        // 目标显示（仅Target模式）
        if gameMode == .targeted {
            configureTargetDisplay()
        }
        
        // 返回按钮
        configureWithdrawButton()
        
        // 切割轨迹视图
        sliceTrailView.frame = view.bounds
        view.addSubview(sliceTrailView)
    }
    
    func configureTargetDisplay() {
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        let displaySize: CGFloat = 55  // 缩小尺寸
        
        targetDisplayView.frame = CGRect(
            x: (view.bounds.width - displaySize) / 2,
            y: safeTop + 10,
            width: displaySize,
            height: displaySize * 1.45
        )
        targetDisplayView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        targetDisplayView.layer.cornerRadius = 6
        targetDisplayView.layer.borderWidth = 2
        targetDisplayView.layer.borderColor = UIColor.white.cgColor
        targetDisplayView.clipsToBounds = true  // 切掉圆角外的内容
        view.addSubview(targetDisplayView)
        
        targetImageView.frame = targetDisplayView.bounds
        targetImageView.contentMode = .scaleAspectFill
        targetImageView.clipsToBounds = true
        targetImageView.layer.cornerRadius = 6  // 图片也要圆角
        targetDisplayView.addSubview(targetImageView)
        
        // 提示文本（每10秒换目标）
        targetHintLabel.text = "Target changes every 10s"
        targetHintLabel.font = UIFont.boldSystemFont(ofSize: 14)
        targetHintLabel.textColor = .white
        targetHintLabel.textAlignment = .center
        targetHintLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        targetHintLabel.layer.cornerRadius = 8
        targetHintLabel.clipsToBounds = true
        targetHintLabel.frame = CGRect(
            x: (view.bounds.width - 200) / 2,
            y: targetDisplayView.frame.maxY + 10,
            width: 200,
            height: 32
        )
        targetHintLabel.layer.shadowColor = UIColor.black.cgColor
        targetHintLabel.layer.shadowOpacity = 0.5
        targetHintLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        targetHintLabel.layer.shadowRadius = 4
        targetHintLabel.alpha = 0
        view.addSubview(targetHintLabel)
        
        // 淡入动画
        UIView.animate(withDuration: 0.5) {
            self.targetHintLabel.alpha = 1
        }
        
        // 3秒后隐藏提示文本和目标图片
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            UIView.animate(withDuration: 0.5) {
                self?.targetHintLabel.alpha = 0
                self?.targetDisplayView.alpha = 0
            }
        }
        
        randomizeTargetMahjong()
    }
    
    func configureWithdrawButton() {
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 20
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
    }
    
    func initiateGameplay() {
        // 立即生成第一个麻将
        generateMahjong()
        
        // 游戏时钟
        gameClock = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.decrementTimer()
        }
        
        // 麻将生成时钟
        spawnClock = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.generateMahjong()
        }
        
        // Target Mode - 每10秒轮换目标
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
        guard activeMahjongs.count < 5 else {
            return
        }
        
        let mahjongWidth: CGFloat = 60
        let mahjongHeight: CGFloat = mahjongWidth * 1.45
        let randomX = CGFloat.random(in: 40...(view.bounds.width - mahjongWidth - 40))
        
        let randomMahjong = selectRandomMahjong()
        let startY = -mahjongHeight - 20
        let endY = view.bounds.height + 20
        
        let mahjongView = MahjongView(
            mahjongData: randomMahjong,
            frame: CGRect(x: randomX, y: startY, width: mahjongWidth, height: mahjongHeight)
        )
        
        view.insertSubview(mahjongView, belowSubview: sliceTrailView)
        activeMahjongs.append(mahjongView)
        
        let descendDuration = TimeInterval.random(in: 3.5...5.0)
        
        mahjongView.commenceDescending(to: endY, duration: descendDuration) { [weak self] in
            self?.removeMahjong(mahjongView)
        }
    }
    
    func selectRandomMahjong() -> SplinterModel {
        let normalMahjongs = [
            all1, all2, all3, all4, all5, all6, all7, all8, all9,
            bll1, bll2, bll3, bll4, bll5, bll6, bll7, bll8, bll9,
            cll1, cll2, cll3, cll4, cll5, cll6, cll7, cll8, cll9
        ]
        
        let penaltyMahjongs = [penaltyTile1, penaltyTile2, penaltyTile3]
        
        // 80%概率普通麻将，20%概率减分麻将
        let shouldSpawnPenalty = Int.random(in: 1...100) <= 20
        
        if shouldSpawnPenalty {
            return penaltyMahjongs.randomElement()!
        } else {
            return normalMahjongs.randomElement()!
        }
    }
    
    func randomizeTargetMahjong() {
        targetMahjongType = Int.random(in: 1...3)
        updateTargetImage()
    }
    
    func rotateTargetMahjong() {
        // 每10秒自动轮换目标
        randomizeTargetMahjong()
        
        // 闪烁提示目标已更换
        UIView.animate(withDuration: 0.2) {
            self.targetDisplayView.alpha = 1
            self.targetDisplayView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.targetDisplayView.transform = .identity
            } completion: { _ in
                // 2秒后再次隐藏
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 0.3) {
                        self.targetDisplayView.alpha = 0
                    }
                }
            }
        }
    }
    
    func updateTargetImage() {
        let targetMahjongs: [SplinterModel]
        switch targetMahjongType {
        case 1: targetMahjongs = [all1, all2, all3, all4, all5, all6, all7, all8, all9]
        case 2: targetMahjongs = [bll1, bll2, bll3, bll4, bll5, bll6, bll7, bll8, bll9]
        default: targetMahjongs = [cll1, cll2, cll3, cll4, cll5, cll6, cll7, cll8, cll9]
        }
        
        targetImageView.image = targetMahjongs.randomElement()?.splinImage
    }
    
    func removeMahjong(_ mahjong: MahjongView) {
        activeMahjongs.removeAll { $0 === mahjong }
        mahjong.removeFromSuperview()
    }
    
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
        for (index, mahjong) in activeMahjongs.enumerated() {
            if !mahjong.isSliced {
                let hit = sliceTrailView.detectIntersection(with: mahjong)
                if hit {
                    mahjong.isSliced = true  // 标记为已切割
                    processMahjongSlice(mahjong)
                }
            }
        }
    }
    
    func processMahjongSlice(_ mahjong: MahjongView) {
        removeMahjong(mahjong)
        
        var shouldAwardPoints = false
        var pointsAwarded = 0
        
        // 检查是否是减分麻将（炸弹）
        let isPenaltyTile = mahjong.mahjongData.splinInt < 0
        
        switch gameMode {
        case .classic:
            shouldAwardPoints = true
            pointsAwarded = mahjong.mahjongData.splinInt
            
            if isPenaltyTile {
            } else {
            }
            
        case .targeted:
            if isPenaltyTile {
                // 减分麻将总是扣分
                shouldAwardPoints = true
                pointsAwarded = mahjong.mahjongData.splinInt
            } else {
                let currentMahjongType = determineMahjongType(mahjong: mahjong.mahjongData)
                let isCorrectType = currentMahjongType == targetMahjongType
                
                if isCorrectType {
                    shouldAwardPoints = true
                    pointsAwarded = mahjong.mahjongData.splinInt
                } else {
                    // 切中错误类型，扣1分
                    shouldAwardPoints = true
                    pointsAwarded = -1
                }
            }
        }
        
        if shouldAwardPoints {
            accumulatedScore += pointsAwarded
            // 确保分数不会为负
            if accumulatedScore < 0 {
                accumulatedScore = 0
            }
            scoreLabel.text = "Score: \(accumulatedScore)"
            animateScoreIncrement(points: pointsAwarded, at: mahjong.center)
        }
        
        mahjong.triggerShatterAnimation { }
    }
    
    func determineMahjongType(mahjong: SplinterModel) -> Int {
        // 通过比较图片对象来判断类型
        let allMahjongs = [all1, all2, all3, all4, all5, all6, all7, all8, all9]
        let ballMahjongs = [bll1, bll2, bll3, bll4, bll5, bll6, bll7, bll8, bll9]
        
        if allMahjongs.contains(where: { $0.splinImage === mahjong.splinImage }) {
            return 1
        } else if ballMahjongs.contains(where: { $0.splinImage === mahjong.splinImage }) {
            return 2
        } else {
            return 3
        }
    }
    
    func animateScoreIncrement(points: Int, at position: CGPoint) {
        let floatingLabel = UILabel()
        
        if points > 0 {
            floatingLabel.text = "+\(points)"
            floatingLabel.textColor = .yellow
        } else {
            floatingLabel.text = "\(points)"  // 负数自带减号
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
    
    func concludeGameplay() {
        gameClock?.invalidate()
        spawnClock?.invalidate()
        targetRotationClock?.invalidate()
        
        // 保存游戏记录
        let modeText = gameMode == .classic ? "Slice Mode" : "Target Mode"
        let archive = GameArchive(obtainedScore: accumulatedScore, gameMode: modeText)
        GameArchiveRepository.shared.persistArchive(archive)
        
        exhibitGameOverDialog()
    }
    
    func exhibitGameOverDialog() {
        let dialogView = UIView()
        dialogView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        dialogView.layer.cornerRadius = 20
        dialogView.frame = CGRect(
            x: 40,
            y: view.bounds.height / 2 - 120,
            width: view.bounds.width - 80,
            height: 240
        )
        dialogView.alpha = 0
        dialogView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        view.addSubview(dialogView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Game Over"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 20, y: 30, width: dialogView.bounds.width - 40, height: 40)
        dialogView.addSubview(titleLabel)
        
        let scoreLabel = UILabel()
        scoreLabel.text = "Final Score: \(accumulatedScore)"
        scoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        scoreLabel.textColor = UIColor.compatibleCyan
        scoreLabel.textAlignment = .center
        scoreLabel.frame = CGRect(x: 20, y: 85, width: dialogView.bounds.width - 40, height: 30)
        dialogView.addSubview(scoreLabel)
        
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
    
    @objc func withdrawFromGame() {
        gameClock?.invalidate()
        spawnClock?.invalidate()
        targetRotationClock?.invalidate()
        dismiss(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Tutorial Animation
    
    func exhibitTutorialAnimation() {
        // 创建半透明遮罩
        let tutorialOverlay = UIView()
        tutorialOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        tutorialOverlay.frame = view.bounds
        tutorialOverlay.alpha = 0
        tutorialOverlay.tag = 9999
        view.addSubview(tutorialOverlay)
        
        // 创建示例麻将
        let mahjongWidth: CGFloat = 80
        let mahjongHeight: CGFloat = mahjongWidth * 1.45
        let sampleMahjong = MahjongView(
            mahjongData: all5,
            frame: CGRect(
                x: (view.bounds.width - mahjongWidth) / 2,
                y: view.bounds.height / 2 - mahjongHeight / 2,
                width: mahjongWidth,
                height: mahjongHeight
            )
        )
        sampleMahjong.alpha = 0
        tutorialOverlay.addSubview(sampleMahjong)
        
        // 创建手指图标
        let fingerIcon = UILabel()
        fingerIcon.text = "👆"
        fingerIcon.font = UIFont.systemFont(ofSize: 60)
        fingerIcon.frame = CGRect(
            x: sampleMahjong.frame.minX - 80,
            y: sampleMahjong.frame.minY - 30,
            width: 80,
            height: 80
        )
        fingerIcon.alpha = 0
        tutorialOverlay.addSubview(fingerIcon)
        
        // 创建提示文字
        let instructionLabel = UILabel()
        instructionLabel.text = "Swipe across the mahjong!"
        instructionLabel.font = UIFont.boldSystemFont(ofSize: 24)
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.frame = CGRect(
            x: 40,
            y: sampleMahjong.frame.minY - 100,
            width: view.bounds.width - 80,
            height: 40
        )
        instructionLabel.alpha = 0
        tutorialOverlay.addSubview(instructionLabel)
        
        // 创建得分提示（隐藏）
        let scoreHint = UILabel()
        scoreHint.text = "+5"
        scoreHint.font = UIFont.boldSystemFont(ofSize: 36)
        scoreHint.textColor = .yellow
        scoreHint.textAlignment = .center
        scoreHint.layer.shadowColor = UIColor.black.cgColor
        scoreHint.layer.shadowOpacity = 0.8
        scoreHint.layer.shadowOffset = CGSize(width: 0, height: 2)
        scoreHint.layer.shadowRadius = 4
        scoreHint.frame = CGRect(
            x: (view.bounds.width - 100) / 2,
            y: sampleMahjong.center.y - 18,
            width: 100,
            height: 50
        )
        scoreHint.alpha = 0
        tutorialOverlay.addSubview(scoreHint)
        
        // 创建切割轨迹（用于演示）
        let demoTrailView = SliceTrailView(frame: tutorialOverlay.bounds)
        demoTrailView.alpha = 0
        tutorialOverlay.addSubview(demoTrailView)
        
        // 创建跳过按钮
        let skipButton = UIButton()
        skipButton.setTitle("Skip Tutorial", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        skipButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        skipButton.layer.cornerRadius = 10
        skipButton.layer.borderWidth = 1
        skipButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        skipButton.frame = CGRect(
            x: view.bounds.width - 140,
            y: view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top + 10 : 40,
            width: 120,
            height: 40
        )
        skipButton.alpha = 0
        skipButton.addTarget(self, action: #selector(dismissTutorialAndStart), for: .touchUpInside)
        tutorialOverlay.addSubview(skipButton)
        
        // 动画序列
        UIView.animate(withDuration: 0.5) {
            tutorialOverlay.alpha = 1
            skipButton.alpha = 1
        } completion: { _ in
            // 1. 显示麻将和文字
            UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut) {
                sampleMahjong.alpha = 1
                instructionLabel.alpha = 1
            } completion: { _ in
                // 2. 显示手指并开始滑动动画
                self.performSwipeDemo(
                    fingerIcon: fingerIcon,
                    trailView: demoTrailView,
                    mahjong: sampleMahjong,
                    scoreHint: scoreHint
                )
            }
        }
    }
    
    func performSwipeDemo(fingerIcon: UILabel, trailView: SliceTrailView, mahjong: MahjongView, scoreHint: UILabel) {
        let startPoint = CGPoint(x: mahjong.frame.minX - 40, y: mahjong.center.y)
        let endPoint = CGPoint(x: mahjong.frame.maxX + 40, y: mahjong.center.y)
        
        // 显示手指
        UIView.animate(withDuration: 0.3, delay: 0.5) {
            fingerIcon.alpha = 1
        } completion: { _ in
            // 初始化轨迹
            trailView.initiateNewTrail(at: startPoint)
            
            UIView.animate(withDuration: 0.2) {
                trailView.alpha = 1
            }
            
            // 分20步绘制轨迹（递归方式）
            self.animateSwipeStep(
                step: 0,
                totalSteps: 20,
                fingerIcon: fingerIcon,
                trailView: trailView,
                from: startPoint,
                to: endPoint
            ) {
                // 滑动完成后，触发爆炸
                mahjong.triggerShatterAnimation {
                    // 显示得分
                    UIView.animate(withDuration: 0.3) {
                        scoreHint.alpha = 1
                    } completion: { _ in
                        UIView.animate(withDuration: 0.8) {
                            scoreHint.center.y -= 60
                            scoreHint.alpha = 0
                        } completion: { _ in
                            // 1秒后关闭教程
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.dismissTutorialAndStart()
                            }
                        }
                    }
                }
                
                // 轨迹和手指淡出
                UIView.animate(withDuration: 0.3, delay: 0.2) {
                    trailView.alpha = 0
                    fingerIcon.alpha = 0
                }
            }
        }
    }
    
    func animateSwipeStep(step: Int, totalSteps: Int, fingerIcon: UILabel, trailView: SliceTrailView, from startPoint: CGPoint, to endPoint: CGPoint, onComplete: @escaping () -> Void) {
        guard step <= totalSteps else {
            onComplete()
            return
        }
        
        let progress = CGFloat(step) / CGFloat(totalSteps)
        let currentPoint = CGPoint(
            x: startPoint.x + (endPoint.x - startPoint.x) * progress,
            y: startPoint.y + (endPoint.y - startPoint.y) * progress
        )
        
        fingerIcon.center = CGPoint(x: currentPoint.x + 40, y: currentPoint.y - 30)
        trailView.appendToTrail(point: currentPoint)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            self.animateSwipeStep(
                step: step + 1,
                totalSteps: totalSteps,
                fingerIcon: fingerIcon,
                trailView: trailView,
                from: startPoint,
                to: endPoint,
                onComplete: onComplete
            )
        }
    }
    
    @objc func dismissTutorialAndStart() {
        // 标记已查看教程
        UserDefaults.standard.set(true, forKey: "MahjongSplinter_HasSeenTutorial")
        
        // 移除教程覆盖层
        if let tutorialOverlay = view.viewWithTag(9999) {
            UIView.animate(withDuration: 0.5) {
                tutorialOverlay.alpha = 0
            } completion: { _ in
                tutorialOverlay.removeFromSuperview()
                // 开始游戏
                self.initiateGameplay()
            }
        } else {
            initiateGameplay()
        }
    }
}

