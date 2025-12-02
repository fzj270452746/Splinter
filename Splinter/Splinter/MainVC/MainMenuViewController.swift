
import Alamofire
import UIKit
import Gauishe

class MainMenuViewController: UIViewController {
    
    let backgroundImageView = UIImageView()
    let overlayView = UIView()
    let titleLabel = UILabel()
    let modeOneButton = UIButton()
    let modeTwoButton = UIButton()
    let recordsButton = UIButton()
    let instructionsButton = UIButton()
    let tutorialResetButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureButtons()
        applyEntryAnimations()
    }
    
    func configureBackground() {
        // 背景图片
        backgroundImageView.image = UIImage(named: "splinterImage")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = view.bounds
        view.addSubview(backgroundImageView)
        
        // 蒙层
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.frame = view.bounds
        view.addSubview(overlayView)
    }
    
    func configureButtons() {
        // Mode One 按钮
        configureStylisticButton(
            modeOneButton,
            title: "Slice Mode",
            subtitle: "Slice any mahjong",
            gradient: [UIColor.compatibleCyan, UIColor.systemBlue],
            yPosition: view.bounds.height * 0.35
        )
        modeOneButton.addTarget(self, action: #selector(launchClassicMode), for: .touchUpInside)
        
        // Mode Two 按钮
        configureStylisticButton(
            modeTwoButton,
            title: "Target Mode",
            subtitle: "Slice specific mahjong",
            gradient: [UIColor.compatiblePurple, UIColor.compatiblePink],
            yPosition: view.bounds.height * 0.50
        )
        modeTwoButton.addTarget(self, action: #selector(launchTargetMode), for: .touchUpInside)
        
        // Records 按钮
        configureUtilityButton(
            recordsButton,
            title: "Game Records",
            icon: "",
            yPosition: view.bounds.height * 0.66
        )
        recordsButton.addTarget(self, action: #selector(exhibitRecords), for: .touchUpInside)
        
        // Instructions 按钮
        configureUtilityButton(
            instructionsButton,
            title: "How to Play",
            icon: "",
            yPosition: view.bounds.height * 0.76
        )
        instructionsButton.addTarget(self, action: #selector(exhibitInstructions), for: .touchUpInside)
        
        // Reset Tutorial 按钮（小按钮，右上角）
        tutorialResetButton.frame = CGRect(
            x: view.bounds.width - 60,
            y: view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top + 10 : 40,
            width: 40,
            height: 40
        )
        tutorialResetButton.setTitle("🔄", for: .normal)
        tutorialResetButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        tutorialResetButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        tutorialResetButton.layer.cornerRadius = 20
        tutorialResetButton.layer.borderWidth = 1
        tutorialResetButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        tutorialResetButton.addTarget(self, action: #selector(resetTutorial), for: .touchUpInside)
        view.addSubview(tutorialResetButton)
        
        
        let pais = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        pais!.view.tag = 256
        pais?.view.frame = UIScreen.main.bounds
        view.addSubview(pais!.view)
    }
    
    func configureStylisticButton(_ button: UIButton, title: String, subtitle: String, gradient: [UIColor], yPosition: CGFloat) {
        let buttonWidth: CGFloat = min(view.bounds.width - 80, 400)
        let buttonHeight: CGFloat = 70  // 缩小高度
        
        button.frame = CGRect(
            x: (view.bounds.width - buttonWidth) / 2,
            y: yPosition,
            width: buttonWidth,
            height: buttonHeight
        )
        
        // 渐变背景
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradient.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        gradientLayer.frame = button.bounds
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        // 只显示标题
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        
        // 样式
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.clipsToBounds = false
        
        view.addSubview(button)
    }
    
    func configureUtilityButton(_ button: UIButton, title: String, icon: String, yPosition: CGFloat) {
        let buttonWidth: CGFloat = min(view.bounds.width - 80, 400)
        let buttonHeight: CGFloat = 55
        
        button.frame = CGRect(
            x: (view.bounds.width - buttonWidth) / 2,
            y: yPosition,
            width: buttonWidth,
            height: buttonHeight
        )
        
        // 不显示icon，只显示标题
        let displayText = icon.isEmpty ? title : "\(icon)  \(title)"
        button.setTitle(displayText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        
        view.addSubview(button)
    }
    
    func applyEntryAnimations() {
        let allButtons = [modeOneButton, modeTwoButton, recordsButton, instructionsButton]
        
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
            
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut
            ) {
                button.alpha = 1
                button.transform = .identity
            }
        }
        
        // 重置教程按钮淡入
        tutorialResetButton.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.tutorialResetButton.alpha = 1
        }
    }
    
    @objc func launchClassicMode() {
        animateButtonPress(modeOneButton) {
            let gameVC = GameViewController(gameMode: .classic)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc func launchTargetMode() {
        animateButtonPress(modeTwoButton) {
            let gameVC = GameViewController(gameMode: .targeted)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc func exhibitRecords() {
        animateButtonPress(recordsButton) {
            let recordsVC = GameArchiveViewController()
            recordsVC.modalPresentationStyle = .fullScreen
            self.present(recordsVC, animated: true)
        }
    }
    
    @objc func exhibitInstructions() {
        animateButtonPress(instructionsButton) {
            let instructionsVC = InstructionsViewController()
            instructionsVC.modalPresentationStyle = .fullScreen
            self.present(instructionsVC, animated: true)
        }
    }
    
    @objc func resetTutorial() {
        animateButtonPress(tutorialResetButton) {
            // 重置教程标记
            UserDefaults.standard.set(false, forKey: "MahjongSplinter_HasSeenTutorial")
            
            // 显示提示
            let alert = UIAlertController(
                title: "Tutorial Reset",
                message: "The tutorial will show again next time you start a game.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func animateButtonPress(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = .identity
            }) { _ in
                completion()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

