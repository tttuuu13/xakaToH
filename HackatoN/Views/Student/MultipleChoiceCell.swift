//
//  MultipleChoiceCell.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//

import UIKit

class MultipleChoiceCell: UITableViewCell {
    
    static let reuseIdentifier = "MultipleChoiceCell"
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var buttons: [UIButton] = []
    private var isEditable: Bool = false
    
    var answerSelectionHandler: ((Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(questionLabel)
        contentView.addSubview(optionsStackView)
        
        selectionStyle = .none
        
        questionLabel.pinTop(to: contentView, 12)
        questionLabel.pinLeft(to: contentView, 16)
        questionLabel.pinRight(to: contentView, 16)
        
        optionsStackView.pinTop(to: questionLabel.bottomAnchor, 12)
        optionsStackView.pinLeft(to: contentView, 16)
        optionsStackView.pinRight(to: contentView, 16)
        optionsStackView.pinBottom(to: contentView, 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: MCQuestionModel, isEditable: Bool) {
        self.isEditable = isEditable
        
        questionLabel.text = model.question
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        for (index, option) in model.options.enumerated() {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.spacing = 8
            hStack.alignment = .center
            hStack.isUserInteractionEnabled = true
            
            let button = UIButton(type: .system)
            button.setTitle("○", for: .normal)
            button.tag = index
            button.widthAnchor.constraint(equalToConstant: 30).isActive = true
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            buttons.append(button)
            
            let label = UILabel()
            label.text = option
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 15)
            
            hStack.addArrangedSubview(button)
            hStack.addArrangedSubview(label)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stackTapped(_:)))
            hStack.addGestureRecognizer(tapGesture)
            hStack.tag = index
            
            optionsStackView.addArrangedSubview(hStack)
            
            if model.answer == index {
                button.setTitle("●", for: .normal)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func optionSelected(_ sender: UIButton) {
        selectOption(at: sender.tag)
    }
    
    @objc private func stackTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        selectOption(at: index)
    }
    
    private func selectOption(at index: Int) {
        guard isEditable else { return }
        for (i, button) in buttons.enumerated() {
            button.setTitle(i == index ? "●" : "○", for: .normal)
        }
        answerSelectionHandler?(index)
    }
}
