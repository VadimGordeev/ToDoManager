//
//  TaskTypeController.swift
//  ToDo Manager
//
//  Created by Vadim on 29/11/2025.
//

import UIKit

class TaskTypeController: UITableViewController {
    
    //    1. кортеж, описывающий тип задачи
    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)
    var doAfterTypeSelected:((TaskPriority) -> Void)?
    
    //    2. коллекция доступных типов задач с их описанием
    private var taskTypesInformation: [TypeCellDescription] = [
        (type: .important, title: "Important", description: "This type of task is the highest priority for completion. All important tasks are displayed at the very top of the task list."),
        (type: .normal, title: "Normal", description: "Task with normal priority.")
    ]
    
    //    3. выбранный приоритет
    var selectedType: TaskPriority = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        1. получение значения типа UINib, соответствующее xib-файлу кастомной ячейки
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        //        2. регистрация кастомной ячейки в табличном представлении
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskTypesInformation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        1. получение переиспользуемой кастомной ячейки по ее идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        
//        2. получаем текущий элемент, информация о котором должна быть выведена в строке
        let typeDescription = taskTypesInformation[indexPath.row]
        
//        3. заполняем ячейку данными
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
        
//        4. если тип является выбранным, то отмечаем его галочкой
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        получаем выбранный тип
        let selectedType = taskTypesInformation[indexPath.row].type
//        вызов обработчика
        doAfterTypeSelected?(selectedType)
//        переход к предыдущему экрану
        navigationController?.popViewController(animated: true)
    }
}
