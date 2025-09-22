//
//  MainTabBarController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit
import Firebase
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupLogoutButton()
    }
    
    private func setupTabBar() {
        // Главный экран
        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house"), tag: 0)
        let mainNav = UINavigationController(rootViewController: mainVC)
        
        // Профиль
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person"), tag: 1)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        viewControllers = [mainNav, profileNav]
    }
    
    private func setupLogoutButton() {
        // Добавляем кнопку выхода на каждую вкладку
        for navController in viewControllers ?? [] {
            if let nav = navController as? UINavigationController {
                nav.topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: "Выйти",
                    style: .plain,
                    target: self,
                    action: #selector(logoutTapped)
                )
            }
        }
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Выход", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                // SceneDelegate автоматически перенаправит на экран авторизации
            } catch {
                print("Ошибка выхода: \(error.localizedDescription)")
            }
        })
        
        present(alert, animated: true)
    }
}
