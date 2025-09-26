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
    
    private let profileView = ProfileView()
    private let db = Firestore.firestore()
    
    override func loadView() {
        self.view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        loadUserData()
    }
    
    private func setupController() {
        view.backgroundColor = .systemBackground
        title = "Профиль"
        
        profileView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Выйти",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }
    
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        profileView.emailLabel.text = "Почта: \(user.email ?? "")"
        profileView.nameLabel.text = user.displayName != nil ? "Имя: \(user.displayName!)" : "Имя пользователя"
        
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                guard let data = snapshot?.data() else { return }
                
                if let role = data["role"] as? String {
                    self?.updateRoleUI(role: role)
                }
                if let name = data["name"] as? String {
                    self?.profileView.nameTextField.text = name
                    self?.profileView.nameLabel.text = "Имя: \(name)"
                }
            }
        }
    }
    
    @objc private func logoutTapped() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Ошибка выхода: \(error.localizedDescription)")
        }
    }
    
    private func updateRoleUI(role: String) {
        profileView.roleLabel.text = "Роль: \(role)"
        
        if role.lowercased().contains("учитель") {
            profileView.avatarImageView.image = UIImage(systemName: "person.circle")
            profileView.avatarImageView.tintColor = .systemGreen
            profileView.roleLabel.textColor = .systemGreen
        } else {
            profileView.avatarImageView.image = UIImage(systemName: "books.vertical.fill")
            profileView.avatarImageView.tintColor = .systemBlue
            profileView.roleLabel.textColor = .systemBlue
        }
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func profileViewDidTapEditName(_ view: ProfileView) {
        view.nameTextField.isHidden = false
        view.buttonsStackView.isHidden = false
        view.nameTextField.becomeFirstResponder()
    }
    
    func profileViewDidTapSaveName(_ view: ProfileView) {
        guard let user = Auth.auth().currentUser else { return }
        let newName = view.nameTextField.text ?? ""
        
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
        
        view.nameLabel.text = "Имя: \(newName)"
        hideNameEditing()
    }
    
    func profileViewDidTapCancelEdit(_ view: ProfileView) {
        hideNameEditing()
    }
    
    private func hideNameEditing() {
        view.endEditing(true)
        profileView.nameTextField.isHidden = true
        profileView.buttonsStackView.isHidden = true
    }
}
