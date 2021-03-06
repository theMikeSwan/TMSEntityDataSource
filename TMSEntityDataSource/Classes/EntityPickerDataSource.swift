//
//  EntityPickerDataSource.swift
//  ExpensesMobile
//
//  Created by Michael Swan on 1/25/19.
//  Copyright © 2019 theMikeSwan. All rights reserved.
//

import UIKit
import CoreData

/// # EntityPickerDataSource
/// `EntityPickerDataSource` is designed to take away most of the boiler plate when presenting managed objects in picker views.
///
/// To use `EntityPickerDataSource`:
/// - Call `init(pickerView: , context: , predicate: )`.
/// - If desired set `sortDescriptors` and/or `cacheName`.
/// - Call `initiateFetchRequest`.
/// - Call `entity(atRow: )` from the picker view's delegate as needed to get the entity for a particular row.
///
/// Note: `UIPickerViewDataSource` only supplies the number of components in a picker view and the number of rows in a component, the rest comes from the `UIPickerViewDelegate`.
///
/// Changes made to `sortDescriptors` or `cacheName` after iniating the fetch request will have no effect.
///
/// For picker views you should not alter `fetchBatchSize`.
///
/// Altering `sectionNameKeyPath` will have no effect for picker views.
final public class EntityPickerDataSource<Entity: NSManagedObject>: NSObject, UIPickerViewDataSource, NSFetchedResultsControllerDelegate, EntityDataSourceProtocol {
    private let picker: UIPickerView?
    private let includeBlankOption: Bool
    
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
    
    /// Initalizes a new `EntityPickerDataSource` configured for use with a picker view with the given parameters.
    ///
    /// This method will generate a data source that has instances of the entity type specified filtered by the supplied predicate.
    ///
    /// - Parameters:
    ///   - pickerView: The picker view that should be supplied with data
    ///   - context: The managed object context to fetch entities from.
    ///   - predicate: An NSPredicate that specifies how the results should be filtered.
    ///   - includeBlankOption: Bool that indicates if there should be one blank option in the picker. Defaults to `false`.
    public init(pickerView: UIPickerView, context: NSManagedObjectContext, predicate: NSPredicate?, includeBlankOption: Bool = false) {
        self.picker = pickerView
        self.context = context
        self.fetchPredicate = predicate
        self.includeBlankOption = includeBlankOption
        super.init()
        picker?.dataSource = self
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
        picker?.reloadAllComponents()
    }
    
    // MARK: - Fetched Results Controller
    
    /// Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
    ///
    /// This method is invoked after all invocations of `controller(_:didChange:at:for:newIndexPath:)` and `controller(_:didChange:atSectionIndex:for:)` have been sent for a given change event (such as the controller receiving a `NSManagedObjectContextDidSave` notification).
    ///
    /// - Parameter controller: The fetched results controller that sent the message.
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reloadData()
    }
    
    // MARK: - UIPickerViewDataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = self.resultsController?.fetchedObjects?.count ?? 0
        if includeBlankOption {
            count += 1
        }
        return count
    }
    
    /// Supplies the entity at a given row.
    ///
    /// This method is useful for the `UIPickerViewDelegate`'s `pickerView(_: , titleForRow: , forComponent: )` and `pickerView(_: , didSelectRow: , inComponent: )` methods.
    ///
    /// This method takes into account if there is a blank line in the picker view and will offset the returned index accordingly so no math is required on the passed in index.
    /// You will get back `nil` if the passed in Int is outside the bounds of the results.
    ///
    /// - Parameter atRow: The index of the desired entity.
    /// - Returns: The entity that is at the given index of the fetched objects.
    public func entity(atRow: Int) -> Entity? {
        guard let results = resultsController?.fetchedObjects else {
            return nil
        }
        var index = atRow
        if includeBlankOption {
            index -= 1
        }
        guard index >= 0, index < results.count else { return nil }
        return results[index]
    }
    
    /// Supplies the row index for a given entity, provided the entity exists in the results set.
    ///
    /// This method takes into account if there is a blank line in the picker view and will offset the returned index accordingly so no math is required on the result.
    ///
    /// - Parameter entity: The entity for which the row index is desired.
    /// - Returns: The row index, if it exists, of the entity.
    public func row(for entity: Entity) -> Int? {
        guard let results = resultsController?.fetchedObjects else {
            return nil
        }
        var index = results.firstIndex(of: entity)
        if index != nil, includeBlankOption {
            index! += 1
        }
        return index
    }
}
