//
//  ViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit

class QuestionListViewController: UIViewController {
    
    private let tableView = UITableView()
    
    // вопросы для коллоквиума
    private let questions = [
        "Объясните разницу между протоколом и абстрактным классом.",
        "Что такое ARC и как он работает?",
        "Как работает GCD в iOS?",
        "Что такое weak и unowned ссылки?",
        "Как реализовать паттерн Singleton на Swift?"
    ]
    
    // ответы студентов (по индексу вопроса)
    private var answers: [String?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Коллоквиум"
        view.backgroundColor = .systemBackground
        
        answers = Array(repeating: nil, count: questions.count)
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        tableView.register(QuestionCell.self, forCellReuseIdentifier: "QuestionCell")
        
        view.addSubview(tableView)
        tableView.pin(to: view) // растянуть на весь экран
    }
}

// MARK: - UITableViewDataSource
extension QuestionListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as? QuestionCell else {
            return UITableViewCell()
        }
        var textQuestionModel = TextQuestionModel.init(question: questions[indexPath.row])
        cell.configure(with: textQuestionModel)
        
        // сохраняем индекс в tag для связи с массивом answers
        cell.answerTextView.tag = indexPath.row
        cell.answerTextView.delegate = self
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension QuestionListViewController: UITableViewDelegate {
    // тут можно обработать выбор ячейки, если понадобится
}

// MARK: - UITextViewDelegate
extension QuestionListViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        answers[textView.tag] = textView.text
    }
}
