//
//  ExamsListCell.swift
//  HackatoN
//
//  Created by Nick on 22.09.2025.
//

import UIKit

final class ExamsListCell: UITableViewCell {
    static let reuseIdentifier = "ExamsListCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(startDateLabel)
        
        selectionStyle = .none
        
        titleLabel.pinTop(to: contentView, 12)
        titleLabel.pinHorizontal(to: contentView)
        
        startDateLabel.pinTop(to: titleLabel.bottomAnchor, 8)
        startDateLabel.pinHorizontal(to: contentView)
        startDateLabel.pinBottom(to: contentView, 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: QuestionListModel) {
        print("\(model.name)")
        titleLabel.text = model.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        //dateFormatter.locale = .autoupdatingCurrent
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        startDateLabel.text = dateFormatter.string(from: model.startTime)
    }
}
