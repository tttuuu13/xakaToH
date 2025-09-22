import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let emailLabel = UILabel()
    private let roleLabel = UILabel()
    
    private let infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        return view
    }()
    
    private let profileInfoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Информация о профиле"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let editNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать имя", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите имя"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .words
        tf.backgroundColor = .tertiarySystemBackground
        tf.layer.shadowColor = UIColor.black.cgColor
        tf.layer.shadowOpacity = 0.05
        tf.layer.shadowRadius = 8
        tf.layer.shadowOffset = CGSize(width: 0, height: 4)
        return tf
    }()
    
    private let saveNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    private let cancelEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Профиль"
        setupScrollView()
        setupAvatar()
        setupTitle()
        setupInfoCard()
        setupEditButton()
        setupEditSection()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupAvatar() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupTitle() {
        profileInfoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileInfoTitleLabel)
        
        NSLayoutConstraint.activate([
            profileInfoTitleLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            profileInfoTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            profileInfoTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupInfoCard() {
        infoCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoCardView)
        
        NSLayoutConstraint.activate([
            infoCardView.topAnchor.constraint(equalTo: profileInfoTitleLabel.bottomAnchor, constant: 12),
            infoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        setupCardContent()
    }
    
    private func setupCardContent() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        infoCardView.addSubview(nameLabel)
        infoCardView.addSubview(emailLabel)
        infoCardView.addSubview(roleLabel)
        
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
        
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        emailLabel.textAlignment = .left
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emailLabel.textColor = .secondaryLabel
        
        roleLabel.textAlignment = .left
        roleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        roleLabel.textColor = .systemBlue
    }
    
    private func setupEditButton() {
        editNameButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(editNameButton)
        
        NSLayoutConstraint.activate([
            editNameButton.topAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: 24),
            editNameButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        
        editNameButton.addTarget(self, action: #selector(editNameTapped), for: .touchUpInside)
    }
    
    private func setupEditSection() {
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameTextField)
        
        buttonsStackView.addArrangedSubview(cancelEditButton)
        buttonsStackView.addArrangedSubview(saveNameButton)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
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
        
        saveNameButton.addTarget(self, action: #selector(saveNameTapped), for: .touchUpInside)
        cancelEditButton.addTarget(self, action: #selector(cancelEditTapped), for: .touchUpInside)
    }
    
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        emailLabel.text = "Почта: \(user.email ?? "")"
        nameLabel.text = user.displayName != nil ? "Имя: \(user.displayName!)" : "Имя пользователя"
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                guard let data = snapshot?.data() else { return }
                
                if let role = data["role"] as? String {
                    self?.updateRoleUI(role: role)
                }
                if let name = data["name"] as? String {
                    self?.nameTextField.text = name
                    self?.nameLabel.text = "Имя: \(name)"
                }
            }
        }
    }
    
    @objc private func editNameTapped() {
        nameTextField.isHidden = false
        buttonsStackView.isHidden = false
        nameTextField.becomeFirstResponder()
    }
    
    @objc private func saveNameTapped() {
        guard let user = Auth.auth().currentUser else { return }
        let newName = nameTextField.text ?? ""
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData(["name": newName]) { error in
            if let error = error {
                print("Ошибка сохранения имени: \(error)")
            }
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        changeRequest.commitChanges { error in
            if let error = error {
                print("Ошибка обновления displayName: \(error)")
            }
        }
        
        nameLabel.text = "Имя: \(newName)"
        hideNameEditing()
    }
    
    @objc private func cancelEditTapped() {
        hideNameEditing()
    }
    
    private func hideNameEditing() {
        view.endEditing(true)
        nameTextField.isHidden = true
        buttonsStackView.isHidden = true
    }
    
    private func updateRoleUI(role: String) {
        roleLabel.text = "Роль: \(role)"
        
        if role.lowercased().contains("учитель") {
            avatarImageView.image = UIImage(systemName: "person.circle")
            avatarImageView.tintColor = .systemGreen
            roleLabel.textColor = .systemGreen
        } else {
            avatarImageView.image = UIImage(systemName: "books.vertical.fill")
            avatarImageView.tintColor = .systemBlue
            roleLabel.textColor = .systemBlue
        }
    }
}
