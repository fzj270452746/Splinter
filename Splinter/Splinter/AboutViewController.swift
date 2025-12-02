//
//  AboutViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class AboutViewController: BaseViewController {
    
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
        
        // App图标（使用麻将图片）
        let iconImageView = UIImageView(image: UIImage(named: "all 5"))
        iconImageView.frame = CGRect(x: (contentView.bounds.width - 100) / 2, y: yOffset, width: 100, height: 145)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.layer.cornerRadius = 20
        iconImageView.clipsToBounds = true
        iconImageView.layer.borderWidth = 3
        iconImageView.layer.borderColor = UIColor.white.cgColor
        contentView.addSubview(iconImageView)
        yOffset += 165
        
        // App名称
        yOffset = addCenteredLabel(AppInfo.appName, fontSize: 36, color: .white, bold: true, at: yOffset)
        
        // 版本号
        yOffset = addCenteredLabel(AppInfo.fullVersion, fontSize: 18, color: UIColor.white.withAlphaComponent(0.8), bold: false, at: yOffset - 10)
        
        // 分隔线
        yOffset += 20
        let divider1 = UIView()
        divider1.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        divider1.frame = CGRect(x: 40, y: yOffset, width: contentView.bounds.width - 80, height: 1)
        contentView.addSubview(divider1)
        yOffset += 30
        
        // 应用描述
        yOffset = addSectionTitle("📱 About This App", at: yOffset)
        yOffset = addDescriptionText(
            "Mahjong Splinter is an exciting and addictive tile-slicing game that combines traditional mahjong elements with fast-paced action gameplay.\n\nSwipe your finger to slice falling mahjong tiles, earn points, and challenge yourself to achieve the highest score!",
            at: yOffset
        )
        
        // 特色功能
        yOffset = addSectionTitle("✨ Features", at: yOffset)
        yOffset = addDescriptionText(
            "• Two exciting game modes\n• Beautiful visual effects\n• Smooth animations and controls\n• Game records tracking\n• iPad support\n• Offline gameplay",
            at: yOffset
        )
        
        // 技术信息
        let divider2 = UIView()
        divider2.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        divider2.frame = CGRect(x: 40, y: yOffset, width: contentView.bounds.width - 80, height: 1)
        contentView.addSubview(divider2)
        yOffset += 30
        
        yOffset = addSectionTitle("🛠 Technical Info", at: yOffset)
        yOffset = addDescriptionText(
            "Built with Swift and UIKit\nMinimum iOS: 14.0\nCompatible with iPhone and iPad",
            at: yOffset
        )
        
        // 致谢
        yOffset = addSectionTitle("❤️ Thank You", at: yOffset)
        yOffset = addDescriptionText(
            "Thank you for playing Mahjong Splinter! We hope you enjoy this game.\n\nFor support or suggestions, please use the Rate & Feedback button on the main menu.",
            at: yOffset
        )
        
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
            AnimationHelper.applyShadowEffect(to: label.layer)
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
}

