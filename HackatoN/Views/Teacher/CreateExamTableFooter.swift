//
//  AddQuestionCell.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import UIKit

protocol CreateExamTableFooterDelegate {
    func addTextQuestionButtonTapped(in sectionId: UUID)
    func addMCQuestionButtonTapped(in sectionId: UUID)
    func addSectionButtonTapped()
}

class CreateExamTableFooter: UITableViewHeaderFooterView {
    
    // MARK: - properties
    static let reuseIdentifier = "AddQuestionCell"
    var delegate: CreateExamTableFooterDelegate?
    private(set) var section: UUID?
    var isLast: Bool = false {
        didSet {
            addSectionButton.isHidden = !isLast
        }
    }
    
    // MARK: - UI
    private let addTextQuestionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Текстовый вопрос", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let addMCQuestionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вопрос с вариантами ответа", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let addSectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить cекцию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 3
        return stackView
    }()
    
    // MARK: - init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
        addTextQuestionButton.addTarget(self, action: #selector(addTextQuestionButtonTapped), for: .touchUpInside)
        addMCQuestionButton.addTarget(self, action: #selector(addMCQuestionButtonTapped), for: .touchUpInside)
        addSectionButton.addTarget(self, action: #selector(addSectionButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configuration
    private func configureUI() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(addTextQuestionButton)
        stackView.addArrangedSubview(addMCQuestionButton)
        stackView.addArrangedSubview(addSectionButton)
        stackView.pin(to: contentView)
    }
    
    // MARK: - private
    @objc
    private func addTextQuestionButtonTapped() {
        guard let section = self.section else { return }
        self.delegate?.addTextQuestionButtonTapped(in: section)
    }
    
    @objc
    private func addMCQuestionButtonTapped() {
        guard let section = self.section else { return }
        self.delegate?.addMCQuestionButtonTapped(in: section)
    }
    
    @objc
    private func addSectionButtonTapped() {
        self.delegate?.addSectionButtonTapped()
    }
    
    // MARK: - public API
    func configure(with sectionId: UUID) {
        self.section = sectionId
    }
}
