//
//  GameArchiveViewController.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import UIKit

class GameArchiveViewController: BaseViewController {
    
    let titleLabel = UILabel()
    let tableView = UITableView()
    let emptyStateLabel = UILabel()
    let withdrawButton: UIButton
    let obliterateAllButton = UIButton()
    
    var archives: [GameArchive] = []
    
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
        retrieveArchives()
    }
    
    func configureUI() {
        configureLabelWithShadow(titleLabel, text: "Game Records", fontSize: 32, frame: CGRect(x: 20, y: 60, width: view.bounds.width - 40, height: 50))
        
        tableView.frame = CGRect(x: 20, y: 130, width: view.bounds.width - 40, height: view.bounds.height - 260)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArchiveTableCell.self, forCellReuseIdentifier: "ArchiveCell")
        view.addSubview(tableView)
        
        emptyStateLabel.text = "No game records yet.\nStart playing to see your scores here!"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.frame = tableView.frame
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        
        obliterateAllButton.frame = CGRect(x: 20, y: view.bounds.height - 140, width: view.bounds.width - 40, height: 50)
        obliterateAllButton.setTitle("Clear All Records", for: .normal)
        obliterateAllButton.setTitleColor(.white, for: .normal)
        obliterateAllButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        obliterateAllButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        obliterateAllButton.layer.cornerRadius = 12
        obliterateAllButton.addTarget(self, action: #selector(obliterateAllArchives), for: .touchUpInside)
        view.addSubview(obliterateAllButton)
        
        withdrawButton.frame = CGRect(x: 20, y: view.bounds.height - 80, width: 120, height: 50)
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
    
    func configureLabelWithShadow(_ label: UILabel, text: String, fontSize: CGFloat, frame: CGRect) {
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textColor = .white
        label.textAlignment = .center
        label.frame = frame
        AnimationHelper.applyShadowEffect(to: label.layer)
        view.addSubview(label)
    }
    
    func retrieveArchives() {
        archives = GameArchiveRepository.shared.retrieveAllArchives()
        tableView.reloadData()
        emptyStateLabel.isHidden = !archives.isEmpty
        obliterateAllButton.isHidden = archives.isEmpty
    }
    
    @objc func obliterateAllArchives() {
        let alert = UIAlertController(title: "Clear All Records", message: "Are you sure you want to delete all game records? This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            GameArchiveRepository.shared.eradicateAllArchives()
            self?.retrieveArchives()
        })
        present(alert, animated: true)
    }
}

extension GameArchiveViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archives.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveCell", for: indexPath) as! ArchiveTableCell
        cell.configureWithArchive(archives[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            GameArchiveRepository.shared.obliterateArchive(identifier: archives[indexPath.row].identifier)
            retrieveArchives()
        }
    }
}

class ArchiveTableCell: UITableViewCell {
    
    let containerView = UIView()
    let scoreLabel = UILabel()
    let modeLabel = UILabel()
    let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        contentView.addSubview(containerView)
        
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 28)
        scoreLabel.textColor = .compatibleCyan
        containerView.addSubview(scoreLabel)
        
        modeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        modeLabel.textColor = .white
        containerView.addSubview(modeLabel)
        
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        dateLabel.textAlignment = .right
        containerView.addSubview(dateLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = CGRect(x: 0, y: 5, width: contentView.bounds.width, height: contentView.bounds.height - 10)
        scoreLabel.frame = CGRect(x: 20, y: 10, width: 100, height: 35)
        modeLabel.frame = CGRect(x: 20, y: 45, width: 200, height: 20)
        dateLabel.frame = CGRect(x: containerView.bounds.width - 150, y: (containerView.bounds.height - 20) / 2, width: 130, height: 20)
    }
    
    func configureWithArchive(_ archive: GameArchive) {
        scoreLabel.text = "\(archive.obtainedScore)"
        modeLabel.text = archive.gameMode
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm"
        dateLabel.text = formatter.string(from: archive.chronologicalStamp)
    }
}

