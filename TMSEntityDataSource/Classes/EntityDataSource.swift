//
//  EntityDataSource.swift
//  ExpensesMobile
//
//  Created by Mike Swan on 7/25/17.
//  Copyright © 2017 theMikeSwan. All rights reserved.
//

import UIKit
import CoreData

/// `EntityDataSource` is an abstract superclass that handles the common fetched results controller code for data sources that supply Core Data entities.
///
/// To subclass `EntityDataSource`:
/// - Create an initializer that calls up to `init(context: NSManagedObjectContext, predicate: NSPredicate?)`.
/// - Implement `reloadData()` as required to reload the data in the view you are supplying data to. (This is only called when `initiateFetchRequest()` is first called.)
/// - Implement any of the `NSFetchedResultsControllerDelegate` methods your subclass needs. (`EntityDataSource` does not implement any, it only declares conformance and sets itself as delegate for subclasses.)
/// - Optionally supply default values for `fetchBatchSize`, `sortDescriptors`, `sectionNameKeyPath`, and/or `cacheName`. (Changing any of these values after the fetch request has been started will have no effect.)
public class EntityDataSource<Entity: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {

    /// The managed object context to fetch entities from.
    let context: NSManagedObjectContext
    /// The predicate to use to filter the fetch results.
    private let fetchPredicate: NSPredicate?
    /// Takes care of actually supplying the desired entities.
    var resultsController: NSFetchedResultsController<Entity>?
    
    /// How many results to fetch at one time. The default is 0 which the fetch request treats as infinite.
    public var fetchBatchSize: Int = 0
    /// An array of the sort descriptors that should be used in the fetched results controller. (Optional)
    public var sortDescriptors: [NSSortDescriptor]?
    /// Passed to the fetched results controller's `sectionNameKeyPath`. (Optional)
    public var sectionNameKeyPath: String?
    /// Passed to the fetched results controller's `cacheName`. (Optional)
    public var cacheName: String?
    
    // MARK: - Initializers
    
    /// Initalizes a new `EntityDataSource` configured for use with the given parameters. This method will generate a data source that has instances of the entity type specified filtered by the supplied predicate.
    ///
    /// - Parameters:
    ///   - context: The managed object context to fetch entities from.
    ///   - predicate: (Optional) An NSPredicate that specifies how the results should be filtered.
    public init(context: NSManagedObjectContext, predicate: NSPredicate?) {
        self.context = context
        self.fetchPredicate = predicate
        super.init()
    }
    
    /// Kicks off the fetch request.
    public func initiateFetchRequest() {
        let request = Entity.fetchRequest() as! NSFetchRequest<Entity>
        request.fetchBatchSize = self.fetchBatchSize
        request.sortDescriptors = self.sortDescriptors
        request.predicate = self.fetchPredicate
        
        let controller = NSFetchedResultsController<Entity>(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: self.sectionNameKeyPath, cacheName: self.cacheName)
        controller.delegate = self
        self.resultsController = controller
        do {
            try resultsController!.performFetch()
            self.reloadData()
        } catch {
            print("Error fetching \(NSStringFromClass(Entity.self)) entities: \(error.localizedDescription)")
        }
    }
    
    /// Reloads the data view container.
    func reloadData() {    }
    
    /// Returns a new instance of the Entity type after inserting it into the managed object context.
    public func addItem() -> Entity {
        let result = Entity(context: context)
        do {
            try context.save()
        } catch {
            print("Error saving context after adding entity: \(error.localizedDescription)")
        }
        return result
    }
    
}
