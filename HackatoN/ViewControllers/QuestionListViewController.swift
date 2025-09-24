//
//  ViewController.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit

protocol QuestionListViewControllerDelegate: AnyObject {
    func questionListViewController(_ viewController: QuestionListViewController, didUpdateExam exam: ExamModel, with question: QuestionProtocol)
}

class QuestionListViewController: UIViewController {
    
    weak var delegate: QuestionListViewControllerDelegate?
    
    private let tableView = UITableView()
    private var examModel: ExamModel
    
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return examModel.status == .started ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return examModel.questions.count
        case 1: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: EndExamCell.reuseIdentifier,
                for: indexPath
            ) as? EndExamCell else {
                return UITableViewCell()
            }
            return cell
        }
        
        let question = examModel.questions[indexPath.row]
        
        switch question {
        case let textQuestion as TextQuestionModel:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TextQuestionCell.reuseIdentifier,
                for: indexPath
            ) as? TextQuestionCell else {
                return UITableViewCell()
            }
            cell.configure(with: textQuestion, isEditable: examModel.status == .started)
            cell.asnwerChanged = { [weak self] newText in
                guard let self = self else { return }
                let question = self.examModel.questions[indexPath.row]
                guard case var questionModel as TextQuestionModel = question else { return }
                questionModel.answer = newText
                delegate?.questionListViewController(self, didUpdateExam: examModel, with: questionModel)
            }
            return cell
            
        case let mcQuestion as MultipleChoiceQuestionModel:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MultipleChoiceCell.reuseIdentifier,
                for: indexPath
            ) as? MultipleChoiceCell else {
                return UITableViewCell()
            }
            cell.configure(with: mcQuestion, isEditable: examModel.status == .started)
            cell.answerSelectionHandler = { [weak self] selecterdOption in
                guard let self = self else { return }
                let question = self.examModel.questions[indexPath.row]
                guard case var questionModel as MultipleChoiceQuestionModel = question else { return }
                questionModel.answer = selecterdOption
                delegate?.questionListViewController(self, didUpdateExam: examModel, with: questionModel)
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}
