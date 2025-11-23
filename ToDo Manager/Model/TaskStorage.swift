//
//  TaskStorage.swift
//  ToDo Manager
//
//  Created by Vadim on 23/11/2025.
//

protocol TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

class TasksStorage: TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol] {
        let testTasks: [TaskProtocol] = [
            Task(title: "Buy bread", type: .normal, status: .planned),
            Task(title: "Clean house", type: .important, status: .planned),
            Task(title: "Read a book", type: .normal, status: .completed),
            Task(title: "Buy vacuum cleaner", type: .normal, status: .completed),
            Task(title: "Kiss wife", type: .important, status: .planned),
            Task(title: "Call parents", type: .important, status: .planned)
        ]
        return testTasks
    }
    
    func saveTasks(_ tasks: [any TaskProtocol]) {
        <#code#>
    }
}
