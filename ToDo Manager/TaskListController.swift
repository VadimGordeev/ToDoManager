//
//  TaskListController.swift
//  ToDo Manager
//
//  Created by Vadim on 23/11/2025.
//

import UIKit

class TaskListController: UITableViewController {
    
    var taskStorage: TasksStorageProtocol = TasksStorage()
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
        didSet {
//            sort
            for (tasksGroupPriority, tasksGroup) in tasks {
                tasks[tasksGroupPriority] = tasksGroup.sorted { task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
//            save
            var savingArray: [TaskProtocol] = []
            tasks.forEach { _, value in
                savingArray += value
            }
            taskStorage.saveTasks(savingArray)
        }
    }
    var sectionTypesPosition: [TaskPriority] = [.important, .normal]
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func loadTasks() {
//        подготовка коллекции с задачами, использование только тех задач, для которых определена секция в таблице
        sectionTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
//        загрузка и разбор задач из хранилища
        taskStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }

    // MARK: - Table view data source

//    количество секций
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tasks.count
    }
// количество строк в определенной секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionTypesPosition[section]
        let count = tasks[taskType]?.count ?? 0
//        проверка на вывод заглушки "нет задач"
        return count > 0 ? count : 1
    }

    //    ячейка для строки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        // ячейка на основе констрейнтов
        //        return getConfiguredTaskCell_constraints(for: indexPath)
        // ячейка на основе стека
        let taskType = sectionTypesPosition[indexPath.section]
        let taskList = tasks[taskType] ?? []
        
//        вывод заглушки или ячейки с задачей
        if taskList.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noTasksCell", for: indexPath)
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = "Нет задач"
                label.textColor = .secondaryLabel
                label.textAlignment = .center
            }
            cell.selectionStyle = .none
            return cell
        } else {
            return getConfiguredTaskCell_stack(for: indexPath)
        }
    }

//    ячейка на основе ограничений
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
//        загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "taskCellConstraints",
            for: indexPath
        )
//        получаем данные о задаче, которую необходимо вывести в ячейке
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
//        текстовая метка символа
        let symbolLabel = cell.viewWithTag(1) as? UILabel
//        текстовая метка названия задачи
        let textLabel = cell.viewWithTag(2) as? UILabel
        
//        изменяем символ в ячейке
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
//        изменяем текст в ячейке
        textLabel?.text = currentTask.title
        
//        изменяем цвет текста и символа
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        
        return cell
    }
    
//  возвращаем символ для соответствующего типа задачи
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
    
//  название секций
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let tasksType = sectionTypesPosition[section]
        
        if tasksType == .important {
            title = "Important"
        } else if tasksType == .normal {
            title = "Current"
        }
        return title
    }
    
//    ячейка на основе стека
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell{
//        загружаем прототип ячейки
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
//        получаем данные о задаче, которые необходимо вывести в ячейке
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        
        return cell
    }
    
    func setTasks(_ tasksCollection: [TaskProtocol]) {
//        подготовка коллекции с задачами
//        использование только тех задач, для которых определена секция
        sectionTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
//        загрузка и разбор задач из хранилища
        tasksCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        проверяем существование задачи
        let taskType = sectionTypesPosition[indexPath.section]
        let taskList = tasks[taskType] ?? []
        //        удаление действий для заглушки
        guard !taskList.isEmpty else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        //        проверяем, что задача не является выполненной
        guard tasks[taskType]![indexPath.row].status == .planned else {
            //            снимаем выделение со строки
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
//        отмечаем задачу как выполненную
        tasks[taskType]![indexPath.row].status = .completed
//        перезагружаем секцию таблицы
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //        получаем данные о задаче, которую необходимо перевести в статус запланированна
        let taskType = sectionTypesPosition[indexPath.section]
        let taskList = tasks[taskType] ?? []
//        удаление действий для заглушки
        guard !taskList.isEmpty else { return nil }
        
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        //        действие для изменения статуса на запланирована
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Undone") {_,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView
                .reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        //        действие для перехода к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "Edit") {
            _,
            _,
            _ in
            //        загрузка сцены со storyboard
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
                identifier: "TaskEditController"
            ) as! TaskEditController
            //            передача значений задачи
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            //            передача обработчика для сохранения задачи
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
            //        переход к экрану редактирования
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        //        изменяем цвет кнопки с действием
        actionEditInstance.backgroundColor = .darkGray
        
        //        создаем объект, описывающий доступные действия
        //        в зависимости от статуса задачи будет отображено 1 или 2 действия
        let actionConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionConfiguration = UISwipeActionsConfiguration(
                actions: [actionSwipeInstance, actionEditInstance]
            )
        } else {
            actionConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
        }
        
        return actionConfiguration
    }
    
//    удаление возможности взаимодействия с заглушкой
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let taskType = sectionTypesPosition[indexPath.section]
        let taskList = tasks[taskType] ?? []

        return !taskList.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // удаляем задачу
        let taskType = sectionTypesPosition[indexPath.section]
        tasks[taskType]?.remove(at: indexPath.row)
        // удаляем строку, соответсвующую задаче
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
//        секция, из которой происходит перемещение
        let taskTypeFrom = sectionTypesPosition[sourceIndexPath.section]
//        секция, в которую происходит перемещение
        let taskTypeTo = sectionTypesPosition[destinationIndexPath.section]
        
//        безопасно извлекаем задачу, тем самым контролируя ее
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        
//        удаляем задачу с места, откуда она перенесена
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
//        вставляем задачу на новую позицию
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
//        если секция изменилась, изменяем тип задачи в соответствии с новой позицией
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        
//        обновляем данные
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
}
