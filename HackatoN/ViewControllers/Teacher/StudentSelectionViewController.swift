//
//  StudentSelectionViewController.swift
//  HackatoN
//
//  Created by Nick on 27.09.2025.
//

import UIKit
import FirebaseFirestore

protocol StudentSelectionViewControllerDelegate: AnyObject {
    func studentSelectionViewController(_ controller: StudentSelectionViewController, didSelectStudents students: [StudentModel])
}

class StudentSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private let contentView = StudentSelectionView()
    private var students: [StudentModel] = []
    private let db = Firestore.firestore()
    weak var delegate: StudentSelectionViewControllerDelegate?
    private var preselectedStudents: [StudentModel] = []
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        loadStudents()
    }
    
    // MARK: - Setup
    private func setupController() {
        contentView.delegate = self
        contentView.configureTableView(delegate: self, dataSource: self)
        updateSelectedCount()
    }
    
    // MARK: - Public Methods
    func setPreselectedStudents(_ students: [StudentModel]) {
        preselectedStudents = students
    }
    
    // MARK: - Data Loading
    private func loadStudents() {
        db.collection("users").whereField("role", isEqualTo: "student").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Ошибка загрузки студентов: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("Нет документов студентов")
                    return
                }
                
                self?.students = documents.compactMap { document in
                    let data = document.data()
                    guard let uid = data["uid"] as? String,
                          let name = data["name"] as? String,
                          let email = data["email"] as? String else {
                        return nil
                    }
                    
                    // Проверяем, был ли этот студент предварительно выбран
                    let isPreselected = self?.preselectedStudents.contains { $0.uid == uid } ?? false
                    
                    return StudentModel(uid: uid, name: name, email: email, isSelected: isPreselected)
                }
                
                self?.contentView.tableView.reloadData()
                self?.updateSelectedCount()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateSelectedCount() {
        let selectedCount = students.filter { $0.isSelected }.count
        contentView.updateSelectedCount(selectedCount)
    }
    
    private func toggleStudentSelection(at index: Int) {
        guard index >= 0 && index < students.count else { return }
        students[index].isSelected.toggle()
        
        let indexPath = IndexPath(row: index, section: 0)
        contentView.tableView.reloadRows(at: [indexPath], with: .none)
        updateSelectedCount()
    }
}

// MARK: - UITableViewDataSource
extension StudentSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StudentSelectionCell.reuseIdentifier, for: indexPath) as? StudentSelectionCell else {
            return UITableViewCell()
        }
        
        let student = students[indexPath.row]
        cell.configure(with: student)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StudentSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toggleStudentSelection(at: indexPath.row)
    }
}

// MARK: - StudentSelectionViewDelegate
extension StudentSelectionViewController: StudentSelectionViewDelegate {
    func studentSelectionViewDidTapDone(_ view: StudentSelectionView) {
        let selectedStudents = students.filter { $0.isSelected }
        delegate?.studentSelectionViewController(self, didSelectStudents: selectedStudents)
        dismiss(animated: true)
    }
    
    func studentSelectionViewDidTapCancel(_ view: StudentSelectionView) {
        dismiss(animated: true)
    }
}
