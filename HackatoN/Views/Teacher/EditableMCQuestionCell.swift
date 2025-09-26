//
//  EditableMCQuestionCell.swift
//  HackatoN
//
//  Created by Nick on 25.09.2025.
//

import UIKit

class EditableMCQuestionCell: UITableViewCell {
    
    // MARK: - properties
    static let reuseIdentifier = "EditableMCQuestionCell"
    var questionChanged: ((EditableQuestionProtocol) -> Void)?
    private var question: EditableMCQuestionModel?
    private var optionsTableViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Введите вопрос"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let questionTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .systemGray5
        textView.font = .systemFont(ofSize: 20, weight: .medium)
        return textView
    }()
    
    private let optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private let addOptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить вариант ответа", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        return button
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        optionsTableView.register(MCQuestionOptionEditCell.self, forCellReuseIdentifier: MCQuestionOptionEditCell.reuseIdentifier)
        
        addOptionButton.addTarget(self, action: #selector(addOption), for: .touchUpInside)
        questionTextView.delegate = self
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configuration
    private func configureUI() {
        contentView.addSubview(label)
        contentView.addSubview(questionTextView)
        contentView.addSubview(optionsTableView)
        contentView.addSubview(addOptionButton)
        
        label.pinTop(to: contentView, 3)
        label.pinHorizontal(to: contentView, 5)
        
        questionTextView.pinTop(to: label.bottomAnchor, 5)
        questionTextView.pinHorizontal(to: contentView, 5)
        
        optionsTableView.pinTop(to: questionTextView.bottomAnchor, 5)
        optionsTableView.pinHorizontal(to: contentView, 5)
        optionsTableView.backgroundColor = .systemBackground
        
        addOptionButton.pinTop(to: optionsTableView.bottomAnchor, 5)
        addOptionButton.pinHorizontal(to: contentView, 5)
        addOptionButton.pinBottom(to: contentView, 3)
        
        optionsTableViewHeightConstraint = optionsTableView.heightAnchor.constraint(equalToConstant: 0)
        optionsTableViewHeightConstraint?.isActive = true
        
        selectionStyle = .none
    }
    
    // MARK: - update tableView height
    private func updateOptionsTableViewHeight() {
        optionsTableView.layoutIfNeeded()
        optionsTableViewHeightConstraint?.constant = optionsTableView.contentSize.height
    }
    
    private func resizeOuterTableView() {
        updateOptionsTableViewHeight()
        guard let tableView = self.superview as? UITableView else { return }
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func configure(with question: EditableMCQuestionModel) {
        self.question = question
        questionTextView.text = question.question
        optionsTableView.reloadData()
        updateOptionsTableViewHeight()
    }
    
    // MARK: - actions
    @objc
    private func addOption() {
        guard var question = self.question else { return }
        question.options.append("")
        self.question = question
        questionChanged?(question)
        
        let newIndexPath = IndexPath(row: question.options.count - 1, section: 0)
        optionsTableView.beginUpdates()
        optionsTableView.insertRows(at: [newIndexPath], with: .automatic)
        optionsTableView.endUpdates()
        
        resizeOuterTableView()
    }
}

extension EditableMCQuestionCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        question?.options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MCQuestionOptionEditCell.reuseIdentifier, for: indexPath)
        guard let optionCell = cell as? MCQuestionOptionEditCell else { return cell }
        optionCell.configute(with: question?.options[indexPath.row] ?? "")
        optionCell.optionChanged = { [weak self] newOption in
            guard var question = self?.question else { return }
            question.options[indexPath.row] = newOption
            self?.question = question
            self?.questionChanged?(question)
        }
        optionCell.needResizeOuterTableView = { [weak self] in
            self?.resizeOuterTableView()
        }
        return optionCell
    }
}

extension EditableMCQuestionCell: UITableViewDelegate {
    
}

extension EditableMCQuestionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard var question = question else { return }
        question.question = textView.text
        self.question = question
        questionChanged?(question)
        
        if let tableView = superview as? UITableView {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
}
