//
//  MockExamProvider.swift
//  HackatoN
//
//  Created by Nick on 24.09.2025.
//

import Foundation

class MockExamProvider {
    static func provide() -> [ExamModel] {
        return [
            ExamModel(name: "first exam", startTime: Date.now.addingTimeInterval(-3600), status: .started, sections: [
                ExamSectionModel(name: "section1", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ]),
                ExamSectionModel(name: "section2", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ])
            ]),
            ExamModel(name: "second exam", startTime: Date.now.addingTimeInterval(-7200), status: .started, sections: [
                ExamSectionModel(name: "section1", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ]),
                ExamSectionModel(name: "section2", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ])
            ]),
            ExamModel(name: "first exam", startTime: Date.now.addingTimeInterval(3600), status: .scheduled, sections: [
                ExamSectionModel(name: "section1", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ]),
                ExamSectionModel(name: "section2", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ])
            ]),
            ExamModel(name: "second exam", startTime: Date.now.addingTimeInterval(7200), status: .scheduled, sections: [
                ExamSectionModel(name: "section1", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ]),
                ExamSectionModel(name: "section2", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ])
            ]),
            ExamModel(name: "first exam", startTime: Date.now.addingTimeInterval(-36000), status: .finished, sections: [
                ExamSectionModel(name: "section1", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ]),
                ExamSectionModel(name: "section2", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ])
            ]),
            ExamModel(name: "second exam", startTime: Date.now.addingTimeInterval(-72000), status: .finished, sections: [
                ExamSectionModel(name: "section1", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ]),
                ExamSectionModel(name: "section2", questions: [
                    TextQuestionModel(question: "text question 1"),
                    TextQuestionModel(question: "text question 2"),
                    TextQuestionModel(question: "text question 3"),
                    MCQuestionModel(question: "multiple options question 4", options: [
                        "option 1",
                        "option 2",
                        "option 3",
                        "option 4"
                    ])
                ])
            ])
        ]
    }
}
