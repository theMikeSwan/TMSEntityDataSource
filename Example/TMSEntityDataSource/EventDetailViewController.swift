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

class EventDetailViewController: UIViewController, UIPickerViewDelegate {
    
    
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
        categoryPicker.selectRow((dataSource.row(for: category) ?? 0), inComponent: 0, animated: false)
    }
    
    /// Takes care of setting up the data source after making sure the category picker exists and grabbing the context from the event (provided it exists).
    private func setupDataSource() {
        guard let moc = event?.managedObjectContext, let categoryPicker = self.categoryPicker else { return }
        categoryDataSource = EntityPickerDataSource<EventCategory>(pickerView: categoryPicker, context: moc, predicate: nil, includeBlankOption: true)
        categoryDataSource?.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        categoryDataSource?.initiateFetchRequest()
        categoryPicker.delegate = self
    }
    
    // MARK: - UIPickerViewDataSource
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // This just lets the user set no category for an event.
        if row == 0 { return " " }
        // While the delegate is the one that supplies the text that appears in the picker EntityPickerDatasource makes things easy for us.
        // We pass the row number we need the category for and grab out the attribute we want to display.
        return categoryDataSource?.entity(atRow: row)?.name ?? ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // If the user selected the first row there is no category so we set it to nil
        guard row != 0 else {
            event?.category = nil
            return
        }
        // Here we ask the data source what entity is at the selected row and assign that to the event's category.
        event?.category = categoryDataSource?.entity(atRow: row)
    }
    
    // MARK: - Actions
    
    @IBAction func updateEventName(_ sender: UITextField) {
        event?.name = sender.text
    }

    @IBAction func updateEventDate(_ sender: UIDatePicker) {
        event?.date = datePicker.date as NSDate
    }
}
