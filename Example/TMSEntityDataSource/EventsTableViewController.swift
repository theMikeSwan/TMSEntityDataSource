//
//  EventsTableViewController.swift
//  TMSEntityDataSource_Example
//
//  Created by Mike Swan on 1/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
// Need to import both Core Data and TMSEntityDataSource
import CoreData
import TMSEntityDataSource

class EventsTableViewController: UITableViewController, ContextAwareViewController {

    private let reuseIdentifier = "Cell"
    private var dataSource: EntityTableDataSource<Event>?
    
    @IBOutlet private weak var addButton: UIBarButtonItem!
    
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            // We check to see if the new context is nil or not. If it isn't we enable the add button (can't very well add entities if we have no context) and setup the data source
            if managedObjectContext == nil {
                addButton.isEnabled = false
            } else {
                addButton.isEnabled = true
                setupDataSource()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // We call setupDataSource() here and in the context so that whichever one is called after the context is set and the table view exists will trigger the setup.
        // Otherwise, we could end up calling setup before both things are in place which would mean nothing happens and the app doesn't work.
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    /// Takes care of setting up the data source after making sure the context and table view both exist.
    private func setupDataSource() {
        // We call this when the context is set which could be before the view has loaded so we make sure the table view exists as well as the context before proceeding
        guard let moc = managedObjectContext, let tableView = self.tableView else { return }
        dataSource = EntityTableDataSource<Event>(tableView: tableView, reuseIdentifier: reuseIdentifier, context: moc, predicate: nil)
        dataSource?.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        dataSource?.initiateFetchRequest()
    }

    @IBAction func addEvent(_ sender: Any) {
        // EntityDataSource will return the newly created entity so you can set any initial values.
        let event = dataSource?.addItem()
        event?.name = "Awesome Event!"
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            guard let cell = sender as? EventTableViewCell else { return }
            let vc = segue.destination as! EventDetailViewController
            vc.event = cell.entity as? Event
        }
    }
    

}
