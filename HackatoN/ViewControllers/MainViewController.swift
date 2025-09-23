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
    private var startedExams: [QuestionListModel] = []
    private var scheduledExams: [QuestionListModel] = []
    private var finishedExams: [QuestionListModel] = []
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        loadExams()
        sortExams()
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
            QuestionListModel(name: "first exam", startTime: Date.now.addingTimeInterval(-3600), status: .started, questions: [
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
            QuestionListModel(name: "second exam", startTime: Date.now.addingTimeInterval(-7200), status: .started, questions: [
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
            QuestionListModel(name: "first exam", startTime: Date.now.addingTimeInterval(3600), status: .scheduled, questions: [
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
            QuestionListModel(name: "second exam", startTime: Date.now.addingTimeInterval(7200), status: .scheduled, questions: [
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
            QuestionListModel(name: "first exam", startTime: Date.now.addingTimeInterval(-36000), status: .finished, questions: [
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
            QuestionListModel(name: "second exam", startTime: Date.now.addingTimeInterval(-72000), status: .finished, questions: [
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
    
    private func sortExams() {
        startedExams = exams.filter { $0.status == .started }.sorted { $0.startTime < $1.startTime }
        scheduledExams = exams.filter { $0.status == .scheduled }.sorted { $0.startTime < $1.startTime }
        finishedExams = exams.filter { $0.status == .finished }.sorted { $0.startTime < $1.startTime }
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
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return startedExams.count
        case 1: return scheduledExams.count
        case 2: return finishedExams.count
        default : return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return ExamStatus.started.rawValue
        case 1: return ExamStatus.scheduled.rawValue
        case 2: return ExamStatus.finished.rawValue
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExamsListCell.reuseIdentifier, for: indexPath)
        guard let examListCell = cell as? ExamsListCell else { return cell }
        
        let exam: QuestionListModel
        switch indexPath.section {
        case 0: exam = startedExams[indexPath.row]
        case 1: exam = scheduledExams[indexPath.row]
        case 2: exam = finishedExams[indexPath.row]
        default: fatalError("unknown section")
        }
        
        examListCell.configure(with: exam)
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exam: QuestionListModel
        switch indexPath.section {
        case 0: exam = startedExams[indexPath.row]
        case 1: exam = scheduledExams[indexPath.row]
        case 2: exam = finishedExams[indexPath.row]
        default: fatalError("unknown section")
        }
        
        guard exam.status != .scheduled else { return }
        let questinoListViewController = QuestionListViewController(questionListModel: exam)
        navigationController?.pushViewController(questinoListViewController, animated: true)
    }
}
