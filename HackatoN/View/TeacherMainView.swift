//
//  TeacherMainView.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import UIKit

protocol TeacherMainViewDelegate: AnyObject {
    func teacherMainViewDidTapCreateQuiz(_ view: TeacherMainView)
    func teacherMainViewDidTapViewStudents(_ view: TeacherMainView)
    func teacherMainViewDidTapViewResults(_ view: TeacherMainView)
    func teacherMainViewDidTapLogout(_ view: TeacherMainView)
}

final class TeacherMainView: UIView {
    
    weak var delegate: TeacherMainViewDelegate?
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.text = "Панель учителя"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let teacherNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let studentsCountCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let quizzesCountCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let studentsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.text = "0"
        return label
    }()
    
    private let studentsTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Студентов"
        label.textColor = .systemGray
        return label
    }()
    
    let quizzesCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.text = "0"
        return label
    }()
    
    private let quizzesTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Викторин"
        label.textColor = .systemGray
        return label
    }()
    
    private let actionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let createQuizButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать викторину", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewStudentsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Просмотреть студентов", for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewResultsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Результаты викторин", for: .normal)
        button.backgroundColor = UIColor.systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Отдельная кнопка для выхода, если захотите использовать внутри вью
    // Либо можно оставить только item в навбаре у контроллера
    let logoutBarButtonItem = UIBarButtonItem(title: "Выйти", style: .plain, target: nil, action: nil)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(welcomeLabel)
        contentView.addSubview(teacherNameLabel)
        contentView.addSubview(statsStackView)
        contentView.addSubview(actionsStackView)
        
        setupStatsCards()
        
        actionsStackView.addArrangedSubview(createQuizButton)
        actionsStackView.addArrangedSubview(viewStudentsButton)
        actionsStackView.addArrangedSubview(viewResultsButton)
        
        setupConstraints()
    }
    
    private func setupStatsCards() {
        let studentsStack = UIStackView(arrangedSubviews: [studentsCountLabel, studentsTextLabel])
        studentsStack.axis = .vertical
        studentsStack.spacing = 8
        studentsStack.translatesAutoresizingMaskIntoConstraints = false
        
        studentsCountCard.addSubview(studentsStack)
        
        let quizzesStack = UIStackView(arrangedSubviews: [quizzesCountLabel, quizzesTextLabel])
        quizzesStack.axis = .vertical
        quizzesStack.spacing = 8
        quizzesStack.translatesAutoresizingMaskIntoConstraints = false
        
        quizzesCountCard.addSubview(quizzesStack)
        
        let horizontalStack = UIStackView(arrangedSubviews: [studentsCountCard, quizzesCountCard])
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 16
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        statsStackView.addArrangedSubview(horizontalStack)
        
        NSLayoutConstraint.activate([
            studentsStack.centerXAnchor.constraint(equalTo: studentsCountCard.centerXAnchor),
            studentsStack.centerYAnchor.constraint(equalTo: studentsCountCard.centerYAnchor),
            
            quizzesStack.centerXAnchor.constraint(equalTo: quizzesCountCard.centerXAnchor),
            quizzesStack.centerYAnchor.constraint(equalTo: quizzesCountCard.centerYAnchor),
            
            studentsCountCard.heightAnchor.constraint(equalToConstant: 120),
            quizzesCountCard.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Welcome Label
            welcomeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Teacher Name Label
            teacherNameLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 10),
            teacherNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            teacherNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Stats Stack
            statsStackView.topAnchor.constraint(equalTo: teacherNameLabel.bottomAnchor, constant: 30),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Actions Stack
            actionsStackView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 40),
            actionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Button Heights
            createQuizButton.heightAnchor.constraint(equalToConstant: 56),
            viewStudentsButton.heightAnchor.constraint(equalToConstant: 56),
            viewResultsButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupActions() {
        createQuizButton.addTarget(self, action: #selector(createQuizTapped), for: .touchUpInside)
        viewStudentsButton.addTarget(self, action: #selector(viewStudentsTapped), for: .touchUpInside)
        viewResultsButton.addTarget(self, action: #selector(viewResultsTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func createQuizTapped() {
        delegate?.teacherMainViewDidTapCreateQuiz(self)
    }
    
    @objc private func viewStudentsTapped() {
        delegate?.teacherMainViewDidTapViewStudents(self)
    }
    
    @objc private func viewResultsTapped() {
        delegate?.teacherMainViewDidTapViewResults(self)
    }
}

