//
//  EntityCellProtocol.swift
//  ExpensesMobile
//
//  Created by Michael Swan on 1/25/19.
//  Copyright © 2019 theMikeSwan. All rights reserved.
//

import UIKit
import CoreData

/// # EntityCellProtocol
/// `EntityCellProtocol` is a simple protocol for use by subclasses of `UITableViewCell` and `UICollectionViewCell` to declare that they can take an `NSManagedObject` and configure themselves from there.
///
/// Any table or collection view cells used in tables or collection views with `EntityTableDataSource` or `EntityCollectionDataSource` as the data source should conform to this protocol.
public protocol EntityCellProtocol {
    // TODO: Figure out how to refactor everything so that this protocol just requires there to be an entity property that is a NSManagedObject _or_ a subclass of it.
//    associatedtype ManagedObject: NSManagedObject
    /// The NSManagedObject that will be presented in the cell.
    var entity: NSManagedObject? { get set }
}
