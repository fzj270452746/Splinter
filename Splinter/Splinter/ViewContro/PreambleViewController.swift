//
//  PreambleViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class PreambleViewController: VantageViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let withdrawButton: UIButton
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.withdrawButton = UIButton()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollView()
        configureContent()
        configureWithdrawButton()
    }
    
    func configureScrollView() {
        scrollView.frame = CGRect(x: 20, y: 60, width: view.bounds.width - 40, height: view.bounds.height - 160)
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: 0)
        scrollView.addSubview(contentView)
    }
    
    func configureContent() {
        var yOffset: CGFloat = 40
        
        // App图标
        let iconImageView = UIImageView(image: UIImage(named: "all 5"))
        iconImageView.frame = CGRect(x: (contentView.bounds.width - 100) / 2, y: yOffset, width: 100, height: 145)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 20
        iconImageView.clipsToBounds = true
        iconImageView.layer.borderWidth = 3
        iconImageView.layer.borderColor = UIColor.white.cgColor
        contentView.addSubview(iconImageView)
        yOffset += 165
        
        yOffset = addCenteredLabel(AppInfo.appName, fontSize: 36, color: .white, bold: true, at: yOffset)
        yOffset = addCenteredLabel(AppInfo.fullVersion, fontSize: 18, color: UIColor.white.withAlphaComponent(0.8), bold: false, at: yOffset - 10)
        
        yOffset += 20
        addDivider(at: yOffset)
        yOffset += 30
        
        yOffset = addSectionTitle("📱 About This App", at: yOffset)
        yOffset = addDescriptionText("Mahjong Splinter is an exciting and addictive tile-slicing game that combines traditional mahjong elements with fast-paced action gameplay.\n\nSwipe your finger to slice falling mahjong tiles, earn points, and challenge yourself to achieve the highest score!", at: yOffset)
        
        yOffset = addSectionTitle("✨ Features", at: yOffset)
        yOffset = addDescriptionText("• Two exciting game modes\n• Beautiful visual effects\n• Smooth animations and controls\n• Game records tracking\n• iPad support\n• Offline gameplay", at: yOffset)
        
        addDivider(at: yOffset)
        yOffset += 30
        
        yOffset = addSectionTitle("🛠 Technical Info", at: yOffset)
        yOffset = addDescriptionText("Built with Swift and UIKit\nMinimum iOS: 14.0\nCompatible with iPhone and iPad", at: yOffset)
        
        yOffset = addSectionTitle("❤️ Thank You", at: yOffset)
        yOffset = addDescriptionText("Thank you for playing Mahjong Splinter! We hope you enjoy this game.\n\nFor support or suggestions, please use the Rate & Feedback button on the main menu.", at: yOffset)
        
        contentView.frame.size.height = yOffset + 40
        scrollView.contentSize = contentView.frame.size
    }
    
    func addCenteredLabel(_ text: String, fontSize: CGFloat, color: UIColor, bold: Bool, at yOffset: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.textColor = color
        label.textAlignment = .center
        label.numberOfLines = 0
        label.frame = CGRect(x: 20, y: yOffset, width: contentView.bounds.width - 40, height: 0)
        label.sizeToFit()
        label.frame.size.width = contentView.bounds.width - 40
        
        if bold {
            KineticOrchestrator.applyShadowEffect(to: label.layer)
        }
        
        contentView.addSubview(label)
        return yOffset + label.frame.height + 20
    }
    
    func addSectionTitle(_ title: String, at yOffset: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .compatibleCyan
        label.frame = CGRect(x: 20, y: yOffset, width: contentView.bounds.width - 40, height: 30)
        contentView.addSubview(label)
        return yOffset + 40
    }
    
    func addDescriptionText(_ text: String, at yOffset: CGFloat) -> CGFloat {
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
    
    func addDivider(at yOffset: CGFloat) {
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        divider.frame = CGRect(x: 40, y: yOffset, width: contentView.bounds.width - 80, height: 1)
        contentView.addSubview(divider)
    }
    
    func configureWithdrawButton() {
        withdrawButton.frame = CGRect(x: (view.bounds.width - 150) / 2, y: view.bounds.height - 80, width: 150, height: 50)
        withdrawButton.setTitle("← Back", for: .normal)
        withdrawButton.setTitleColor(.white, for: .normal)
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        withdrawButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        withdrawButton.layer.cornerRadius = 12
        withdrawButton.layer.borderWidth = 2
        withdrawButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        withdrawButton.addTarget(self, action: #selector(withdrawAction), for: .touchUpInside)
        view.addSubview(withdrawButton)
    }
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForDevice()
    }
    
    func adjustLayoutForDevice() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        let safeBottom = view.safeAreaInsets.bottom > 0 ? view.safeAreaInsets.bottom : 20
        
        if isPad {
            applyPadLayout(safeTop: safeTop, safeBottom: safeBottom)
        } else {
            applyPhoneLayout(safeTop: safeTop, safeBottom: safeBottom)
        }
        
        recalculateContentHeight()
    }
    
    func applyPadLayout(safeTop: CGFloat, safeBottom: CGFloat) {
        let maxWidth: CGFloat = 700
        let horizontalInset = (view.bounds.width - maxWidth) / 2
        
        scrollView.frame = CGRect(x: horizontalInset, y: safeTop + 20, width: maxWidth, height: view.bounds.height - safeTop - safeBottom - 120)
        contentView.frame.size.width = maxWidth
        withdrawButton.frame = CGRect(x: (view.bounds.width - 180) / 2, y: view.bounds.height - safeBottom - 80, width: 180, height: 55)
    }
    
    func applyPhoneLayout(safeTop: CGFloat, safeBottom: CGFloat) {
        scrollView.frame = CGRect(x: 20, y: safeTop + 20, width: view.bounds.width - 40, height: view.bounds.height - safeTop - safeBottom - 120)
        contentView.frame.size.width = view.bounds.width - 40
        withdrawButton.frame = CGRect(x: (view.bounds.width - 150) / 2, y: view.bounds.height - safeBottom - 70, width: 150, height: 50)
    }
    
    func recalculateContentHeight() {
        var maxY: CGFloat = 0
        for subview in contentView.subviews {
            let bottom = subview.frame.maxY
            if bottom > maxY { maxY = bottom }
        }
        contentView.frame.size.height = maxY + 20
        scrollView.contentSize = contentView.frame.size
    }
}
