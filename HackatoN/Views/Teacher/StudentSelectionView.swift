//
//  StudentSelectionView.swift
//  HackatoN
//
//  Created by Nick on 27.09.2025.
//

import UIKit

protocol StudentSelectionViewDelegate: AnyObject {
    func studentSelectionViewDidTapDone(_ view: StudentSelectionView)
    func studentSelectionViewDidTapCancel(_ view: StudentSelectionView)
}

class StudentSelectionView: UIView {
    
    // MARK: - Properties
    weak var delegate: StudentSelectionViewDelegate?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите студентов"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private let selectedCountLabel: UILabel = {
        let label = UILabel()
        label.text = "Выбрано: 0 студентов"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
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
        
        // Header view
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        headerView.addSubview(cancelButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(doneButton)
        
        addSubview(headerView)
        addSubview(selectedCountLabel)
        addSubview(tableView)
        
        // Setup constraints
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        selectedCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Header view
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Cancel button
            cancelButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Title label
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Done button
            doneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Selected count label
            selectedCountLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            selectedCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            selectedCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: selectedCountLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Add separator line
        let separatorView = UIView()
        separatorView.backgroundColor = .separator
        headerView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        setupActions()
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        delegate?.studentSelectionViewDidTapCancel(self)
    }
    
    @objc private func doneButtonTapped() {
        delegate?.studentSelectionViewDidTapDone(self)
    }
    
    // MARK: - Public Methods
    func updateSelectedCount(_ count: Int) {
        let text = count == 1 ? "Выбран 1 студент" : "Выбрано \(count) студентов"
        selectedCountLabel.text = text
    }
    
    func configureTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        tableView.register(StudentSelectionCell.self, forCellReuseIdentifier: StudentSelectionCell.reuseIdentifier)
    }
}
