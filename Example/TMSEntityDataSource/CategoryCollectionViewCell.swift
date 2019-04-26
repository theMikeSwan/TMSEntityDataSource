//
//  CategoryCollectionViewCell.swift
//  TMSEntityDataSource_Example
//
//  Created by Mike Swan on 1/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
// Need to import both Core Data and TMSEntityDataSource
import CoreData
import TMSEntityDataSource

// Declare comformance to EntityCellProtocol
class CategoryCollectionViewCell: UICollectionViewCell, EntityCellProtocol {
    // Add this property to conform to EntityCellProtocol
    var entity: NSManagedObject? {
        // Add a did set observer to setup the cell whenever the entity is set.
        didSet {
            configureCell()
        }
    }
    
    // Create a private computed variable to take care of casting from NSManagedObject to the specific Entity type the cell will display.
    private var category: EventCategory? {
        get {
            guard let category = entity as? EventCategory else { return nil }
            return category
        }
    }
    
    // Outlets for displaying info about the entity.
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    
    private func configureCell() {
        // Unwrap the entity and make sure we have some outlets before setting values to the outlets.
        guard let category = self.category, nameLabel != nil else { return }
        // Do any cell configuration that varies for each entity. Any cell layout that is only done once (like rounding corners and the such) should be done in a different method.
        // Remember cells get reused so don't create views here as you will end up with lots of copies eventually.
        nameLabel.text = category.name
        let count = category.events?.count ?? 0
        let suffix = count == 1 ? "event" : "events"
        countLabel.text = "\(count) \(suffix)"
    }
    
}
