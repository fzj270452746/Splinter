//
//  AppraisalViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class AppraisalViewController: VantageViewController {
    
    let titleLabel = UILabel()
    let starRatingView = StellarAppraisalWidget()
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
        
        titleLabel.text = "Rate & Feedback"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 20, y: safeTop + 20, width: view.bounds.width - 40, height: 50)
        KineticOrchestrator.applyShadowEffect(to: titleLabel.layer)
        view.addSubview(titleLabel)
        
        let ratingLabel = UILabel()
        ratingLabel.text = "How do you like this game?"
        ratingLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .center
        ratingLabel.frame = CGRect(x: 20, y: safeTop + 90, width: view.bounds.width - 40, height: 30)
        view.addSubview(ratingLabel)
        
        starRatingView.frame = CGRect(x: (view.bounds.width - 250) / 2, y: safeTop + 135, width: 250, height: 50)
        view.addSubview(starRatingView)
        
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
        
        submitButton.frame = CGRect(x: 30, y: safeTop + 450, width: view.bounds.width - 60, height: 55)
        submitButton.setTitle("Submit Feedback", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        submitButton.backgroundColor = UIColor.compatibleCyan
        submitButton.layer.cornerRadius = 12
        submitButton.addTarget(self, action: #selector(submitFeedback), for: .touchUpInside)
        view.addSubview(submitButton)
        
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
        
        saveFeedbackLocally(rating: rating, text: feedbackText)
        
        let thankYouAlert = UIAlertController(title: "Thank You! 🎉", message: "Your feedback has been received. We appreciate your support!", preferredStyle: .alert)
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


    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForDevice()
    }
    
    func adjustLayoutForDevice() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let safeTop = view.safeAreaInsets.top > 0 ? view.safeAreaInsets.top : 40
        
        if isPad {
            applyPadLayout(safeTop: safeTop)
        } else {
            applyPhoneLayout(safeTop: safeTop)
        }
    }
    
    func applyPadLayout(safeTop: CGFloat) {
        let maxWidth: CGFloat = 600
        let horizontalInset = (view.bounds.width - maxWidth) / 2
        
        titleLabel.frame = CGRect(x: horizontalInset, y: safeTop + 20, width: maxWidth, height: 50)
        
        let ratingLabel = view.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "How do you like this game?" } as? UILabel
        ratingLabel?.frame = CGRect(x: horizontalInset, y: safeTop + 90, width: maxWidth, height: 30)
        
        starRatingView.frame = CGRect(x: (view.bounds.width - 300) / 2, y: safeTop + 135, width: 300, height: 60)
        
        let feedbackLabel = view.subviews.first { $0 is UILabel && ($0 as! UILabel).text?.contains("thoughts") == true } as? UILabel
        feedbackLabel?.frame = CGRect(x: horizontalInset + 10, y: safeTop + 220, width: maxWidth - 20, height: 25)
        
        feedbackTextView.frame = CGRect(x: horizontalInset + 10, y: safeTop + 255, width: maxWidth - 20, height: 200)
        placeholderLabel.frame = CGRect(x: horizontalInset + 26, y: safeTop + 267, width: maxWidth - 52, height: 25)
        
        submitButton.frame = CGRect(x: horizontalInset + 10, y: safeTop + 480, width: maxWidth - 20, height: 60)
        
        withdrawButton.frame = CGRect(x: horizontalInset, y: safeTop + 10, width: 55, height: 55)
        withdrawButton.layer.cornerRadius = 27.5
    }
    
    func applyPhoneLayout(safeTop: CGFloat) {
        titleLabel.frame = CGRect(x: 20, y: safeTop + 20, width: view.bounds.width - 40, height: 50)
        
        let ratingLabel = view.subviews.first { $0 is UILabel && ($0 as! UILabel).text == "How do you like this game?" } as? UILabel
        ratingLabel?.frame = CGRect(x: 20, y: safeTop + 90, width: view.bounds.width - 40, height: 30)
        
        starRatingView.frame = CGRect(x: (view.bounds.width - 250) / 2, y: safeTop + 135, width: 250, height: 50)
        
        let feedbackLabel = view.subviews.first { $0 is UILabel && ($0 as! UILabel).text?.contains("thoughts") == true } as? UILabel
        feedbackLabel?.frame = CGRect(x: 30, y: safeTop + 210, width: view.bounds.width - 60, height: 25)
        
        feedbackTextView.frame = CGRect(x: 30, y: safeTop + 245, width: view.bounds.width - 60, height: 180)
        placeholderLabel.frame = CGRect(x: 46, y: safeTop + 257, width: view.bounds.width - 92, height: 25)
        
        submitButton.frame = CGRect(x: 30, y: safeTop + 450, width: view.bounds.width - 60, height: 55)
        
        withdrawButton.frame = CGRect(x: 20, y: safeTop + 10, width: 50, height: 50)
        withdrawButton.layer.cornerRadius = 25
    }
}

extension AppraisalViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

class StellarAppraisalWidget: UIView {
    
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

