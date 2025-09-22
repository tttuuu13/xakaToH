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
    private var exams: [QuestionListModel] = []
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        loadExams()
    }
    
    // MARK: - Setup
    private func setupController() {
        title = "Главная"
        contentView.delegate = self
        contentView.configureTableView(delegate: self, dataSource: self)
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
    
    // MARK: - Data
    private func loadExams() {
        // ВРЕМЕННАЯ ЗАГЛУШКА
        exams = [
            QuestionListModel(name: "first exam", status: .notStarted, questions: [
                TextQuestionModel(question: "text question 1"),
                TextQuestionModel(question: "text question 2"),
                TextQuestionModel(question: "text question 3"),
                MultipleChoiceQuestionModel(question: "multiple options question 4", options: [
                    "option 1",
                    "option 2",
                    "option 3",
                    "option 4"
                ])
            ]),
            QuestionListModel(name: "second exam", status: .notStarted, questions: [
                TextQuestionModel(question: "text question 1"),
                TextQuestionModel(question: "text question 2"),
                TextQuestionModel(question: "text question 3"),
                MultipleChoiceQuestionModel(question: "multiple options question 4", options: [
                    "option 1",
                    "option 2",
                    "option 3",
                    "option 4"
                ])
            ])
        ]
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

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExamsListCell.reuseIdentifier, for: indexPath)
        guard let examListCell = cell as? ExamsListCell else { return cell }
        let exam = exams[indexPath.row]
        examListCell.configure(with: exam)
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exam = exams[indexPath.row]
        let questinoListViewController = QuestionListViewController(questionListModel: exam)
        navigationController?.pushViewController(questinoListViewController, animated: true)
    }
}
