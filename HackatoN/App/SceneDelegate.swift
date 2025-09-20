//
//  SceneDelegate.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        setupAuthStateListener()
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Auth State Management
    
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            DispatchQueue.main.async {
                if let user = user {
                    print("Пользователь авторизован: \(user.uid)")
                    self?.checkUserRoleAndShowScreen(uid: user.uid)
                } else {
                    print("Пользователь не авторизован")
                    self?.showAuthScreen()
                }
            }
        }
    }
    
    private func checkUserRoleAndShowScreen(uid: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let data = snapshot?.data(),
                   let role = data["role"] as? String {
                    
                    switch role {
                    case "teacher":
                        self?.showTeacherScreen()
                    case "student":
                        self?.showStudentScreen()
                    default:
                        // Если роль неизвестна, показываем студенческий экран по умолчанию
                        self?.showStudentScreen()
                    }
                } else {
                    // Если не удалось получить роль, показываем студенческий экран
                    self?.showStudentScreen()
                }
            }
        }
    }
    
    private func showAuthScreen() {
        let authVC = AuthenticationViewController()
        let navController = UINavigationController(rootViewController: authVC)
        
        window?.rootViewController = navController
        
        if window?.rootViewController != nil {
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    private func showStudentScreen() {
        let studentMainVC = MainTabBarController()
        
        window?.rootViewController = studentMainVC
        UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
    
    private func showTeacherScreen() {
        let teacherMainVC = TeacherMainViewController()
        let navController = UINavigationController(rootViewController: teacherMainVC)
        
        window?.rootViewController = navController
        UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
