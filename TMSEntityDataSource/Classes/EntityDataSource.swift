//
//  EntityDataSource.swift
//  ExpensesMobile
//
//  Created by Mike Swan on 7/25/17.
//  Copyright © 2017 theMikeSwan. All rights reserved.
//

import UIKit
import CoreData

/// `EntityDataSourceProtocol` would be an abstract superclass to reduce code duplication but NSFetchedResultsController doesn't work when it is created in a superclass. As a result this protocol exists to at least reduce a little code duplication.
///
/// When implementing `initiateFetchRequest()` use `controller()` to take care of creating the controller with most settings in place. `initiateFetchRequest()` only needs to set the delegate and start the fetch (this is the part that has to be duplicated due to `NSFetchedResultsController`'s issues).
///
/// Classes thast conform to this protocol should typically be generics in the form of `EntityTableDataSource<Entity: NSManagedObject>`.
public protocol EntityDataSourceProtocol {
    associatedtype Entity: NSManagedObject
    /// The managed object context to fetch entities from.
    var context: NSManagedObjectContext {get}
    /// The predicate to use to filter the fetch results.
    var fetchPredicate: NSPredicate? {get}
    /// Takes care of actually supplying the desired entities.
    var resultsController: NSFetchedResultsController<Entity>? {get set}
    
    /// How many results to fetch at one time. The default is 0 which the fetch request treats as infinite.
    var fetchBatchSize: Int { get set }
    /// An array of the sort descriptors that should be used in the fetched results controller. (Optional)
    var sortDescriptors: [NSSortDescriptor]? { get set }
    /// Passed to the fetched results controller's `sectionNameKeyPath`. (Optional)
    var sectionNameKeyPath: String? { get set }
    /// Passed to the fetched results controller's `cacheName`. (Optional)
    var cacheName: String? { get set }
    
    /// Kicks off the fetch request.
    ///
    /// Use `controller()` to get the `NSFetchedResultsController`
    func initiateFetchRequest()
    /// Creates the fetched results controller needed for the class.
    ///
    /// Default implementation included in extension.
    func controller() -> NSFetchedResultsController<Entity>
    /// Reloads the data view container.
    func reloadData()
    /// Returns a new instance of the Entity type after inserting it into the managed object context.
    ///
    /// Default implementation included in extension.
    func addItem() -> Entity
}
extension EntityDataSourceProtocol {
    /// Creates the fetched results controller needed for the class.
    public func controller() -> NSFetchedResultsController<Entity> {
        let request = Entity.fetchRequest() as! NSFetchRequest<Entity>
        request.fetchBatchSize = self.fetchBatchSize
        request.sortDescriptors = self.sortDescriptors
        request.predicate = self.fetchPredicate
        
        let controller = NSFetchedResultsController<Entity>(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: self.sectionNameKeyPath, cacheName: self.cacheName)
        return controller
    }
    
    
    /// Returns a new instance of the Entity type after inserting it into the managed object context.
    public func addItem() -> Entity {
        let result = Entity(context: context)
        context.processPendingChanges()
        do {
            try context.save()
        } catch {
            print("Error saving context after adding entity: \(error.localizedDescription)")
        }
        return result
    }
    
}
