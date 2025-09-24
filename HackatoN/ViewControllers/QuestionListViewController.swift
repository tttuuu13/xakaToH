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
            return cell
        }
        
        let question = examModel.sections[indexPath.section].questions[indexPath.row]
        
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
                let section = self.examModel.sections[indexPath.section]
                let question = section.questions[indexPath.row]
                guard case var questionModel as TextQuestionModel = question else { return }
                questionModel.answer = newText
                delegate?.questionListViewController(self, didUpdateExam: examModel, with: questionModel, at: section.id)
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
                let section = self.examModel.sections[indexPath.section]
                let question = section.questions[indexPath.row]
                guard case var questionModel as MultipleChoiceQuestionModel = question else { return }
                questionModel.answer = selecterdOption
                delegate?.questionListViewController(self, didUpdateExam: examModel, with: questionModel, at: section.id)
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}
