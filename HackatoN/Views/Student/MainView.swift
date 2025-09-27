//
//  MainView.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit

final class MainView: UIView {
    
    // MARK: - Public
    weak var delegate: MainViewDelegate?
    
    // MARK: - UI
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Добро пожаловать!"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(welcomeLabel)
        addSubview(tableView)
        
        welcomeLabel.pinTop(to: self.safeAreaLayoutGuide.topAnchor, 12)
        welcomeLabel.pinHorizontal(to: self, 12)
        
        tableView.pinTop(to: welcomeLabel.bottomAnchor, 12)
        tableView.pinHorizontal(to: self, 12)
        tableView.pinBottom(to: self, 12)
    }
    
    // MARK: - Public API
    func configureTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        tableView.register(ExamsListCell.self, forCellReuseIdentifier: ExamsListCell.reuseIdentifier)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

