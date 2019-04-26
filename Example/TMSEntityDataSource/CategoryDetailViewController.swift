//
//  CategoryDetailViewController.swift
//  TMSEntityDataSource_Example
//
//  Created by Mike Swan on 1/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
// Need to import both Core Data and TMSEntityDataSource
import CoreData
import TMSEntityDataSource

class CategoryDetailViewController: UIViewController {
    
    var category: EventCategory? {
        didSet {
            if category != nil {
                configureView()
            }
        }
    }
    
    private let reuseIdentifier = "Cell"
    private var dataSource: EntityTableDataSource<Event>?

    @IBOutlet private weak var nameLabel: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    /// Takes care of setting up the data source after making sure the context and table view both exist.
    private func setupDataSource() {
        // We call this when the context is set which could be before the view has loaded so we make sure the table view exists as well as the context before proceeding
        guard let category = self.category, let moc = category.managedObjectContext, let tableView = self.tableView else { return }
        // In this case we only want the events that belong to the current category.
        // Note that we could also grab the events set from the category and display the contents. It is done this way here to show how easy it is to add a predicate to filter the entities returned by the data source.
        let predicate = NSPredicate(format: "category == %@", category)
        dataSource = EntityTableDataSource<Event>(tableView: tableView, reuseIdentifier: reuseIdentifier, context: moc, predicate: predicate)
        dataSource?.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        dataSource?.initiateFetchRequest()
    }
    
    private func configureView() {
        guard let category = self.category, nameLabel != nil else { return }
        nameLabel.text = category.name
        setupDataSource()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowExpenseDetail" {
            guard let cell = sender as? EventTableViewCell else { return }
            let vc = segue.destination as! EventDetailViewController
            vc.event = cell.entity as? Event
        }
    }
    
    @IBAction func updateCategoryName(_ sender: UITextField) {
        category?.name = sender.text
    }
    
}
