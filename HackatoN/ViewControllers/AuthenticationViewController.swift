//
//  AuthenticationViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

final class AuthenticationViewController: UIViewController {
    
    // MARK: - Properties
    private let authManager = AuthenticationManager()
    private let contentView = AuthenticationView()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    // MARK: - Setup
    private func setupController() {
        title = "Авторизация"
        view.backgroundColor = .systemBackground
        contentView.delegate = self
    }
    
    // MARK: - Navigation
    private func navigateToMainScreen() {
        let mainVC = MainViewController() // Замените на ваш главный контроллер при необходимости
        let navController = UINavigationController(rootViewController: mainVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

// MARK: - AuthenticationViewDelegate
extension AuthenticationViewController: AuthenticationViewDelegate {
    func authenticationViewDidTapSignIn(_ view: AuthenticationView) {
        view.hideError()
        view.showLoading(true)
        
        guard let email = view.email, !email.isEmpty,
              let password = view.password, !password.isEmpty else {
            view.showError("Пожалуйста, заполните все поля")
            view.showLoading(false)
            return
        }
        
        authManager.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                view.showLoading(false)
                switch result {
                case .success:
                    // SceneDelegate обработает переход, но на всякий случай можно залогировать
                    print("Успешная авторизация")
                case .failure(let error):
                    view.showError(error.localizedDescription)
                }
            }
        }
    }
    
    func authenticationViewDidTapSignUp(_ view: AuthenticationView) {
        view.hideError()
        view.showLoading(true)
        
        guard let email = view.email, !email.isEmpty,
              let password = view.password, !password.isEmpty else {
            view.showError("Пожалуйста, заполните все поля")
            view.showLoading(false)
            return
        }
        
        let name = email.components(separatedBy: "@").first ?? "Пользователь"
        
        authManager.registerStudent(email: email, password: password, name: name) { [weak self] result in
            DispatchQueue.main.async {
                view.showLoading(false)
                switch result {
                case .success:
                    print("Регистрация успешна")
                case .failure(let error):
                    view.showError(error.localizedDescription)
                }
            }
        }
    }
}

