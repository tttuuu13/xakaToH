//
//  CreateExamView.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import UIKit

protocol CreateExamViewDelegate {
    func createExam()
    func addStudents()
}

class CreateExamView: UIView {
    
    // MARK: - public
    var delegate: CreateExamViewDelegate? {
        didSet {
            configureButtons()
        }
    }
    
    // MARK: - UI
    private let examNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название экзамена"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }()
    
    private let createExamButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать экзамен", for: .normal)
        return button
    }()

    private let addStudentsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить студентов", for: .normal)
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
        addSubview(examNameTextField)
        addSubview(createExamButton)
        addSubview(addStudentsButton)
        addSubview(tableView)

        backgroundColor = .systemBackground
        
        // Поле для названия экзамена
        examNameTextField.pinTop(to: self.safeAreaLayoutGuide.topAnchor, 10)
        examNameTextField.pinHorizontal(to: self, 16)
        examNameTextField.setHeight(44)
        
        // Кнопки
        createExamButton.pinTop(to: examNameTextField.bottomAnchor, 10)
        createExamButton.pinRight(to: self.safeAreaLayoutGuide.trailingAnchor, 16)

        addStudentsButton.pinTop(to: examNameTextField.bottomAnchor, 10)
        addStudentsButton.pinLeft(to: self.safeAreaLayoutGuide.leadingAnchor, 16)
        addStudentsButton.pinRight(to: createExamButton.leadingAnchor, -10)

        // Таблица
        tableView.pinTop(to: createExamButton.bottomAnchor, 10)
        tableView.pinHorizontal(to: self, 10)
        tableView.pinBottom(to: self.safeAreaLayoutGuide.bottomAnchor, 5)
    }
    
    private func configureButtons() {
        createExamButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.createExam()
        }, for: .touchUpInside)
        
        addStudentsButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.addStudents()
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
    
    func updateAddStudentsButtonTitle(_ title: String) {
        addStudentsButton.setTitle(title, for: .normal)
    }
    
    func getExamName() -> String {
        return examNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    func setExamName(_ name: String) {
        examNameTextField.text = name
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
