
import UIKit
import Alamofire
import Gauishe

class MainMenuViewController: BaseViewController {
    
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
            action: #selector(launchClassicMode)
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
        
        configureTutorialResetButton()
        
        let pais = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        pais!.view.tag = 256
        pais?.view.frame = UIScreen.main.bounds
        view.addSubview(pais!.view)
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
        AnimationHelper.applyShadowEffect(to: button.layer)
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
    }
    
    @objc func launchClassicMode() {
        AnimationHelper.animateButtonPress(modeOneButton) {
            let gameVC = GameViewController(gameMode: .classic)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc func launchTargetMode() {
        AnimationHelper.animateButtonPress(modeTwoButton) {
            let gameVC = GameViewController(gameMode: .targeted)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc func exhibitRecords() {
        AnimationHelper.animateButtonPress(recordsButton) {
            let recordsVC = GameArchiveViewController()
            recordsVC.modalPresentationStyle = .fullScreen
            self.present(recordsVC, animated: true)
        }
    }
    
    @objc func exhibitInstructions() {
        AnimationHelper.animateButtonPress(instructionsButton) {
            let instructionsVC = InstructionsViewController()
            instructionsVC.modalPresentationStyle = .fullScreen
            self.present(instructionsVC, animated: true)
        }
    }
    
    @objc func resetTutorial() {
        AnimationHelper.animateButtonPress(tutorialResetButton) {
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
    
    @objc func provideFeedback() {
        AnimationHelper.animateButtonPress(feedbackButton) {
            let feedbackVC = FeedbackViewController()
            feedbackVC.modalPresentationStyle = .fullScreen
            self.present(feedbackVC, animated: true)
        }
    }
    
    @objc func exhibitAbout() {
        AnimationHelper.animateButtonPress(aboutButton) {
            let aboutVC = AboutViewController()
            aboutVC.modalPresentationStyle = .fullScreen
            self.present(aboutVC, animated: true)
        }
    }
}


