//
//  CustomTableViewCell.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//

import UIKit

class TextQuestionCell: UITableViewCell, UITextViewDelegate {
    static let reuseIdentifier = "TextQuestionCell"
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let answerTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.isScrollEnabled = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    var asnwerChanged: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(questionLabel)
        contentView.addSubview(answerTextView)
        
        selectionStyle = .none
        
        questionLabel.pinTop(to: contentView, 12)
        questionLabel.pinLeft(to: contentView, 16)
        questionLabel.pinRight(to: contentView, 16)
        
        answerTextView.pinTop(to: questionLabel.bottomAnchor, 8)
        answerTextView.pinLeft(to: contentView, 16)
        answerTextView.pinRight(to: contentView, 16)
        answerTextView.pinBottom(to: contentView, 12)
        answerTextView.setHeight(mode: .grOE, 30)
        
        answerTextView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: TextQuestionModel) {
        questionLabel.text = model.question
        answerTextView.text = model.answer ?? ""
    }
    
    func textViewDidChange(_ textView: UITextView) {
        asnwerChanged?(textView.text)
    }
}
