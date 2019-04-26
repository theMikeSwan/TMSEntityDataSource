//
//  EventCategory+CoreDataProperties.swift
//  TMSEntityDataSource_Example
//
//  Created by Mike Swan on 1/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
//

import Foundation
import CoreData


extension EventCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventCategory> {
        return NSFetchRequest<EventCategory>(entityName: "EventCategory")
    }

    @NSManaged public var name: String?
    @NSManaged public var events: NSSet?

}

// MARK: Generated accessors for events
extension EventCategory {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}
