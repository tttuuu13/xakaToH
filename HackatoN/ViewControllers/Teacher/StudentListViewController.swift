//
//  StudentListViewController.swift
//  HackatoN
//
//  Created by Nick on 27.09.2025.
//

import UIKit
import FirebaseFirestore

class StudentListViewController: UIViewController {
    
    // MARK: - Properties
    private let contentView = StudentListView()
    private var students: [StudentModel] = []
    private let db = Firestore.firestore()
    
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
        title = "Список студентов"
        contentView.configureTableView(delegate: self, dataSource: self)
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
                    
                    return StudentModel(uid: uid, name: name, email: email, isSelected: false)
                }
                
                self?.contentView.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension StudentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StudentListCell.reuseIdentifier, for: indexPath) as? StudentListCell else {
            return UITableViewCell()
        }
        
        let student = students[indexPath.row]
        cell.configure(with: student)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StudentListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // No interactive functionality - just deselect
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
