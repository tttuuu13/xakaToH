//
//  CreateExamTableHeader.swift
//  HackatoN
//
//  Created by Nick on 26.09.2025.
//

import UIKit

protocol CreateExamTableHeaderDelegate: AnyObject {
    func didTitleChange(in sectionId: UUID, to newTitle: String)
    func didDeleteTapped(in sectionId: UUID)
}

class CreateExamTableHeader: UITableViewHeaderFooterView {
    
    // MARK: - properties
    static let reuseIdentifier: String = "CreateExamTableHeader"
    var delegate: CreateExamTableHeaderDelegate?
    private(set) var sectionId: UUID?
    
    // MARK: - UI
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Введите название секции вопросов:"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let title: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 17, weight: .medium)
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    private let deleteSectionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Удалить секцию", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
        title.delegate = self
        deleteSectionButton.addTarget(self, action: #selector(deleteSection), for: .touchUpInside)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configuration
    private func configureUI() {
        contentView.addSubview(stackView)
        stackView.pin(to: contentView)
        [label, title, deleteSectionButton].forEach { stackView.addArrangedSubview($0) }
    }

    func configure(sectionId: UUID, text: String) {
        self.sectionId = sectionId
        title.text = text
    }
    
    func updateSectionIndex(_ newId: UUID) {
        self.sectionId = newId
    }
    
    // MARK: - actions
    @objc
    private func deleteSection() {
        guard let section = self.sectionId else { return }
        delegate?.didDeleteTapped(in: section)
    }
}

extension CreateExamTableHeader: UITextViewDelegate {
    private func parentTableView() -> UITableView? {
        var view = self.superview
        while let current = view {
            if let tableView = current as? UITableView {
                return tableView
            }
            view = current.superview
        }
        return nil
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let section = self.sectionId {
            delegate?.didTitleChange(in: section, to: textView.text)
        }
        if let tableView = self.superview as? UITableView {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
}
