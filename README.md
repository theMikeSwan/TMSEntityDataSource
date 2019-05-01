# TMSEntityDataSource

`TMSEntityDataSource` is a collection of classes designed to make populating table, collection, and picker views with Core Data entities easier.

[![CI Status](https://img.shields.io/travis/theMikeSwan/TMSEntityDataSource.svg?style=flat)](https://travis-ci.org/theMikeSwan/TMSEntityDataSource)
[![Version](https://img.shields.io/cocoapods/v/TMSEntityDataSource.svg?style=flat)](https://cocoapods.org/pods/TMSEntityDataSource)
[![License](https://img.shields.io/cocoapods/l/TMSEntityDataSource.svg?style=flat)](https://cocoapods.org/pods/TMSEntityDataSource)
[![Platform](https://img.shields.io/cocoapods/p/TMSEntityDataSource.svg?style=flat)](https://cocoapods.org/pods/TMSEntityDataSource)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first and then hit Build & Run.

### Overview of the example app

The example app lets you create, edit, and delete events with a name, date, and category, as well as create and edit the categories for those events. 

There are two tabs in the app; one for events and one for categories. The evnents are listed in a table view and the categories are in a collection view.

The detail page for events includes a picker view with all of the categories in it and the category detail view has a table view that is filtered to display only the events in the selected category. (It would be better in a production app to just use the `events` property from the selected category, but the goal of ther example app is to show the various usage patterns of `TMSEntityDataSource`.)

### Areas of Interest

#### In the Cells group
There is a custom cell class for both events and categories that take care of displaying the event or category they are given (note that the outlets are all private eliminating the urge to set them from outside the cell).

The main thing to look at in these classes is the `entity` property and the `event`/`category` property as these show how to trigger the setup of the view and one way of converting from the generic `NSManagedObject` that is `entity` to the specific entity the cell works with.

#### In the ViewControllers group
##### `EventsTableViewController.swift`
To see how the data source is setup for a table view when the view loads take a look at `setupDataSource()`.

For adding new entities to the context check out `addEvent(_:)`. This version makes a change to the newly created event, the category view shows ignoring the returned entity.

##### `CategoryCollectionViewController.swift`
To see how the data source is setup for a collection view when the view loads take a look at `setupDataSource()`.

For adding new entities to the context check out `addEvent(_:)`. Since `addItem()` is marked with `@discardableResult` you can just ignore the returned entity if you don't want to make any changes at creation.

##### `EventDetailViewController.swift`
`setupDatasource()` shows configuring an `EntityPickerDataSource`. In this example we include a blank option at the top of the picker since the category relationship is optional.

Given that there is no easy way to tell `EntityPickerDataSource` what attribute of tghe category entities we want to display in the picker view the delegate methods are left to the the client app. `EntityPickerDataSource` does provide a couple useful methods to help though…

`configureView()` shows the initial setup of the picker view after the datasource has been setup. It gets the row index for the event's category from the datasource.

`pickerView(_:, titleForRow:, forComponent: )` shows how easy it is to get the proper string to use for each row by using `EntityPickerDataSource`'s `entity(atRow:)` method. `pickerView(_:, didSelectRow:, inComponent: )` uses the same method when assigning the selected category to the event.

##### `CategoryDetailViewController.swift`
In this one `setupDataSource()` shows setting up a datasource with a predicate.

## Requirements
- iOS 11.0 or higher
- Core Data

## Installation

TMSEntityDataSource is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TMSEntityDataSource'
```
If you don't want to use CocoaPods just drag the files for whichever views you need to supply data to into your project.

## Usage



## Contributing
If you see a way in which `TMSEntityDataSource` can be improved or needs fixing by all means send me a pull request, or at least open an issue. Even if you think your change is minor send it on, it might just make all the difference for someone.

The main area that could use help right now is error handling, currently errors just get logged… not the best option.

## Author

theMikeSwan, michaelswan@mac.com

## License

TMSEntityDataSource is available under the MIT license. See the LICENSE file for more info.
