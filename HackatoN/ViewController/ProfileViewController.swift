//
//  ProfileViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Профиль"
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(roleLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        emailLabel.text = user.email
        
        // Загружаем роль из Firestore
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let data = snapshot?.data(),
                   let role = data["role"] as? String {
                    self?.roleLabel.text = "Роль: \(role)"
                }
            }
        }
    }
}
