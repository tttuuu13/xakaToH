//
//  MainViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit
import Firebase
import FirebaseAuth

protocol MainViewDelegate: AnyObject {
    func mainViewDidRequestLogout(_ view: MainView)
}

final class MainViewController: UIViewController {
    
    // MARK: - Properties
    private let contentView = MainView()
    
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
        title = "Главная"
        contentView.delegate = self
        setupLogoutButton()
    }
    
    private func setupLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Выйти",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }
    
    // MARK: - Actions
    @objc private func logoutTapped() {
        mainViewDidRequestLogout(contentView)
    }
}

// MARK: - MainViewDelegate
extension MainViewController: MainViewDelegate {
    func mainViewDidRequestLogout(_ view: MainView) {
        do {
            try Auth.auth().signOut()
            // Возвращаемся на экран авторизации
            dismiss(animated: true)
        } catch {
            print("Ошибка выхода: \(error.localizedDescription)")
        }
    }
}

