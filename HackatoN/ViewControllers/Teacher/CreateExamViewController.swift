//
//  CreateExamViewController.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import UIKit

class CreateExamViewController: UIViewController {
    
    // MARK: - Properties
    private let contentView = CreateExamView()
    private var editableExamModel = EditableExamModel()
    private let firebaseManager = MockFirebaseDataManager()
    
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
        if editableExamModel.sections.count == 0 {
            editableExamModel.sections.append(EditableExamSectionModel())
        }
        contentView.configureTableView(delegate: self, dataSource: self)
        contentView.delegate = self
    }
    
    // MARK: - Actions
    private func createSection() {
        editableExamModel.sections.append(EditableExamSectionModel())
        
        contentView.tableView.beginUpdates()
        contentView.tableView.insertSections(IndexSet(integer: editableExamModel.sections.count - 1), with: .automatic)
        for footer in contentView.visibleFooterViews() {
            footer.isLast = footer.section == editableExamModel.sections[editableExamModel.sections.count - 1].id
        }
        for header in contentView.visibleHeaderViews() {
            header.isOnlyOneSection = editableExamModel.sections.count == 1
        }
        contentView.tableView.endUpdates()
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
    
    private func changeQuestion(in sectionId: UUID, with question: EditableQuestionProtocol) {
        guard let sectionIndex = editableExamModel.sections.firstIndex(where: { $0.id == sectionId }) else { return }
        guard let questionIndex = editableExamModel.sections[sectionIndex].questions.firstIndex(where: {
            $0.id == question.id
        }) else { return }
        editableExamModel.sections[sectionIndex].questions[questionIndex] = question
    }
}

extension CreateExamViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return editableExamModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editableExamModel.sections[section].questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < editableExamModel.sections.count else { return UITableViewCell() }
        
        let question = editableExamModel.sections[indexPath.section].questions[indexPath.row]
        let sectionId = editableExamModel.sections[indexPath.section].id
        
        switch question {
        case let textQuestion as EditableTextQuestionModel:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditableTextQuestionCell.reuseIdentifier, for: indexPath)
            guard let textQuestionCell = cell as? EditableTextQuestionCell else { return cell }
            
            textQuestionCell.configute(with: textQuestion.question)
            textQuestionCell.questionChanged = { [weak self] newQuestion in
                self?.changeQuestion(in:sectionId, with: newQuestion)
            }
            return textQuestionCell
            
        case let MCQuestion as EditableMCQuestionModel:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditableMCQuestionCell.reuseIdentifier, for: indexPath)
            guard let mcQuestionCell = cell as? EditableMCQuestionCell else { return cell }
            
            mcQuestionCell.configure(with: MCQuestion)
            mcQuestionCell.questionChanged = { [weak self] newQuestion in
                self?.changeQuestion(in: sectionId, with: newQuestion)
            }
            return mcQuestionCell
            
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CreateExamTableHeader.reuseIdentifier) as? CreateExamTableHeader else { return nil }
        let sectionId = editableExamModel.sections[section].id
        headerView.configure(sectionId: sectionId, text: editableExamModel.sections[section].name)
        headerView.isOnlyOneSection = editableExamModel.sections.count == 1
        headerView.delegate = self
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CreateExamTableFooter.reuseIdentifier) as? CreateExamTableFooter else { return nil }
        let sectionId = editableExamModel.sections[section].id
        footerView.configure(with: sectionId)
        footerView.isLast = section == editableExamModel.sections.count - 1
        footerView.delegate = self
        return footerView
    }
}

extension CreateExamViewController: UITableViewDelegate {
    
}

extension CreateExamViewController: CreateExamTableHeaderDelegate {
    func didTitleChange(in sectionId: UUID, to newTitle: String) {
        guard let sectionIndex = editableExamModel.sections.firstIndex(where: { $0.id == sectionId }) else { return }
        editableExamModel.sections[sectionIndex].name = newTitle
    }
    
    func didDeleteTapped(in sectionId: UUID) {
        guard let sectionIndex = editableExamModel.sections.firstIndex(where: { $0.id == sectionId }) else { return }
        editableExamModel.sections.remove(at: sectionIndex)
        contentView.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        
        contentView.tableView.beginUpdates()
        for footer in contentView.visibleFooterViews() {
            footer.isLast = footer.section == editableExamModel.sections[editableExamModel.sections.count - 1].id
        }
        for header in contentView.visibleHeaderViews() {
            header.isOnlyOneSection = editableExamModel.sections.count == 1
        }
        contentView.tableView.endUpdates()
    }
}

extension CreateExamViewController: CreateExamTableFooterDelegate {
    private func addRow(in sectionId: UUID) {
        guard let sectionIndex = editableExamModel.sections.firstIndex(where: { $0.id == sectionId }) else { return }
        
        let newIndexPath = IndexPath(row: editableExamModel.sections[sectionIndex].questions.count - 1, section: sectionIndex)
        contentView.tableView.beginUpdates()
        contentView.tableView.insertRows(at: [newIndexPath], with: .automatic)
        contentView.tableView.endUpdates()
    }
    
    func addTextQuestionButtonTapped(in sectionId: UUID) {
        guard let sectionIndex = editableExamModel.sections.firstIndex(where: { $0.id == sectionId }) else { return }
        
        editableExamModel.sections[sectionIndex].questions.append(EditableTextQuestionModel())
        addRow(in: sectionId)
    }
    
    func addMCQuestionButtonTapped(in sectionId: UUID) {
        guard let sectionIndex = editableExamModel.sections.firstIndex(where: { $0.id == sectionId }) else { return }
        
        editableExamModel.sections[sectionIndex].questions.append(EditableMCQuestionModel())
        addRow(in: sectionId)
    }
    
    func addSectionButtonTapped() {
        createSection()
    }
}

extension CreateExamViewController: CreateExamViewDelegate {
    func createExam() {
        Task {
            do {
                try await firebaseManager.sendCreatedExamToFirebase(exam: editableExamModel.createExam())
                await MainActor.run {
                    self.dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
