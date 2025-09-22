//
//  ExamsListCell.swift
//  HackatoN
//
//  Created by Nick on 22.09.2025.
//

import UIKit

final class ExamsListCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        
        selectionStyle = .none
        
        titleLabel.pinTop(to: contentView, 12)
        titleLabel.pinHorizontal(to: contentView)
        
        statusLabel.pinTop(to: titleLabel, 8)
        statusLabel.pinHorizontal(to: contentView)
        statusLabel.pinBottom(to: contentView, 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: QuestionListModel) {
        titleLabel.text = model.name
        statusLabel.text = model.status.rawValue
    }
}
