//
//  TaskEditController.swift
//  ToDo Manager
//
//  Created by Vadim on 29/11/2025.
//

import UIKit

class TaskEditController: UITableViewController {
    
    var taskText: String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    private var taskTitles: [TaskPriority: String] = [
        .important: "Important",
        .normal: "Normal"
    ]
    
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        let title = taskTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !title.isEmpty else {
            let alertController = UIAlertController(title: "The task name must not be empty", message: "Please enter task title", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed : .planned
        doAfterEdit?(title, type, status)
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle?.text = taskText
        taskTypeLabel?.text = taskTitles[taskType]
        if taskStatus == .completed {
            taskStatusSwitch.isOn = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
//      ссылка на контроллер назначения
            let destination = segue.destination as! TaskTypeController
//            передача выбранного типа
            destination.selectedType = taskType
//            передача обработчика выбора типа
            destination.doAfterTypeSelected = { [unowned self] selectedType in
                taskType = selectedType
//                обновляем метку с текущим типом
                taskTypeLabel?.text = taskTitles[taskType]
            }
            
        }
    }
}
