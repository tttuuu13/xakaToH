//
//  MainViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

protocol MainViewDelegate: AnyObject {
    func mainViewDidRequestLogout(_ view: MainView)
}

final class MainViewController: UIViewController {
    
    // MARK: - Properties
    private let contentView = MainView()
    private let firebaseManager = FirebaseDataManager()
    private let localStore = LocalExamStateStore()
    
    private var exams: [ExamModel] = []
    private var startedExams: [ExamModel] = []
    private var scheduledExams: [ExamModel] = []
    private var finishedExams: [ExamModel] = []
    
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
        setupPullToRefresh()
    }
    
    private func setupLogoutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Выйти",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        contentView.tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data
    private func loadExams() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Пользователь не авторизован")
            return
        }
        
        Task {
            do {
                // Очищаем старые данные
                cleanupOldData()
                // Восстанавливаем все локальные состояния
                restoreAllLocalStates()
                // Применяем локальные состояния (старт/финиш/автофиниш по истечению часа)
                applyLocalStateToExams()
                exams = try await firebaseManager.getExamsForStudent(studentUID: currentUser.uid)
                await MainActor.run {
                    sortExams()
                    contentView.reloadData()
                }
            } catch {
                print("Ошибка загрузки экзаменов: \(error.localizedDescription)")
            }
        }
    }
    
    private func applyLocalStateToExams() {
        let now = Date()
        for i in exams.indices {
            let id = exams[i].id
            if localStore.isFinished(examId: id) {
                exams[i].status = .finished
                // Загружаем сохраненные ответы
                loadSavedAnswersToExam(&exams[i])
                continue
            }
            if let startedAt = localStore.startedAt(for: id) {
                let deadline = startedAt.addingTimeInterval(3600)
                if now >= deadline {
                    // Автоматически завершаем локально
                    localStore.markFinished(examId: id)
                    exams[i].status = .finished
                    // Загружаем сохраненные ответы
                    loadSavedAnswersToExam(&exams[i])
                } else {
                    exams[i].status = .started
                }
            } else {
                // Если нет локального старта — оставляем как есть (ожидаем, что учитель создал .scheduled)
                // Но если вдруг с сервера пришел started/finished — не трогаем
            }
        }
    }
    
    private func restoreAllLocalStates() {
        print("Восстанавливаем все локальные состояния...")
        
        // Получаем все ключи из UserDefaults
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        
        // Ищем все ключи, связанные с экзаменами
        let startedKeys = allKeys.filter { $0.hasPrefix("exam_startedAt_") }
        let finishedKeys = allKeys.filter { $0.hasPrefix("exam_finished_") }
        
        print("Найдено начатых экзаменов: \(startedKeys.count)")
        print("Найдено завершенных экзаменов: \(finishedKeys.count)")
        
        // Восстанавливаем состояния для всех найденных экзаменов
        for key in startedKeys {
            let examIdString = String(key.dropFirst("exam_startedAt_".count))
            guard let examId = UUID(uuidString: examIdString) else { continue }
            
            // Находим экзамен в списке
            if let examIndex = exams.firstIndex(where: { $0.id == examId }) {
                let startedAt = localStore.startedAt(for: examId)!
                let deadline = startedAt.addingTimeInterval(3600)
                let now = Date()
                
                if now >= deadline {
                    // Время истекло - завершаем
                    localStore.markFinished(examId: examId)
                    exams[examIndex].status = .finished
                    loadSavedAnswersToExam(&exams[examIndex])
                    print("Экзамен \(examId) автоматически завершен по истечении времени")
                } else {
                    exams[examIndex].status = .started
                    print("Экзамен \(examId) восстановлен как начатый")
                }
            }
        }
        
        for key in finishedKeys {
            let examIdString = String(key.dropFirst("exam_finished_".count))
            guard let examId = UUID(uuidString: examIdString) else { continue }
            
            // Находим экзамен в списке
            if let examIndex = exams.firstIndex(where: { $0.id == examId }) {
                exams[examIndex].status = .finished
                loadSavedAnswersToExam(&exams[examIndex])
                print("Экзамен \(examId) восстановлен как завершенный")
            }
        }
    }
    
    private func cleanupOldData() {
        print("Очищаем старые данные...")
        
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        
        // Ищем все ключи, связанные с экзаменами
        let startedKeys = allKeys.filter { $0.hasPrefix("exam_startedAt_") }
        let finishedKeys = allKeys.filter { $0.hasPrefix("exam_finished_") }
        let answersKeys = allKeys.filter { $0.hasPrefix("exam_answers_") }
        
        // Получаем ID всех текущих экзаменов
        let currentExamIds = Set(exams.map { $0.id })
        
        // Удаляем данные для экзаменов, которых больше нет
        for key in startedKeys {
            let examIdString = String(key.dropFirst("exam_startedAt_".count))
            guard let examId = UUID(uuidString: examIdString) else { continue }
            if !currentExamIds.contains(examId) {
                localStore.clear(examId: examId)
                print("Удалены данные для несуществующего экзамена: \(examId)")
            }
        }
        
        for key in finishedKeys {
            let examIdString = String(key.dropFirst("exam_finished_".count))
            guard let examId = UUID(uuidString: examIdString) else { continue }
            if !currentExamIds.contains(examId) {
                localStore.clear(examId: examId)
                print("Удалены данные для несуществующего экзамена: \(examId)")
            }
        }
        
        for key in answersKeys {
            let examIdString = String(key.dropFirst("exam_answers_".count))
            guard let examId = UUID(uuidString: examIdString) else { continue }
            if !currentExamIds.contains(examId) {
                localStore.clear(examId: examId)
                print("Удалены данные для несуществующего экзамена: \(examId)")
            }
        }
    }
    
    private func loadSavedAnswersToExam(_ exam: inout ExamModel) {
        guard let savedAnswers = localStore.getAnswers(for: exam.id) else { return }
        
        // Создаем новую модель с обновленными ответами
        var updatedSections: [ExamSectionModel] = []
        
        for section in exam.sections {
            var updatedQuestions: [QuestionProtocol] = []
            
            for question in section.questions {
                let key = "\(section.id.uuidString)_\(question.id.uuidString)"
                
                if let savedAnswer = savedAnswers[key] {
                    switch question {
                    case let textQuestion as TextQuestionModel:
                        var updatedTextQuestion = textQuestion
                        updatedTextQuestion.answer = savedAnswer as? String
                        updatedQuestions.append(updatedTextQuestion)
                    case let mcQuestion as MCQuestionModel:
                        var updatedMCQuestion = mcQuestion
                        updatedMCQuestion.answer = savedAnswer as? Int
                        updatedQuestions.append(updatedMCQuestion)
                    default:
                        updatedQuestions.append(question)
                    }
                } else {
                    updatedQuestions.append(question)
                }
            }
            
            var updatedSection = section
            updatedSection.questions = updatedQuestions
            updatedSections.append(updatedSection)
        }
        
        // Обновляем модель
        exam.sections = updatedSections
    }
    
    private func sortExams() {
        startedExams = exams.filter { $0.status == .started }.sorted { $0.startTime < $1.startTime }
        scheduledExams = exams.filter { $0.status == .scheduled }.sorted { $0.startTime < $1.startTime }
        finishedExams = exams.filter { $0.status == .finished }.sorted { $0.startTime < $1.startTime }
    }
    
    private func updateExam(_ exam: ExamModel) {
        if let idx = exams.firstIndex(where: { $0.id == exam.id }) {
            exams[idx] = exam
        }
        sortExams()
        contentView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func logoutTapped() {
        mainViewDidRequestLogout(contentView)
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadExams()
        
        // Останавливаем индикатор обновления через небольшую задержку
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            refreshControl.endRefreshing()
        }
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
        
        let exam: ExamModel
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
        let exam: ExamModel
        switch indexPath.section {
        case 0: exam = startedExams[indexPath.row]
        case 1: exam = scheduledExams[indexPath.row]
        case 2: exam = finishedExams[indexPath.row]
        default: fatalError("unknown section")
        }
        
        // Находим актуальную версию экзамена в основном массиве
        guard let actualExamIndex = exams.firstIndex(where: { $0.id == exam.id }) else { return }
        let actualExam = exams[actualExamIndex]
        
        switch actualExam.status {
        case .scheduled:
            // Предложить начать тест
            let alert = UIAlertController(title: "Начать тест?", message: "После начала у вас будет 60 минут на прохождение.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            alert.addAction(UIAlertAction(title: "Начать", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let startedAt = Date()
                self.localStore.markStarted(examId: actualExam.id, date: startedAt)
                
                var startedExam = actualExam
                startedExam.status = .started
                self.updateExam(startedExam)
                
                let vc = QuestionListViewController(examModel: startedExam)
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            present(alert, animated: true)
            
        case .started:
            let vc = QuestionListViewController(examModel: actualExam)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
            
        case .finished:
            // Уже завершен — можно открыть только для просмотра (без редактирования)
            let vc = QuestionListViewController(examModel: actualExam)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MainViewController: QuestionListViewControllerDelegate {
    func questionListViewController(_ viewController: QuestionListViewController, didUpdateExam exam: ExamModel, with question: QuestionProtocol, at sectionId: UUID) {
        guard let examIndex = exams.firstIndex(where: { $0.id == exam.id }) else { return }
        guard let sectionIndex = exams[examIndex].sections.firstIndex(where: { $0.id == sectionId }) else { return }
        guard let questionIndex = exams[examIndex].sections[sectionIndex].questions.firstIndex(where: { $0.id == question.id }) else { return }
        
        exams[examIndex].sections[sectionIndex].questions[questionIndex] = question
        sortExams()
        contentView.reloadData()
    }
    
    func questionListViewControllerDidFinishExam(_ viewController: QuestionListViewController, exam: ExamModel) {
        // Помечаем локально завершение и обновляем списки
        localStore.markFinished(examId: exam.id)
        var finishedExam = exam
        finishedExam.status = .finished
        updateExam(finishedExam)
    }
}
