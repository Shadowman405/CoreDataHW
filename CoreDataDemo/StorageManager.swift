//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Maxim Mitin on 18.08.21.
//

import CoreData
import UIKit

class StorageManager {
    
    lazy var viewContext: NSManagedObjectContext = persistentContainer.viewContext
    var taskList: [Task] = []
    
    static let shared = StorageManager()
    
    private init() {}

// MARK: - migration
    
    @objc func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func showAlert(with title: String, and massage: String) {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        //present(alert, animated: true)
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        rootVC?.present(alert, animated: true)
    }
    
    func save(_ taskName: String) {
        guard let entiyDescription = NSEntityDescription.entity(forEntityName: "Task", in: viewContext) else {
            return
        }
        guard let task = NSManagedObject(entity: entiyDescription, insertInto: viewContext) as? Task else { return }
        task.name = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        let tableView = UITableView()
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func delete()
    {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        if let tasks = try? viewContext.fetch(fetchRequest){
            for task in tasks {
                viewContext.delete(task)
            }
        }
        
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
    }
    
// MARK: - CoreData functiona from AppDelegate
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
 
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
