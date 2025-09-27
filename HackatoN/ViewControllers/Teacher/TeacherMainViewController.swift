//
//  TeacherMainViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

final class TeacherMainViewController: UIViewController {
    
    // MARK: - UI
    private let contentView = TeacherMainView()
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        loadTeacherData()
        loadStats()
    }
    
    // MARK: - Setup
    private func setupController() {
        view.backgroundColor = .systemBackground
        title = "Учитель"
        
        contentView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Выйти",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }
    
    // MARK: - Data Loading
    private func loadTeacherData() {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let data = snapshot?.data(),
                   let name = data["name"] as? String {
                    self?.contentView.teacherNameLabel.text = "Добро пожаловать, \(name)!"
                }
            }
        }
    }
    
    private func loadStats() {
        loadStudentsCount()
        loadQuizzesCount()
    }
    
    private func loadStudentsCount() {
        db.collection("users").whereField("role", isEqualTo: "student").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let documents = snapshot?.documents {
                    self?.contentView.studentsCountLabel.text = "\(documents.count)"
                }
            }
        }
    }
    
    private func loadQuizzesCount() {
        guard let teacherUID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("quizzes").whereField("createdBy", isEqualTo: teacherUID).getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let documents = snapshot?.documents {
                    self?.contentView.quizzesCountLabel.text = "\(documents.count)"
                }
            }
        }
    }
    
    // MARK: - Actions
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

// MARK: - TeacherMainViewDelegate
extension TeacherMainViewController: TeacherMainViewDelegate {
    func teacherMainViewDidTapCreateQuiz(_ view: TeacherMainView) {
        //let createQuizVC = CreateQuizViewController()
        let createExamVC = CreateExamViewController()
        let navController = UINavigationController(rootViewController: createExamVC)
        present(navController, animated: true)
    }
    
    func teacherMainViewDidTapViewStudents(_ view: TeacherMainView) {
        let studentsVC = StudentListViewController()
        navigationController?.pushViewController(studentsVC, animated: true)
    }
    
    func teacherMainViewDidTapViewResults(_ view: TeacherMainView) {
        let resultsVC = QuizResultsViewController()
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    func teacherMainViewDidTapLogout(_ view: TeacherMainView) {
        logoutTapped()
    }
}
