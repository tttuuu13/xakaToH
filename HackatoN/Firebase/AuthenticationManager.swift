//
//  AuthenticationManager.swift
//  HackatoN
//
//  Created by dread on 20.09.2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthenticationManager {
    
    private let db = Firestore.firestore()
    
    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<String?, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(AuthError.invalidUID))
                return
            }
            
            // Получаем роль пользователя
            self?.getUserRole(uid: uid, completion: completion)
        }
    }
    
    // MARK: - Register Student
    func registerStudent(email: String, password: String, name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Ошибка регистрации в Auth: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(AuthError.invalidUID))
                return
            }
            
            print("Пользователь создан в Auth с UID: \(uid)")
            
            // Сразу создаем документ в Firestore, используя полученный UID
            self?.createUserDocument(uid: uid, email: email, name: name, role: "student", completion: completion)
        }
    }

    
    // MARK: - Private Methods
    private func getUserRole(uid: String, completion: @escaping (Result<String?, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Ошибка получения роли пользователя: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let data = snapshot?.data(),
               let role = data["role"] as? String {
                print("Найдена роль пользователя: \(role)")
                completion(.success(role))
            } else {
                print("Роль пользователя не найдена")
                completion(.success(nil))
            }
        }
    }
    
    private func createUserDocument(uid: String, email: String, name: String, role: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Создание документа в Firestore для UID: \(uid)")
        
        let userData: [String: Any] = [
            "uid": uid,
            "email": email,
            "name": name,
            "role": role,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Ошибка создания документа в Firestore: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Документ пользователя успешно создан в Firestore")
                completion(.success(()))
            }
        }
    }
}

// MARK: - Custom Errors
enum AuthError: LocalizedError {
    case invalidUID
    case userNotAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .invalidUID:
            return "Ошибка получения UID пользователя"
        case .userNotAuthenticated:
            return "Пользователь не авторизован"
        }
    }
}

