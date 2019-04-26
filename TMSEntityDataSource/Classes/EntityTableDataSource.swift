//
//  EntityTableDataSource.swift
//  ExpensesMobile
//
//  Created by Michael Swan on 1/25/19.
//  Copyright © 2019 theMikeSwan. All rights reserved.
//

import UIKit
import CoreData

/// `EntityTableDataSource` is designed to take away most of the boiler plate when presenting managed objects in table views.
///
/// To use `EntityTableDataSource`:
/// - Call `init(tableView: , reuseIdentifier: , context: , predicate: )`.
/// - If needed set the additional properties of `EntityTableDataSource` such as `fetchBatchSize`, `sortDescriptors`, `sectionNameKeyPath`, and `cacheName`.
/// - Call `initiateFetchRequest`, `EntityTableDataSource` will take care of the rest.
///
/// To add a new entity to the table view:
/// - Call `addItem() -> Entity`
/// - Make any desired alterations to the returned entity.
///
/// Changes made to `fetchBatchSize`, `sortDescriptors`, `sectionNameKeyPath`, or `cacheName` after iniating the fetch request will have no effect.
final public class EntityTableDataSource<Entity: NSManagedObject>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate, EntityDataSourceProtocol {
    
    /// The managed object context to fetch entities from.
    public let context: NSManagedObjectContext
    /// The predicate to use to filter the fetch results.
    public let fetchPredicate: NSPredicate?
    /// Takes care of actually supplying the desired entities.
    public var resultsController: NSFetchedResultsController<Entity>?
    
    /// How many results to fetch at one time. The default is 0 which the fetch request treats as infinite.
    public var fetchBatchSize: Int = 0
    /// An array of the sort descriptors that should be used in the fetched results controller. (Optional)
    public var sortDescriptors: [NSSortDescriptor]?
    /// Passed to the fetched results controller's `sectionNameKeyPath`. (Optional)
    public var sectionNameKeyPath: String?
    /// Passed to the fetched results controller's `cacheName`. (Optional)
    public var cacheName: String?
    
    
    /// The table view to supply entities to.
    private let tableView: UITableView
    /// The reuse ID for cells in the table view.
    private let reuseID: String
    
    /// Initalizes a new `EntityTableDataSource` configured for use with a given table view and parameters.
    ///
    /// This method will generate a data source that has instances of the entity type specified filtered by the supplied predicate.
    ///
    /// - Parameters:
    ///   - tableView: The table view that should be supplied with data
    ///   - reuseIdentifier: The reuse identifier of the cells in the table view data will be supplied to.
    ///   - context: The managed object context to fetch entities from.
    ///   - predicate: (Optional) An NSPredicate that specifies how the results should be filtered.
    public init(tableView: UITableView, reuseIdentifier: String, context: NSManagedObjectContext, predicate: NSPredicate?) {
        self.tableView = tableView
        self.reuseID = reuseIdentifier
        self.context = context
        self.fetchPredicate = predicate
        super.init()
        
        
        tableView.dataSource = self
    }
    
    public func initiateFetchRequest() {
        let theController = controller()
        theController.delegate = self
        self.resultsController = theController
        do {
            try resultsController!.performFetch()
            self.reloadData()
        } catch {
            print("Error fetching \(NSStringFromClass(Entity.self)) entities: \(error.localizedDescription)")
        }
    }
    
    public func reloadData() {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.resultsController?.sections?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theCell = self.tableView.dequeueReusableCell(withIdentifier: self.reuseID, for: indexPath) as! UITableViewCell & EntityCellProtocol
        configure(cell: theCell, atIndex: indexPath)
        return theCell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.context.delete( self.resultsController!.object(at: indexPath))
            self.context.processPendingChanges()
            do {
                try context.save()
            } catch {
                print("Error saving context after deleting entity: \(error.localizedDescription)")
            }
        } else if editingStyle == .insert {
            _ = self.addItem()
        }
    }
    
    /// Configures a given table view cell for the specified index path.
    ///
    /// - Parameters:
    ///   - cell: The cell to be configured.
    ///   - indexPath: The index path of the cell to be configured.
    fileprivate func configure(cell: EntityCellProtocol, atIndex indexPath: IndexPath) {
        var theCell = cell
        theCell.entity = self.resultsController?.object(at: indexPath)
    }
    
    // MARK: - Fetched Results Controller
    
    /// Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
    ///
    /// This method is invoked before all invocations of `controller(_:didChange:at:for:newIndexPath:)` and `controller(_:didChange:atSectionIndex:for:)` have been sent for a given change event (such as the controller receiving a `NSManagedObjectContextDidSave` notification).
    ///
    /// - Parameter controller: The fetched results controller that sent the message.
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    /// Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
    ///
    /// The fetched results controller reports changes to its section before changes to the fetch result objects.
    /// Changes are reported with the following heuristics:
    ///
    /// - On add and remove operations, only the added/removed object is reported.
    /// - It’s assumed that all objects that come after the affected object are also moved, but these moves are not reported.
    /// - A move is reported when the changed attribute on the object is one of the sort descriptors used in the fetch request.
    /// - An update of the object is assumed in this case, but no separate update message is sent to the delegate.
    /// - An update is reported when an object’s state changes, but the changed attributes aren’t part of the sort keys.
    ///
    /// # Special Considerations
    /// This method may be invoked many times during an update event (for example, if you are importing data on a background thread and adding them to the context in a batch). You should consider carefully whether you want to update the table view on receipt of each message.
    ///
    /// - Parameters:
    ///   - controller: The fetched results controller that sent the message.
    ///   - anObject: The object in controller’s fetched results that changed.
    ///   - indexPath: The index path of the changed object (this value is nil for insertions).
    ///   - type: The type of change. For valid values see `NSFetchedResultsChangeType`.
    ///   - newIndexPath: The destination path for the object for insertions or moves (this value is nil for a deletion).
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configure(cell: self.tableView.cellForRow(at: indexPath!)! as! EntityCellProtocol, atIndex: indexPath!)
        case .move:
            self.configure(cell: self.tableView.cellForRow(at: indexPath!)! as! EntityCellProtocol, atIndex: indexPath!)
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    /// Notifies the receiver of the addition or removal of a section.
    ///
    /// The fetched results controller reports changes to its section before changes to the fetched result objects.
    ///
    /// # Special Considerations
    /// This method may be invoked many times during an update event (for example, if you are importing data on a background thread and adding them to the context in a batch). You should consider carefully whether you want to update the table view on receipt of each message.
    ///
    /// - Parameters:
    ///   - controller: The fetched results controller that sent the message.
    ///   - sectionInfo: The section that changed.
    ///   - sectionIndex: The index of the changed section.
    ///   - type: The type of change (insert or delete). Valid values are `NSFetchedResultsChangeType.insert` and `NSFetchedResultsChangeType.delete`.
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            self.tableView.reloadSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        }
    }
    
    /// Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
    ///
    /// This method is invoked after all invocations of `controller(_:didChange:at:for:newIndexPath:)` and `controller(_:didChange:atSectionIndex:for:)` have been sent for a given change event (such as the controller receiving a `NSManagedObjectContextDidSave` notification).
    ///
    /// - Parameter controller: The fetched results controller that sent the message.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
