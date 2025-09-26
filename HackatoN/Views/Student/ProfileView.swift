//
//  ProfileView.swift
//  HackatoN
//
//  Created by mariia on 22.09.2025.
//

import UIKit

protocol ProfileViewDelegate: AnyObject {
    func profileViewDidTapEditName(_ view: ProfileView)
    func profileViewDidTapSaveName(_ view: ProfileView)
    func profileViewDidTapCancelEdit(_ view: ProfileView)
}

final class ProfileView: UIView {
    
    weak var delegate: ProfileViewDelegate?
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let roleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        return label
    }()
    
    private let infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileInfoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Информация о профиле"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let editNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать имя", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите имя"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .words
        tf.backgroundColor = .tertiarySystemBackground
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let saveNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cancelEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        setupScrollView()
        setupAvatar()
        setupTitle()
        setupInfoCard()
        setupEditButton()
        setupEditSection()
        setupActions()
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupAvatar() {
        contentView.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupTitle() {
        contentView.addSubview(profileInfoTitleLabel)
        
        NSLayoutConstraint.activate([
            profileInfoTitleLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            profileInfoTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            profileInfoTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupInfoCard() {
        contentView.addSubview(infoCardView)
        
        NSLayoutConstraint.activate([
            infoCardView.topAnchor.constraint(equalTo: profileInfoTitleLabel.bottomAnchor, constant: 12),
            infoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        setupCardContent()
    }
    
    private func setupCardContent() {
        infoCardView.addSubview(nameLabel)
        infoCardView.addSubview(emailLabel)
        infoCardView.addSubview(roleLabel)
        
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -16),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            emailLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -16),
            
            roleLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 12),
            roleLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            roleLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -16),
            roleLabel.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupEditButton() {
        contentView.addSubview(editNameButton)
        
        NSLayoutConstraint.activate([
            editNameButton.topAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: 24),
            editNameButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    
    private func setupEditSection() {
        contentView.addSubview(nameTextField)
        
        buttonsStackView.addArrangedSubview(cancelEditButton)
        buttonsStackView.addArrangedSubview(saveNameButton)
        contentView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: editNameButton.bottomAnchor, constant: 12),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsStackView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        nameTextField.isHidden = true
        buttonsStackView.isHidden = true
    }
    
    private func setupActions() {
        editNameButton.addTarget(self, action: #selector(editNameTapped), for: .touchUpInside)
        saveNameButton.addTarget(self, action: #selector(saveNameTapped), for: .touchUpInside)
        cancelEditButton.addTarget(self, action: #selector(cancelEditTapped), for: .touchUpInside)
    }

    @objc private func editNameTapped() {
        delegate?.profileViewDidTapEditName(self)
    }
    
    @objc private func saveNameTapped() {
        delegate?.profileViewDidTapSaveName(self)
    }
    
    @objc private func cancelEditTapped() {
        delegate?.profileViewDidTapCancelEdit(self)
    }
}
