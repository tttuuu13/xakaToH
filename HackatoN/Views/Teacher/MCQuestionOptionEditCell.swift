//
//  MCQuestionOptionEditCell.swift
//  HackatoN
//
//  Created by Nick on 25.09.2025.
//

import UIKit

class MCQuestionOptionEditCell: UITableViewCell, UITextViewDelegate {
    
    // MARK: - properties
    static let reuseIdentifier = "MCQuestionOptionEditCell"
    var optionChanged: ((String) -> Void)?
    
    // MARK: - UI
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Введите вариант ответа"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 20, weight: .medium)
        return textView
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
        contentView.addSubview(label)
        
        label.pinTop(to: contentView, 3)
        label.pinHorizontal(to: contentView, 5)
        
        textView.pinTop(to: label.bottomAnchor, 5)
        textView.pinHorizontal(to: contentView, 5)
        textView.pinBottom(to: contentView, 3)
        
        selectionStyle = .none
        textView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public API
    func configute(with text: String) {
        textView.text = text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        optionChanged?(textView.text)
        
        if let tableView = superview as? UITableView {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
}
