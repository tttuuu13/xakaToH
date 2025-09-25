//
//  AddQuestionCell.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import UIKit

protocol AddQuestionCellDelegate {
    func addTextQuestionButtonTapped(in section: Int)
    func addMCQuestionButtonTapped(in section: Int)
}

class AddQuestionCell: UITableViewCell {
    
    // MARK: - properties
    static let reuseIdentifier = "AddQuestionCell"
    var delegate: AddQuestionCellDelegate?
    private var section: Int?
    
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
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(addTextQuestionButton)
        contentView.addSubview(addMCQuestionButton)
        selectionStyle = .none
        
        addTextQuestionButton.pinVertical(to: contentView, 3)
        addMCQuestionButton.pinVertical(to: contentView, 3)
        
        addTextQuestionButton.pinLeft(to: contentView, 3)
        addMCQuestionButton.pinLeft(to: addTextQuestionButton.trailingAnchor, 5)
        addMCQuestionButton.pinRight(to: contentView, 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    // MARK: - public API
    func configure(with section: Int) {
        self.section = section
        addTextQuestionButton.addTarget(self, action: #selector(addTextQuestionButtonTapped), for: .touchUpInside)
        addMCQuestionButton.addTarget(self, action: #selector(addMCQuestionButtonTapped), for: .touchUpInside)
    }
}
