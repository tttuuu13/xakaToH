//
//  EndExamCell.swift
//  HackatoN
//
//  Created by Nick on 20.09.2025.
//

import UIKit

class EndExamCell: UITableViewCell {
    static let reuseIdentifier = "EndExamCell"
    var tapped: (() -> Void)?
    
    private let endButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Завершить экзамен", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(endButton)
        selectionStyle = .none
        endButton.pin(to: contentView, 5)
        
        endButton.addTarget(self, action: #selector(endButtonTapped), for: .touchUpInside)
    }
    
    @objc private func endButtonTapped() {
        tapped?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
