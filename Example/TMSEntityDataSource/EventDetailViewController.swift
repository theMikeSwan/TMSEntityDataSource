//
//  EventDetailViewController.swift
//  TMSEntityDataSource_Example
//
//  Created by Mike Swan on 1/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
// Need to import both Core Data and TMSEntityDataSource
import CoreData
import TMSEntityDataSource

class EventDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    var event: Event? {
        didSet {
            if event != nil {
                configureView()
            }
        }
    }

    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var categoryPicker: UIPickerView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    private var categoryDataSource: EntityPickerDataSource<EventCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    private func configureView() {
        guard let event = self.event, nameField != nil else { return }
        nameField.text = event.name
        datePicker.setDate((event.date as Date?) ?? Date(), animated: false)
        setupDataSource()
        // If we don't have a data source yet the picker has 0 components and 0 rows so we can't do anything with it.
        guard let dataSource = categoryDataSource else { return }
        // If the event doesn't have a category we set the picker to the blank row.
        guard let category = event.category else {
            categoryPicker.selectRow(0, inComponent: 0, animated: false)
            return
        }
        // We know which category the event belongs to now but need the row. EntityPickerDataSource has us covered.
        // We do need to add one to the row it gives us because of our blank line at the beginning
        categoryPicker.selectRow((dataSource.row(for: category) ?? 0) + 1, inComponent: 0, animated: false)
    }
    
    /// Takes care of setting up the data source after making sure the category picker exists and grabbing the context from the event (provided it exists).
    private func setupDataSource() {
        guard let moc = event?.managedObjectContext, let categoryPicker = self.categoryPicker else { return }
        categoryDataSource = EntityPickerDataSource<EventCategory>(pickerView: categoryPicker, context: moc, predicate: nil)
        categoryDataSource?.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        categoryDataSource?.initiateFetchRequest()
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
    }
    
    // MARK: - UIPickerViewDataSource
    // We set ourselves as the data source so that we can insert a blank line at the beginning of the picker, otherwise we would let the categoryDataSource take care of these two methods for us.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // Here we just make sure the data source exists before passing the value from the category data source.
        guard let dataSource = categoryDataSource else { return 0 }
        return dataSource.numberOfComponents(in: pickerView)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let dataSource = categoryDataSource else { return 0 }
        // Here we add one to whatever the category data source gives us. The extra is for a blank line in the picker as events can have no category
//        var numRows = dataSource.pickerView(pickerView, numberOfRowsInComponent: component)
//        print("The picker's data source says there are \(numRows) rows")
//        numRows += 1
//        return numRows
        return (dataSource.pickerView(pickerView, numberOfRowsInComponent: component) + 1)
    }
    
    // MARK: - UIPickerViewDataSource
    // We always need to implement the delegate methods for two reasons.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // This just lets the user set no category for an event.
        if row == 0 { return " " }
        // Here is our first reason to implement the delegate methods. The data source doesn't know what property from the entities it finds should be used in the picker, that varies by use case.
        // The picker data source still makes things easy for us though, we just ask for the entity we need and grab the property we want to display
        return categoryDataSource?.entity(atRow: row - 1).name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // If the user selected the first row there is no category so we set it to nil
        guard row != 0 else {
            event?.category = nil
            return
        }
        // Here we ask the data source what entity is at the selected row (subtracting 1 to compensate for our empty row) and assign that to the event's category.
        event?.category = categoryDataSource?.entity(atRow: row - 1)
    }
    
    // MARK: - Actions
    
    @IBAction func updateEventName(_ sender: UITextField) {
        event?.name = sender.text
    }

    @IBAction func updateEventDate(_ sender: UIDatePicker) {
        event?.date = datePicker.date as NSDate
    }
}
