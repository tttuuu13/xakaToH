//
//  ViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit

class QuestionListViewController: UIViewController {
    
    private let tableView = UITableView()
    private var questionListModel: QuestionListModel
    
    
    init(questionListModel: QuestionListModel) {
        self.questionListModel = questionListModel
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
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        tableView.register(TextQuestionCell.self, forCellReuseIdentifier: TextQuestionCell.reuseIdentifier)
        tableView.register(MultipleChoiceCell.self, forCellReuseIdentifier: MultipleChoiceCell.reuseIdentifier)
        tableView.register(EndExamCell.self, forCellReuseIdentifier: EndExamCell.reuseIdentifier)
        
        view.addSubview(tableView)
        tableView.pin(to: view)
    }
}

// MARK: - UITableViewDataSource
extension QuestionListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionListModel.questions.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == questionListModel.questions.count {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EndExamCell.reuseIdentifier,
                for: indexPath
                ) as? EndExamCell else {
                return UITableViewCell()
            }
            return cell
        }
        
        let question = questionListModel.questions[indexPath.row]
            
            switch question {
            case let textQuestion as TextQuestionModel:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: TextQuestionCell.reuseIdentifier,
                    for: indexPath
                ) as? TextQuestionCell else {
                    return UITableViewCell()
                }
                cell.configure(with: textQuestion)
                cell.asnwerChanged = { [weak self] newText in
                    let question = self?.questionListModel.questions[indexPath.row]
                    guard case var questionModel as TextQuestionModel = question else { return }
                    questionModel.answer = newText
                    self?.questionListModel.questions[indexPath.row] = questionModel
                }
                return cell
                
            case let mcQuestion as MultipleChoiceQuestionModel:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: MultipleChoiceCell.reuseIdentifier,
                    for: indexPath
                ) as? MultipleChoiceCell else {
                    return UITableViewCell()
                }
                cell.configure(with: mcQuestion)
                cell.answerSelectionHandler = { [weak self] selecterdOption in
                    let question = self?.questionListModel.questions[indexPath.row]
                    guard case var questionModel as MultipleChoiceQuestionModel = question else { return }
                    questionModel.answer = selecterdOption
                    self?.questionListModel.questions[indexPath.row] = questionModel
                }
                return cell
                
            default:
                return UITableViewCell()
            }
    }
}
