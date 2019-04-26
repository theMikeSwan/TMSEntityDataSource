//
//  EventTableViewCell.swift
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
class EventTableViewCell: UITableViewCell, EntityCellProtocol {
    
    // Add this property to conform to EntityCellProtocol
    var entity: NSManagedObject? {
        // Add a did set observer to setup the cell whenever the entity is set.
        didSet {
            configureCell()
        }
    }
    
    
    
    // Create a private computed variable to take care of casting from NSManagedObject to the specific Entity type the cell will display.
    private var event: Event? {
        get {
            guard let event = entity as? Event else { return nil }
            return event
        }
    }
    
    // Outlets for displaying info about the entity.
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private func configureCell() {
        // Unwrap the entity and make sure we have some outlets before setting values to the outlets.
        guard let event = self.event, nameLabel != nil else { return }
        // Do any cell configuration that varies for each entity. Any cell layout that is only done once (like rounding corners and the such) should be done in a different method.
        // Remember cells get reused so don't create views here as you will end up with lots of copies eventually.
        nameLabel.text = event.name
        dateLabel.text = DateFormatter.localizedString(from: (event.date as Date?) ?? Date(), dateStyle: .medium, timeStyle: .none)
    }
}
