//
//  Event+CoreDataClass.swift
//  TMSEntityDataSource_Example
//
//  Created by Mike Swan on 1/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Event)
public class Event: NSManagedObject {

    public override func awakeFromInsert() {
        self.date = Date() as NSDate
    }
}
