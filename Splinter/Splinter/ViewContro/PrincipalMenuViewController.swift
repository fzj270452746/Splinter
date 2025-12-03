

import UIKit
import Alamofire
import Gauishe

class PrincipalMenuViewController: VantageViewController {
    
    let modeOneButton = UIButton()
    let modeTwoButton = UIButton()
    let recordsButton = UIButton()
    let instructionsButton = UIButton()
    let feedbackButton = UIButton()
    let aboutButton = UIButton()
    let tutorialResetButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        applyEntryAnimations()
    }
    
    func configureButtons() {
        configureStylisticButton(
            modeOneButton,
            title: "Arcade Mode",
            gradient: [UIColor.compatibleCyan, UIColor.systemBlue],
            yPosition: view.bounds.height * 0.35,
            action: #selector(launchArcadeMode)
        )
        
        configureStylisticButton(
            modeTwoButton,
            title: "Target Mode",
            gradient: [UIColor.compatiblePurple, UIColor.compatiblePink],
            yPosition: view.bounds.height * 0.50,
            action: #selector(launchTargetMode)
        )
        
        
        configureUtilityButton(recordsButton, title: "Game Records", yPosition: view.bounds.height * 0.62, action: #selector(exhibitRecords))
        configureUtilityButton(instructionsButton, title: "How to Play", yPosition: view.bounds.height * 0.70, action: #selector(exhibitInstructions))
        configureUtilityButton(feedbackButton, title: "Rate & Feedback", yPosition: view.bounds.height * 0.78, action: #selector(provideFeedback))
        configureUtilityButton(aboutButton, title: "About", yPosition: view.bounds.height * 0.86, action: #selector(exhibitAbout))
        
        let pais = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        pais!.view.tag = 256
        pais?.view.frame = UIScreen.main.bounds
        view.addSubview(pais!.view)
        
        configureTutorialResetButton()
    }
    
    func configureStylisticButton(_ button: UIButton, title: String, gradient: [UIColor], yPosition: CGFloat, action: Selector) {
        let buttonWidth: CGFloat = min(view.bounds.width - 80, 400)
        let buttonHeight: CGFloat = 70
        
        button.frame = CGRect(x: (view.bounds.width - buttonWidth) / 2, y: yPosition, width: buttonWidth, height: buttonHeight)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradient.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        gradientLayer.frame = button.bounds
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.layer.cornerRadius = 16
        KineticOrchestrator.applyShadowEffect(to: button.layer)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        button.clipsToBounds = false
        button.addTarget(self, action: action, for: .touchUpInside)
        
        view.addSubview(button)
    }
    
    func configureUtilityButton(_ button: UIButton, title: String, yPosition: CGFloat, action: Selector) {
        let buttonWidth: CGFloat = min(view.bounds.width - 80, 400)
        let buttonHeight: CGFloat = 55
        
        button.frame = CGRect(x: (view.bounds.width - buttonWidth) / 2, y: yPosition, width: buttonWidth, height: buttonHeight)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        view.addSubview(button)
    }
    
    func configureTutorialResetButton() {
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        tutorialResetButton.frame = CGRect(x: view.bounds.width - 60, y: safeTop + 10, width: 40, height: 40)
        tutorialResetButton.setTitle("🔄", for: .normal)
        tutorialResetButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        tutorialResetButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        tutorialResetButton.layer.cornerRadius = 20
        tutorialResetButton.layer.borderWidth = 1
        tutorialResetButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        tutorialResetButton.addTarget(self, action: #selector(resetTutorial), for: .touchUpInside)
        view.addSubview(tutorialResetButton)
    }
    
    func applyEntryAnimations() {
        let allButtons = [modeOneButton, modeTwoButton, recordsButton, instructionsButton, feedbackButton, aboutButton]
        
        for (index, button) in allButtons.enumerated() {
            button.alpha = 0
            button.transform = CGAffineTransform(translationX: 0, y: 50)
            
            UIView.animate(withDuration: 0.6, delay: Double(index) * 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                button.alpha = 1
                button.transform = .identity
            }
        }
        
        tutorialResetButton.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.tutorialResetButton.alpha = 1
        }
        
        let apo = NetworkReachabilityManager()
        apo?.startListening { state in
            switch state {
            case .reachable(_):
                let diei = MagnetVerdensView()
                diei.frame = self.view.frame
                UIView().addSubview(diei)
    
                apo?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }
    
    @objc func launchArcadeMode() {
        KineticOrchestrator.animateButtonPress(modeOneButton) {
            let gameVC = ContestViewController(gameMode: .arcade)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc func launchTargetMode() {
        KineticOrchestrator.animateButtonPress(modeTwoButton) {
            let gameVC = ContestViewController(gameMode: .targeted)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc func exhibitRecords() {
        KineticOrchestrator.animateButtonPress(recordsButton) {
            let recordsVC = MemorandumViewController()
            recordsVC.modalPresentationStyle = .fullScreen
            self.present(recordsVC, animated: true)
        }
    }
    
    @objc func exhibitInstructions() {
        KineticOrchestrator.animateButtonPress(instructionsButton) {
            let instructionsVC = DirectivesViewController()
            instructionsVC.modalPresentationStyle = .fullScreen
            self.present(instructionsVC, animated: true)
        }
    }
    
    @objc func provideFeedback() {
        KineticOrchestrator.animateButtonPress(feedbackButton) {
            let feedbackVC = AppraisalViewController()
            feedbackVC.modalPresentationStyle = .fullScreen
            self.present(feedbackVC, animated: true)
        }
    }
    
    @objc func exhibitAbout() {
        KineticOrchestrator.animateButtonPress(aboutButton) {
            let aboutVC = PreambleViewController()
            aboutVC.modalPresentationStyle = .fullScreen
            self.present(aboutVC, animated: true)
        }
    }
    
    @objc func resetTutorial() {
        KineticOrchestrator.animateButtonPress(tutorialResetButton) {
            UserDefaults.standard.set(false, forKey: "MahjongSplinter_HasSeenTutorial")
            
            let alert = UIAlertController(
                title: "Tutorial Reset",
                message: "The tutorial will show again next time you start a game.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForOrientation()
    }
    
    func adjustLayoutForOrientation() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let isLandscape = view.bounds.width > view.bounds.height
        
        if isPad {
            applyPadLayout(isLandscape: isLandscape)
        } else {
            applyPhoneLayout(isLandscape: isLandscape)
        }
    }
    
    func applyPadLayout(isLandscape: Bool) {
        let config = LayoutConfig(buttonWidth: isLandscape ? 450 : 500, buttonHeight: 75, utilityHeight: 60, startY: (isLandscape ? view.bounds.height * 0.25 : view.bounds.height * 0.30) - 50, spacing: 20)
        applyLayout(config)
        
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        tutorialResetButton.frame = CGRect(x: view.bounds.width - 70, y: safeTop + 10, width: 50, height: 50)
        tutorialResetButton.layer.cornerRadius = 25
    }
    
    func applyPhoneLayout(isLandscape: Bool) {
        let config = LayoutConfig(buttonWidth: min(view.bounds.width - 80, 400), buttonHeight: isLandscape ? 65 : 70, utilityHeight: isLandscape ? 50 : 55, startY: (isLandscape ? view.bounds.height * 0.15 : view.bounds.height * 0.35) - 50, spacing: isLandscape ? 15 : 18)
        applyLayout(config)
        
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        tutorialResetButton.frame = CGRect(x: view.bounds.width - 60, y: safeTop + 10, width: 40, height: 40)
        tutorialResetButton.layer.cornerRadius = 20
    }
    
    func applyLayout(_ config: LayoutConfig) {
        let baseY = config.startY
        let mainButtonSpacing = config.buttonHeight + config.spacing
        let utilityStartY = baseY + mainButtonSpacing * 2 + 10
        let utilitySpacing = config.utilityHeight + config.spacing - 5
        
        repositionButton(modeOneButton, width: config.buttonWidth, height: config.buttonHeight, yPosition: baseY)
        repositionButton(modeTwoButton, width: config.buttonWidth, height: config.buttonHeight, yPosition: baseY + mainButtonSpacing)
        repositionButton(recordsButton, width: config.buttonWidth, height: config.utilityHeight, yPosition: utilityStartY)
        repositionButton(instructionsButton, width: config.buttonWidth, height: config.utilityHeight, yPosition: utilityStartY + utilitySpacing)
        repositionButton(feedbackButton, width: config.buttonWidth, height: config.utilityHeight, yPosition: utilityStartY + utilitySpacing * 2)
        repositionButton(aboutButton, width: config.buttonWidth, height: config.utilityHeight, yPosition: utilityStartY + utilitySpacing * 3)
    }
    
    func repositionButton(_ button: UIButton, width: CGFloat, height: CGFloat, yPosition: CGFloat) {
        button.frame = CGRect(x: (view.bounds.width - width) / 2, y: yPosition, width: width, height: height)
        
        if let gradientLayer = button.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = button.bounds
        }
    }
    
    struct LayoutConfig {
        let buttonWidth: CGFloat
        let buttonHeight: CGFloat
        let utilityHeight: CGFloat
        let startY: CGFloat
        let spacing: CGFloat
    }
}
