//
//  BaseViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class BaseViewController: UIViewController {
    
    let backgroundImageView = UIImageView()
    let overlayView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backgroundImageView.frame = view.bounds
        overlayView.frame = view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func createWithdrawButton() -> UIButton {
        let button = UIButton()
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        button.frame = CGRect(x: 20, y: safeTop + 10, width: 50, height: 50)
        button.setTitle("←", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        button.addTarget(self, action: #selector(withdrawAction), for: .touchUpInside)
        return button
    }
    
    @objc func withdrawAction() {
        dismiss(animated: true)
    }
}

