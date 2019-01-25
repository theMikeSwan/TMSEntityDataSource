//
//  EntityCollectionDataSource.swift
//  ExpensesMobile
//
//  Created by Michael Swan on 1/25/19.
//  Copyright © 2019 theMikeSwan. All rights reserved.
//

import UIKit
import CoreData

/// `EntityCollectionDataSource` is designed to take away most of the boiler plate when presenting managed objects in collection views.
///
/// To use `EntityCollectionDataSource`:
/// - Call `init(collectionView: , reuseIdentifier: , context: , predicate: )`.
/// - If needed set the additional properties of `EntityCollectionDataSource` such as `fetchBatchSize`, `sortDescriptors`, `sectionNameKeyPath`, and `cacheName`.
/// - Call `initiateFetchRequest`, `EntityCollectionDataSource` will take care of the rest.
///
/// To add a new entity to the collection view:
/// - Call `addItem() -> Entity`
/// - Make any desired alterations to the returned entity.
///
/// Changes made to `fetchBatchSize`, `sortDescriptors`, `sectionNameKeyPath`, or `cacheName` after iniating the fetch request will have no effect.
public class EntityCollectionDataSource<Entity: NSManagedObject>: EntityDataSource<Entity>, UICollectionViewDataSource {
    private let collectionView: UICollectionView
    private let reuseID: String
    private var resultsProcessingOperations: [BlockOperation] = []
    
    /// Initalizes a new `EntityCollectionDataSource` configured for use with a collection view with the given parameters.
    ///
    /// This method will generate a data source that has instances of the entity type specified filtered by the supplied predicate.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view that should be supplied with data
    ///   - reuseIdentifier: The reuse identifier of the cells in the table view data will be supplied to.
    ///   - context: The managed object context to fetch entities from.
    ///   - filter: An NSPredicate that specifies how the results should be filtered.
    public init(collectionView: UICollectionView, reuseIdentifier: String, context: NSManagedObjectContext, predicate: NSPredicate?) {
        self.collectionView = collectionView
        self.reuseID = reuseIdentifier
        super.init(context: context, predicate: predicate)
        collectionView.dataSource = self
    }
    
    // MARK: - UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.resultsController?.sections?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.resultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let theCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseID, for: indexPath) as! UICollectionViewCell & EntityCellProtocol
        configure(cell: theCell, atIndex: indexPath)
        return theCell
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
            addResultsProcessing(operationBlock: {
                self.collectionView.insertItems(at: [newIndexPath!])
            })
        case .delete:
            addResultsProcessing(operationBlock: {
                self.collectionView.deleteItems(at: [indexPath!])
            })
        case .update:
            addResultsProcessing(operationBlock: {
                self.collectionView.reloadItems(at: [indexPath!])
            })
        case .move:
            addResultsProcessing(operationBlock: {
                self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            })
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
            addResultsProcessing(operationBlock: {
                self.collectionView.insertSections(IndexSet(integer: sectionIndex))
            })
        case .update:
            addResultsProcessing(operationBlock: {
                self.collectionView.reloadSections(IndexSet(integer: sectionIndex))
            })
        case .delete:
            addResultsProcessing(operationBlock: {
                self.collectionView.deleteSections(IndexSet(integer: sectionIndex))
            })
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
        collectionView.performBatchUpdates({
            for operation in self.resultsProcessingOperations {
                operation.start()
            }
        }, completion: { (complete) in
            self.resultsProcessingOperations.removeAll()
        })
    }
    
    /// Adds a new closure to the `resultsProcessingOperations` array that will be executed when `controllerDidChangeContent(_: )` is called.
    ///
    /// - Parameter operationBlock: A closure containing the code to updagte a specific cell or section in the collection view.
    private func addResultsProcessing(operationBlock: @escaping ()-> Void) {
        self.resultsProcessingOperations.append(BlockOperation(block: operationBlock))
    }
    
    deinit {
        for operation in resultsProcessingOperations {
            operation.cancel()
        }
        resultsProcessingOperations.removeAll()
    }
}
