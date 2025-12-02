//
//  FeedbackViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class FeedbackViewController: BaseViewController {
    
    let titleLabel = UILabel()
    let starRatingView = StarRatingView()
    let feedbackTextView = UITextView()
    let placeholderLabel = UILabel()
    let submitButton = UIButton()
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
        configureUI()
        configureTapGesture()
    }
    
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func configureUI() {
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        
        // 标题
        titleLabel.text = "Rate & Feedback"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 20, y: safeTop + 20, width: view.bounds.width - 40, height: 50)
        AnimationHelper.applyShadowEffect(to: titleLabel.layer)
        view.addSubview(titleLabel)
        
        // 星级评分
        let ratingLabel = UILabel()
        ratingLabel.text = "How do you like this game?"
        ratingLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .center
        ratingLabel.frame = CGRect(x: 20, y: safeTop + 90, width: view.bounds.width - 40, height: 30)
        view.addSubview(ratingLabel)
        
        starRatingView.frame = CGRect(x: (view.bounds.width - 250) / 2, y: safeTop + 135, width: 250, height: 50)
        view.addSubview(starRatingView)
        
        // 反馈文本框
        let feedbackLabel = UILabel()
        feedbackLabel.text = "Tell us your thoughts (optional):"
        feedbackLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        feedbackLabel.textColor = .white
        feedbackLabel.frame = CGRect(x: 30, y: safeTop + 210, width: view.bounds.width - 60, height: 25)
        view.addSubview(feedbackLabel)
        
        feedbackTextView.frame = CGRect(x: 30, y: safeTop + 245, width: view.bounds.width - 60, height: 180)
        feedbackTextView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        feedbackTextView.textColor = .white
        feedbackTextView.font = UIFont.systemFont(ofSize: 16)
        feedbackTextView.layer.cornerRadius = 12
        feedbackTextView.layer.borderWidth = 2
        feedbackTextView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        feedbackTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        feedbackTextView.delegate = self
        view.addSubview(feedbackTextView)
        
        placeholderLabel.text = "Share your experience..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        placeholderLabel.frame = CGRect(x: 46, y: safeTop + 257, width: view.bounds.width - 92, height: 25)
        view.addSubview(placeholderLabel)
        
        // 提交按钮
        submitButton.frame = CGRect(x: 30, y: safeTop + 450, width: view.bounds.width - 60, height: 55)
        submitButton.setTitle("Submit Feedback", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        submitButton.backgroundColor = UIColor.compatibleCyan
        submitButton.layer.cornerRadius = 12
        submitButton.addTarget(self, action: #selector(submitFeedback), for: .touchUpInside)
        view.addSubview(submitButton)
        
        // 返回按钮
        withdrawButton.frame = CGRect(x: 20, y: safeTop + 10, width: 50, height: 50)
        withdrawButton.setTitle("←", for: .normal)
        withdrawButton.setTitleColor(.white, for: .normal)
        withdrawButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        withdrawButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        withdrawButton.layer.cornerRadius = 25
        withdrawButton.layer.borderWidth = 2
        withdrawButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        withdrawButton.addTarget(self, action: #selector(withdrawAction), for: .touchUpInside)
        view.addSubview(withdrawButton)
    }
    
    @objc func submitFeedback() {
        let rating = starRatingView.currentRating
        let feedbackText = feedbackTextView.text ?? ""
        
        if rating == 0 {
            let alert = UIAlertController(title: "Rating Required", message: "Please select a star rating before submitting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 保存反馈到本地
        saveFeedbackLocally(rating: rating, text: feedbackText)
        
        // 显示感谢提示
        let thankYouAlert = UIAlertController(
            title: "Thank You! 🎉",
            message: "Your feedback has been received. We appreciate your support!",
            preferredStyle: .alert
        )
        thankYouAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(thankYouAlert, animated: true)
    }
    
    func saveFeedbackLocally(rating: Int, text: String) {
        let feedback: [String: Any] = [
            "rating": rating,
            "text": text,
            "timestamp": Date().timeIntervalSince1970,
            "version": AppInfo.version
        ]
        
        var allFeedbacks = UserDefaults.standard.array(forKey: "MahjongSplinter_Feedbacks") as? [[String: Any]] ?? []
        allFeedbacks.append(feedback)
        UserDefaults.standard.set(allFeedbacks, forKey: "MahjongSplinter_Feedbacks")
    }
}

extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

class StarRatingView: UIView {
    
    var currentRating: Int = 0 {
        didSet {
            updateStarAppearance()
        }
    }
    
    let starButtons: [UIButton] = (0..<5).map { _ in UIButton() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureStars() {
        // 等待布局完成后再配置
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateStarPositions()
    }
    
    func updateStarPositions() {
        let starSize: CGFloat = 50
        let totalStars: CGFloat = 5
        let totalStarWidth = starSize * totalStars
        let availableSpacing = bounds.width - totalStarWidth
        let spacing = availableSpacing / (totalStars + 1)
        
        for (index, button) in starButtons.enumerated() {
            let xPosition = spacing + CGFloat(index) * (starSize + spacing)
            button.frame = CGRect(x: xPosition, y: (bounds.height - starSize) / 2, width: starSize, height: starSize)
            
            if button.titleLabel?.text == nil {
                button.setTitle("☆", for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
                button.tag = index + 1
                button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
                if button.superview == nil {
                    addSubview(button)
                }
            }
        }
    }
    
    @objc func starTapped(_ sender: UIButton) {
        currentRating = sender.tag
        
        // 点击动画
        UIView.animate(withDuration: 0.2) {
            sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        }
    }
    
    func updateStarAppearance() {
        for (index, button) in starButtons.enumerated() {
            let isFilled = index < currentRating
            button.setTitle(isFilled ? "★" : "☆", for: .normal)
            button.setTitleColor(isFilled ? .yellow : .white, for: .normal)
        }
    }
}

