//
//  StudentSelectionCell.swift
//  HackatoN
//
//  Created by Nick on 27.09.2025.
//

import UIKit

class StudentSelectionCell: UITableViewCell {
    static let reuseIdentifier = "StudentSelectionCell"
    
    // MARK: - UI Elements
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(emailLabel)
        
        contentView.addSubview(stackView)
        contentView.addSubview(checkmarkImageView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -16),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    // MARK: - Configuration
    func configure(with student: StudentModel) {
        nameLabel.text = student.name
        emailLabel.text = student.email
        
        let imageName = student.isSelected ? "checkmark.circle.fill" : "circle"
        checkmarkImageView.image = UIImage(systemName: imageName)
        checkmarkImageView.tintColor = student.isSelected ? .systemBlue : .systemGray3
    }
}
