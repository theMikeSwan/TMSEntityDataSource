# TMSEntityDataSource

`TMSEntityDataSource` is a collection of classes designed to make populating table, collection, and picker views with Core Data entities easier.

[![CI Status](https://img.shields.io/travis/theMikeSwan/TMSEntityDataSource.svg?style=flat)](https://travis-ci.org/theMikeSwan/TMSEntityDataSource)
[![Version](https://img.shields.io/cocoapods/v/TMSEntityDataSource.svg?style=flat)](https://cocoapods.org/pods/TMSEntityDataSource)
[![License](https://img.shields.io/cocoapods/l/TMSEntityDataSource.svg?style=flat)](https://cocoapods.org/pods/TMSEntityDataSource)
[![Platform](https://img.shields.io/cocoapods/p/TMSEntityDataSource.svg?style=flat)](https://cocoapods.org/pods/TMSEntityDataSource)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first and then hot Build & Run.

The example app lets you create, edit, and delete events with a name, date, and category. 

The Events tab has a table view showing all of the events. It is run by `EventsTableViewController`.

Tapping on an event will take you to the event detail screen that has a picker view containing all of the event categories. If you want to see how to use the picker data source check out `EventDetailViewController`.

The Categories tab has a collection view displaying all of the categories along with how many events there are in each category. It is run by `CategoryCollectionViewController` if you want to see how to use the collection view data source.

Tapping on a category cell will take you to the `CategoryDetailViewController`'s screen where you will see a table view of events that are attached to the selected category. This is done by using a `EntityTableDataSource` with a predicate if you want an example of filtering the data source with a predicate. (Note that it would be easier to grab the entities from the `events` relationship but that wouldn't supply you with a demo of how to add a predicate.)

You should also take a look at `EventTableViewCell` and `CategoryCollectionViewCell` to see how the `EntityCellProtocol` is used.

All of the code has comments throughout to help guide you through. If anything isn't clear feel free to open an issue or, better yet, change the comments as you see fit and create a pull request.

## Requirements
iOS 11.0 or higher

## Installation

TMSEntityDataSource is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TMSEntityDataSource'
```
If you don't want to use CocoaPods just drag `EntityDataSource` and the corresponding data source classes for whichever views you need to supply data to into your project.

## Usage

## Contributing
If you see a way in which `TMSEntityDataSource` can be improved or needs fixing by all means send me a pull request, or at least open an issue. Even if you think your change is minor send it on, it might just make all the difference for someone.

The main area that could use help right now is error handling, currently errors just get logged… not the best option…

## Author

theMikeSwan, michaelswan@mac.com

## License

TMSEntityDataSource is available under the MIT license. See the LICENSE file for more info.
