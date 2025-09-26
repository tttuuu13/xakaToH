//
//  CreateExamView.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import UIKit

protocol CreateExamViewDelegate {
    func createExam()
}

class CreateExamView: UIView {
    
    // MARK: - public
    var delegate: CreateExamViewDelegate? {
        didSet {
            configureButtons()
        }
    }
    
    // MARK: - UI
    private let createExamButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать экзамен", for: .normal)
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
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
    
    // MARK: - setup
    private func setupUI() {
        addSubview(createExamButton)
        addSubview(tableView)
        
        backgroundColor = .systemBackground
        
        createExamButton.pinTop(to: self.safeAreaLayoutGuide.topAnchor, 5)
        createExamButton.pinRight(to: self.safeAreaLayoutGuide.trailingAnchor, 5)
        
        tableView.pinTop(to: createExamButton.bottomAnchor, 5)
        tableView.pinHorizontal(to: self, 10)
        tableView.pinBottom(to: self.safeAreaLayoutGuide.bottomAnchor, 5)
    }
    
    private func configureButtons() {
        createExamButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.createExam()
        }, for: .touchUpInside)
    }
    
    // MARK: - public API
    func configureTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        tableView.register(EditableTextQuestionCell.self, forCellReuseIdentifier: EditableTextQuestionCell.reuseIdentifier)
        tableView.register(EditableMCQuestionCell.self, forCellReuseIdentifier: EditableMCQuestionCell.reuseIdentifier)
        tableView.register(CreateExamTableFooter.self, forHeaderFooterViewReuseIdentifier: CreateExamTableFooter.reuseIdentifier)
        tableView.register(CreateExamTableHeader.self, forHeaderFooterViewReuseIdentifier: CreateExamTableHeader.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }
}

extension CreateExamView {
    func visibleHeaderViews() -> [CreateExamTableHeader] {
        var headers: [CreateExamTableHeader] = []
        for section in 0..<tableView.numberOfSections {
            if let header = tableView.headerView(forSection: section) as? CreateExamTableHeader {
                headers.append(header)
            }
        }
        return headers
    }
    
    func visibleFooterViews() -> [CreateExamTableFooter] {
        var footers: [CreateExamTableFooter] = []
        for section in 0..<tableView.numberOfSections {
            if let footer = tableView.footerView(forSection: section) as? CreateExamTableFooter {
                footers.append(footer)
            }
        }
        return footers
    }
}
