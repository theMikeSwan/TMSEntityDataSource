//
//  CategoryCollectionViewController.swift
//  TMSEntityDataSource_Example
//
//  Created by Mike Swan on 1/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
// Need to import both Core Data and TMSEntityDataSource
import CoreData
import TMSEntityDataSource

private let reuseIdentifier = "Cell"

class CategoryCollectionViewController: UICollectionViewController, ContextAwareViewController {

    private var dataSource: EntityCollectionDataSource<EventCategory>?
    
    @IBOutlet private weak var addButton: UIBarButtonItem!
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            if managedObjectContext == nil {
                addButton.isEnabled = false
            } else {
                addButton.isEnabled = true
                setupDataSource()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // We call setupDataSource() here and in the context so that whichever one is called after the context is set and the table view exists will trigger the setup.
        // Otherwise, we could end up calling setup before both things are in place which would mean nothing happens and the app doesn't work.
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }

    /// Takes care of setting up the data source after making sure the context and collection view both exist.
    ///
    /// Shows setting up a data source for a collection view that displays all entities of a given type.
    private func setupDataSource() {
        guard let moc = managedObjectContext, let collectionView = self.collectionView else { return }
        dataSource = EntityCollectionDataSource<EventCategory>(collectionView: collectionView, reuseIdentifier: reuseIdentifier, context: moc, predicate: nil)
        dataSource?.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dataSource?.initiateFetchRequest()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let vc = segue.destination as! CategoryDetailViewController
            guard let cell = sender as? EntityCellProtocol else { return }
            vc.category = cell.entity as? EventCategory
        }
    }
    
    /// Adds a new event category.
    ///
    /// Shows how to use the data source to create a new entity when you don't want to make any adjustments to the new instance.
    @IBAction func addCategory(_ sender: Any) {
        // If you don't want to make any changes to the entity when adding it simply ignore the return value. It is marked as a discardable result.
        dataSource?.addItem()
    }

}
