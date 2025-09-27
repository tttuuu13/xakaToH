//
//  ViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit
import Foundation

protocol QuestionListViewControllerDelegate: AnyObject {
    func questionListViewController(_ viewController: QuestionListViewController, didUpdateExam exam: ExamModel, with question: QuestionProtocol, at sectionId: UUID)
    func questionListViewControllerDidFinishExam(_ viewController: QuestionListViewController, exam: ExamModel)
}

class QuestionListViewController: UIViewController {
    
    weak var delegate: QuestionListViewControllerDelegate?
    
    private let tableView = UITableView()
    private var examModel: ExamModel
    private let localStore = LocalExamStateStore()
    
    // Таймер
    private var timer: Timer?
    private var timeRemaining: TimeInterval = 3600 // 60 минут в секундах
    private let timerLabel = UILabel()
    
    init(examModel: ExamModel) {
        self.examModel = examModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Коллоквиум"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupTimer()
        
        if examModel.status == .started {
            // Загружаем сохраненные ответы, если они есть
            loadSavedAnswers()
            startTimer()
        } else if examModel.status == .finished {
            loadSavedAnswers()
        }
        
        // Принудительно обновляем отображение
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        
        // Сохраняем ответы при выходе из экрана
        if examModel.status == .started {
            saveCurrentAnswers()
        }
    }
    
    deinit {
        stopTimer()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        tableView.register(TextQuestionCell.self, forCellReuseIdentifier: TextQuestionCell.reuseIdentifier)
        tableView.register(MultipleChoiceCell.self, forCellReuseIdentifier: MultipleChoiceCell.reuseIdentifier)
        tableView.register(EndExamCell.self, forCellReuseIdentifier: EndExamCell.reuseIdentifier)
        
        view.addSubview(tableView)
    }
    
    private func setupTimer() {
        timerLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        timerLabel.textAlignment = .center
        timerLabel.textColor = .systemBlue
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            timerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timerLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Обновляем констрейнты таблицы
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Устанавливаем текст для завершенных тестов
        if examModel.status == .finished {
            timerLabel.text = "Тест завершен"
            timerLabel.textColor = .systemGreen
        }
    }
    
    private func startTimer() {
        guard examModel.status == .started else { return }
        
        // Получаем время начала из локального хранилища
        if let startedAt = localStore.startedAt(for: examModel.id) {
            let elapsed = Date().timeIntervalSince(startedAt)
            timeRemaining = max(0, 3600 - elapsed)
        }
        
        updateTimerDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer() {
        timeRemaining -= 1
        updateTimerDisplay()
        
        if timeRemaining <= 0 {
            // Время истекло - автоматически завершаем тест
            autoFinishExam()
        }
    }
    
    private func updateTimerDisplay() {
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) % 3600 / 60
        let seconds = Int(timeRemaining) % 60
        
        if timeRemaining <= 300 { // Последние 5 минут - красный цвет
            timerLabel.textColor = .systemRed
        } else {
            timerLabel.textColor = .systemBlue
        }
        
        timerLabel.text = String(format: "Осталось времени: %02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func autoFinishExam() {
        stopTimer()
        finishExam()
    }
    
    private func finishExam() {
        guard examModel.status == .started else { return }
        
        // Сохраняем ответы локально
        saveAnswersLocally()
        
        // Помечаем тест как завершенный
        localStore.markFinished(examId: examModel.id)
        examModel.status = .finished
        
        // Обновляем UI
        tableView.reloadData()
        
        // Уведомляем делегата
        delegate?.questionListViewControllerDidFinishExam(self, exam: examModel)
        
        // Вернемся назад на список
        navigationController?.popViewController(animated: true)
    }
    
    private func saveAnswersLocally() {
        var answers: [String: Any] = [:]
        
        for section in examModel.sections {
            for question in section.questions {
                let key = "\(section.id.uuidString)_\(question.id.uuidString)"
                
                switch question {
                case let textQuestion as TextQuestionModel:
                    answers[key] = textQuestion.answer ?? ""
                    print("Сохраняем текстовый ответ: \(textQuestion.answer ?? "nil") для ключа \(key)")
                case let mcQuestion as MCQuestionModel:
                    answers[key] = mcQuestion.answer ?? -1
                    print("Сохраняем ответ с выбором: \(mcQuestion.answer ?? -1) для ключа \(key)")
                default:
                    break
                }
            }
        }
        
        print("Сохраняем все ответы: \(answers)")
        localStore.saveAnswers(for: examModel.id, answers: answers)
    }
    
    private func saveCurrentAnswers() {
        var answers: [String: Any] = [:]
        
        for section in examModel.sections {
            for question in section.questions {
                let key = "\(section.id.uuidString)_\(question.id.uuidString)"
                
                switch question {
                case let textQuestion as TextQuestionModel:
                    answers[key] = textQuestion.answer ?? ""
                case let mcQuestion as MCQuestionModel:
                    answers[key] = mcQuestion.answer ?? -1
                default:
                    break
                }
            }
        }
        
        print("Сохраняем текущие ответы: \(answers)")
        localStore.saveAnswers(for: examModel.id, answers: answers)
    }
    
    private func loadSavedAnswers() {
        guard let savedAnswers = localStore.getAnswers(for: examModel.id) else { 
            print("Нет сохраненных ответов для теста \(examModel.id)")
            return 
        }
        
        print("Статус теста: \(examModel.status)")
        
        print("Загружаем сохраненные ответы: \(savedAnswers)")
        
        // Создаем новую модель с обновленными ответами
        var updatedSections: [ExamSectionModel] = []
        
        for section in examModel.sections {
            var updatedQuestions: [QuestionProtocol] = []
            
            for question in section.questions {
                let key = "\(section.id.uuidString)_\(question.id.uuidString)"
                
                if let savedAnswer = savedAnswers[key] {
                    print("Найден сохраненный ответ для ключа \(key): \(savedAnswer)")
                    switch question {
                    case let textQuestion as TextQuestionModel:
                        var updatedTextQuestion = textQuestion
                        updatedTextQuestion.answer = savedAnswer as? String
                        updatedQuestions.append(updatedTextQuestion)
                        print("Обновлен текстовый вопрос: \(updatedTextQuestion.answer ?? "nil")")
                    case let mcQuestion as MCQuestionModel:
                        var updatedMCQuestion = mcQuestion
                        updatedMCQuestion.answer = savedAnswer as? Int
                        updatedQuestions.append(updatedMCQuestion)
                        print("Обновлен вопрос с выбором: \(updatedMCQuestion.answer ?? -1)")
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
        examModel.sections = updatedSections
        
        print("Модель обновлена. Количество секций: \(examModel.sections.count)")
        for (sectionIndex, section) in examModel.sections.enumerated() {
            print("Секция \(sectionIndex): \(section.questions.count) вопросов")
            for (questionIndex, question) in section.questions.enumerated() {
                switch question {
                case let textQuestion as TextQuestionModel:
                    print("  Вопрос \(questionIndex): \(textQuestion.question) - Ответ: \(textQuestion.answer ?? "nil")")
                case let mcQuestion as MCQuestionModel:
                    print("  Вопрос \(questionIndex): \(mcQuestion.question) - Ответ: \(mcQuestion.answer ?? -1)")
                default:
                    break
                }
            }
        }
        
        // Обновляем отображение
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension QuestionListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return examModel.status == .started ? examModel.sections.count + 1 : examModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0..<examModel.sections.count: return examModel.sections[section].questions.count
        case examModel.sections.count: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0..<examModel.sections.count: return examModel.sections[section].name
        case examModel.sections.count: return nil
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == examModel.sections.count {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EndExamCell.reuseIdentifier,
                for: indexPath
            ) as? EndExamCell else {
                return UITableViewCell()
            }
            // Вешаем обработчик на кнопку
            cell.onEndTap = { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(
                    title: "Завершить тест?",
                    message: "После завершения редактирование будет недоступно.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                alert.addAction(UIAlertAction(title: "Завершить", style: .destructive, handler: { _ in
                    self.finishExam()
                }))
                self.present(alert, animated: true)
            }
            return cell
        }
        
        let question = examModel.sections[indexPath.section].questions[indexPath.row]
        
        print("cellForRowAt: секция \(indexPath.section), строка \(indexPath.row)")
        
        switch question {
        case let textQuestion as TextQuestionModel:
            print("Создаем TextQuestionCell: вопрос='\(textQuestion.question)', ответ='\(textQuestion.answer ?? "nil")'")
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TextQuestionCell.reuseIdentifier,
                for: indexPath
            ) as? TextQuestionCell else {
                return UITableViewCell()
            }
            cell.configure(with: textQuestion, isEditable: examModel.status == .started)
            cell.asnwerChanged = { [weak self] newText in
                guard let self = self else { return }
                let section = self.examModel.sections[indexPath.section]
                let question = section.questions[indexPath.row]
                guard case var questionModel as TextQuestionModel = question else { return }
                questionModel.answer = newText
                
                // Обновляем модель
                self.examModel.sections[indexPath.section].questions[indexPath.row] = questionModel
                
                // Сохраняем ответ локально
                self.saveCurrentAnswers()
                
                self.delegate?.questionListViewController(self, didUpdateExam: self.examModel, with: questionModel, at: section.id)
            }
            return cell
            
        case let mcQuestion as MCQuestionModel:
            print("Создаем MultipleChoiceCell: вопрос='\(mcQuestion.question)', ответ=\(mcQuestion.answer ?? -1)")
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MultipleChoiceCell.reuseIdentifier,
                for: indexPath
            ) as? MultipleChoiceCell else {
                return UITableViewCell()
            }
            cell.configure(with: mcQuestion, isEditable: examModel.status == .started)
            cell.answerSelectionHandler = { [weak self] selectedOption in
                guard let self = self else { return }
                let section = self.examModel.sections[indexPath.section]
                let question = section.questions[indexPath.row]
                guard case var questionModel as MCQuestionModel = question else { return }
                questionModel.answer = selectedOption
                
                // Обновляем модель
                self.examModel.sections[indexPath.section].questions[indexPath.row] = questionModel
                
                // Сохраняем ответ локально
                self.saveCurrentAnswers()
                
                self.delegate?.questionListViewController(self, didUpdateExam: self.examModel, with: questionModel, at: section.id)
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate
extension QuestionListViewController: UITableViewDelegate {
    // На случай, если пользователь тапает по всей ячейке, а не по кнопке
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard examModel.status == .started else { return }
        if indexPath.section == examModel.sections.count {
            let alert = UIAlertController(
                title: "Завершить тест?",
                message: "После завершения редактирование будет недоступно.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            alert.addAction(UIAlertAction(title: "Завершить", style: .destructive, handler: { [weak self] _ in
                self?.finishExam()
            }))
            present(alert, animated: true)
        }
    }
}

