//
//  TabBarController.swift
//  TMSEntityDataSource_Example
//
//  Created by Michael Swan on 2/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import CoreData

/// This protocol makes it easier to distribute the managed object context to all of the tab bar controller's view controllers.
///
/// Doing it this way we don't have to cast each of the view controller's to their specific class to assign a managed object context.
protocol ContextAwareViewController {
    var managedObjectContext: NSManagedObjectContext? { get set }
}

// This class just takes care of passing along the managed object context. We use this method rather than having each view controller find the context and grab it themselves so that we can test each view controller in isolation using whatever context we want.
class TabBarController: UITabBarController {

    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            // We check to see if the new context is nil or not. If it isn't we pass the context onto our child view controllers
            if managedObjectContext != nil {
                passContext()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passContext()
    }
    
    private func passContext() {
        guard let moc = managedObjectContext, let kids = viewControllers as? [UINavigationController] else { return }
        // In this app all of the controllers are embeded in navigation controllers so we have to dig down a level
        for kid in kids {
            if var vc = kid.viewControllers[0] as? ContextAwareViewController {
                vc.managedObjectContext = moc
            }
        }
    }
    
}
