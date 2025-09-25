//
//  CreateExamViewController.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import UIKit

class CreateExamViewController: UIViewController, CreateExamViewDelegate {
    
    // MARK: - Properties
    private let contentView = CreateExamView()
    private var editableExamModel = EditableExamModel()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    // MARK: - Setup
    private func setupController() {
        title = "Создание экзамена"
        contentView.configureTableView(delegate: self, dataSource: self)
        contentView.delegate = self
    }
    
    // MARK: - Actions
    func createSection() {
        editableExamModel.sections.append(EditableExamSectionModel())
        contentView.reloadData()
    }
    
    private func renameSection(at index: Int, with name: String) {
        guard index >= 0 && index < editableExamModel.sections.count else { return }
        editableExamModel.sections[index].name = name
    }
    
    private func createTextQuestion(in sectionIndex: Int) {
        guard sectionIndex >= 0 && sectionIndex < editableExamModel.sections.count else { return }
        editableExamModel.sections[sectionIndex].questions.append(EditableTextQuestionModel())
    }
    
    private func createMCQuestion(in sectionIndex: Int) {
        guard sectionIndex >= 0 && sectionIndex < editableExamModel.sections.count else { return }
        editableExamModel.sections[sectionIndex].questions.append(EditableMCQuestionModel())
    }
}

extension CreateExamViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return editableExamModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editableExamModel.sections[section].questions.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < editableExamModel.sections.count else { return UITableViewCell() }
        
        if indexPath.row == editableExamModel.sections[indexPath.section].questions.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddQuestionCell.reuseIdentifier, for: indexPath)
            guard let addQuestionCell = cell as? AddQuestionCell else { return cell }
            addQuestionCell.delegate = self
            addQuestionCell.configure(with: indexPath.section)
            return addQuestionCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EditableTextQuestionCell.reuseIdentifier, for: indexPath)
        guard let editableTextQuestionCell = cell as? EditableTextQuestionCell else { return cell }
        
        editableTextQuestionCell.configute(with: editableExamModel.sections[indexPath.section].questions[indexPath.row].question)
        return editableTextQuestionCell
    }
}

extension CreateExamViewController: UITableViewDelegate {
    
}

extension CreateExamViewController: AddQuestionCellDelegate {
    func addTextQuestionButtonTapped(in section: Int) {
        editableExamModel.sections[section].questions.append(EditableMCQuestionModel())
        contentView.reloadData()
        print("added text question")
    }
    
    func addMCQuestionButtonTapped(in section: Int) {
        editableExamModel.sections[section].questions.append(EditableMCQuestionModel())
        contentView.reloadData()
    }
}
