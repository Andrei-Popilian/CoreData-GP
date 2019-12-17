
# Core Data Good Practices

<kbd>
<img width="200" alt="InheritanceContext" src="https://avatars2.githubusercontent.com/u/55535985?s=460&v=4">
</kbd>

##

[![Platform](https://img.shields.io/static/v1?label=platform&message=iOS&color=green)](https://github.com/Good-Practices/CoreData_Sample)
[![Swift](https://img.shields.io/static/v1?label=Swift&message=100%&color=important)](https://github.com/Good-Practices/CoreData_Sample)
[![iOS Support](https://img.shields.io/static/v1?label=iOS%20Support&message=%3E=%2010.0&color=blue)](https://github.com/Good-Practices/CoreData_Sample)
[![License](https://img.shields.io/static/v1?label=license&message=MIT&color=important)](https://en.wikipedia.org/wiki/MIT_License)


Take this project as a Core Data good practices example.

Some things that Core Data can do beyond most databases:

* Make sure bidirectional relationships are properly hooked up
* Use custom data validation rules
* Use custom data migration logic
* Store specific attributes outside the primary store location
* Serialize custom attribute types as Data
* Index content using Spotlight
* Automatic schema and data migration

Having these abilities means you can have Core Data take care of a lot more logic for you than if you were using a traditional database.

## Table of Contents
 * [Debugging](#debugging)
 * [Theading](#theading)
 * [Mogenerator](#mogenerator)
 * [Migrations](#migrations)
 * [Tools](#tools)
 * [Good practices or TLDR](#good-practices-in-few-words-or-tldr)
 * [Custom Implementations](#custom-implementations)
 * [Collaborators](#collaborators)
 * [Contributing](#contributing)
  * [References](#references)

## Debugging

While debugging please use runtime arguments: *(EditScheme -> Run Tab -> Arguments)

Argument | Description
------------ | -------------
<img width=600/>|<img width=300/>
-com.apple.CoreData.ConcurrencyDebug 1 | Throws an exception whenever your app access a managed object context or managed object from a wrong dispatch queue
-com.apple.CoreData.SQLDebug 1 | 1, 2 or 3 for a more verbose output, logs in console about how CoreData manages SQL fetches, details about queries, etc. 
-com.apple.CoreData.MigrationDebug | Gives you insights in the console about exceptional cases as it migrates data

## Theading

 Keep  **"viewContext"**  read-only, only for fetches 
 Never ever use an **"NSManagedObject"** outside its context’s queue
 
 Core Data tries to be efficient; it typically doesn’t like to load up more data than you need, which means there are times when you ask it for data (like an object property) and it doesn’t have it handy. When this happens, it has to go load the data from its store (which might not even be a local file on disk!) before it can respond to you.

 This is called “faulting”. The marker value internal kept by a managed object is a “fault”, and the process of “fulfilling” (ie, retrieving the data) the fault is “faulting”.

 Here’s the thing: Core Data has to be safe. It has to synchronize these faulting calls with other accesses of the persistent store, and it has to do it in a way that isn’t going to interfere with other calls to fault in data. The way it does that is by expecting that all calls to fault in data happen safely inside one of its queues.

 Every managed object “belongs” to a particular MOC (more on this in a minute), and every MOC has a DispatchQueue that it uses to synchronize its internal logic about loading data from its persistentStoreCoordinator.

 If you use an NSManagedObject from outside the MOC’s queue, then the calls to fault in data are not properly synchronized and protected, which means you’re susceptible to race conditions.

 So, if you have an NSManagedObject, the only safe place to use it is from inside a call to perform or performAndWait
 
 The only managed object property that is safe to use outside of a queue or pass between queues/threads is the object’s **objectID**: this is a Core Data-provided identifier unique for that particular object. You can access this property from anywhere, and it is the only way to “transfer” a managed object from one context to another.
 
 
 ## Mogenerator
 
 Mogenerator is a command-line tool that, given an .xcdatamodel file, will generate two classes per entity. The first class, **_MyEntity**, is intended solely for machine consumption and will be continuously overwritten to stay in sync with your data model. 
 The second class, **MyEntity**, subclasses **_MyEntity**, won't ever be overwritten and is a great place to put your custom logic.
 It supports generating Swift classes and other custom typed entities or properties, e.g enums instead of Scalar or non-scalar type.
 
 How to use it:
 1. Create another **Target** as "Aggregate" to your project
 1. Setup an run script action on it's **Build Phases** as e.g >>> _mogenerator -m YourProjectName/YourModelName.xcdatamodeld/YourModelVersions_v2.xcdatamodel -O PathWhere/ToBeExported --swift --template-var arc=true_
 1. Build this "Mogenerator" **Target** everytime you change your current Core Data model
 
 * [How to Install Mogenerator](http://rentzsch.github.io/mogenerator)
 * You can check this tutorial [Mogenerator Usage](https://raptureinvenice.com/getting-started-with-mogenerator)
 * [Mogenerator Documentation](https://github.com/rentzsch/mogenerator/wiki)
 

 
 ## Migrations
 
 Core Data does lightweight migration for free, like adding new properties (with default values), renaming old ones, etc *(You will have to add a new version of your model file)
 Lightweight migration can perform:
 * Adding an attribute.
 * Removing an attribute.
 * Changing a non-optional attribute to be optional.
 * Changing an optional attribute to non-optional (by defining a default value).
 * Renaming an entity, attribute or relationship (by providing a Renaming ID).
 * Adding a relationship.
 * Removing a relationship.
 * Changing the entity hierarchy.
 
 The default Core Data model migration approach is to go from earlier version to all possible future versions.

 So, if we have 4 model versions (1, 2, 3, 4), you would need to create the following mappings 1 to 4, 2 to 4 and 3 to 4.
 Then when we create model version 5, we would create mappings 1 to 5, 2 to 5, 3 to 5 and 4 to 5. You can see that for each
 new version we must create new mappings from all previous versions to the current version. This does not scale well. For each new version you must add n-1 new mappings.

 Instead the new solution uses an iterative approach where we migrate mutliple times through a chain of model versions.

 So, if we have 4 model versions (1, 2, 3, 4), you would need to create the following mappings 1 to 2, 2 to 3 and 3 to 4.
 Then when we create model version 5, we only need to create one additional mapping 4 to 5. This greatly reduces the work
 required when adding a new version.
 
 - Inside the Policy class use the objects as NSManagedObject (using KVC) instead of the current model type, later those will be changed/removed and you will have to rewrite your code
 - In case of heavyweight migration don't remove the new entities from the mapperModel .xcmappingmodel, it will missmatch your models and the policy is never executed
 
 Steps for a new xcdatamodel version and migration:
 1. Create a new model, modify/add/remove/change names of some entities.
 1. Create a new model version and add it to the CoreDataMigrationVersion as well to "nextVersion" function inside it
 1. Migrate:
    1. If the migration is lightweight you don't have to do anything else, the current Sample setup will do that automatically
    1. If the migration is heavyweight you will have to create a new model Mapping file (**.xcmappingmodel**) and if needed a policy for each custom new Model or for the  nextVersion of an existing model
 1. If you are doing unit tests, check our Sample UnitTest Target and add a test for the next migration + sqlite to be tested(note: keep them light in terms of memory, you want to run them fast and keep your Version Control cloud, light as well)


## Tools

- [**DB Browser for SQLite**](https://sqlitebrowser.org) used to manipulate or check the data base and do queries

## Good practices in few words or TLDR


* Make the model as small as you can, add only entities that are ment to be persisted, the computed ones can later be crafted.


* Try to avoid performing multiple writes in parallel, use a serial synchronous queue in background instead e.g
<p align="center">
<img width="700" alt="PerformAndWait" src="https://user-images.githubusercontent.com/45980382/65870097-c4939680-e37b-11e9-8f8b-93462b8bf63e.png">
</p>


* Use **NSFetchRequest**'s fetchBatchSize (to save memory, instead of fetching the entire data at once, Core Data will help you fetch it in batches, Note: by default is 0 which is infinite) e.g 
<p align="center">
<img width="400" alt="FetchBatchSize" src="https://user-images.githubusercontent.com/45980382/65870176-df660b00-e37b-11e9-845e-60e6a5a8c62b.png">
</p>


* Use **NSExpressions** for not sorting things in memory, Core Data does it better. For a better understanding of **NSExpressions** please check NSHipster's [POST](https://nshipster.com/nsexpression) or Apple's [Documetation](https://developer.apple.com/documentation/foundation/nsexpression/1413747-init)


* While using **NSPredicate** is better to use the number comparison first _e.g if we want to get objects that have a specific name and age, use the age first, the computer work faster with numbers_. More details about **NSPredicate** [HERE](https://docs.mapbox.com/ios/api/maps/4.4.1/predicates-and-expressions.html)


* **NSPredicate** Costs
<p align="center">
<img width="600" alt="Predicate Costs" src="https://user-images.githubusercontent.com/45980382/65521451-8add0e80-dee9-11e9-9f53-e8002aa5e447.png">
</p>


* Allow external storage for a Binary Data _e.g if you are using photos, the system might decide where is better to store them, in memory or on disk, depending on their size and a certain treshold *(toggle that in the attribute inspector of that field)_ e.g
<p align="center">
<img width="700" alt="ExternalStorage" src="https://user-images.githubusercontent.com/45980382/65870291-2e13a500-e37c-11e9-889a-36b79b513592.png">
</p>


* Translate binary large data objects(BLOBs) as separate entities _e.g a large photo and you just want to use as a tumbnail, you add the photo in a separate entity with relationship and keep only the tumbnail in the main entity_.
A good rule will be: 
1. more than 100 kb store in the related entity (person, address, whatever).
1. more than 1 mb store in a separate entity on the other end of a relationship to avoid performance issues.
1. less than 1 mb store on disk and reference the path in your Core Data store.


* Work in batches to keep the memory low **NSBatchUpdateRequest** it can save half of the memory using the loop approach _e.g you have to update a large data set_. Please check the following post for a better understanding [HERE](https://medium.com/@rajanmaheshwari1990/nsbatchupdaterequest-in-swift-and-its-advantage-2f956726a939)


* If you need to use the pervious Inserted/Updated or Deleted objects in context, use the **NSManagedObjectContext**'s instance variables (insertedObjects, updatedObjects, deletedObjects) before saving, instead of saving the context and fetching the data again.
<p align="center">
<img width="600" alt="Inserted" src="https://user-images.githubusercontent.com/45980382/65878397-4d1b3280-e38e-11e9-92b5-f9ee0f59b32b.png">
</p>



* There are multiple architecture approaches as **CoreDataStack**, I suggest to choose between **ContextInheritance** or **SharedPSC**, those 2 have the more pros than other current stacks (for simple to medium sized apps). Use the one that fits your data Set


* **ContextInheritance** *(if you try to avoid contexts conflics and use the current **NSManagedObjectContext**'s **mergePolicy** if happens to have some minor conflicts)
<p align="center">
<img width="500" alt="SharePSC" src="https://user-images.githubusercontent.com/45980382/65521424-7c8ef280-dee9-11e9-8024-489bea0d5d69.png">
</p>


* **SharedPSC** (if you want to easier manage the changes between your contexts, see **mergeChanges** using notifications)
<p align="center">
<img width="600" alt="SharePSC" src="https://user-images.githubusercontent.com/45980382/65521446-87e21e00-dee9-11e9-9a4b-f6a0b762c6e2.png">
</p>


* Use **NSCompoundPredicate** instead of creating a large predicate with AND, OR, (it's convenient and can be used with computed predicates). See [Apple Documetation](https://developer.apple.com/documentation/foundation/nscompoundpredicate)


* **NSManagedObjectContext** is not thread safe, must pe used on the queue it was created on (e.g ViewContext for the Main Thread and the other ones on the Background Thread)


* Set the **Inverse** when using relations, it's helps Core Data to maintain data integrity
<p align="center">
<img width="700" alt="Inverse" src="https://user-images.githubusercontent.com/45980382/65870349-56030880-e37c-11e9-8e9a-ec45eaba4f98.png">
</p>


## Custom Implementations

*  **CoreDataSample** follows the **ContextInheritance**  CoreDataStack, you can check the entire implementation in **CoreDataManager.swift** file

* Core Data doesn't support **Codable** protocol by default(there are inconsitencies on their init func), however I did a custom implementation showing that you can work with both(Core Data and Codable). The only downside is that you will have to do the parsing by yourself in **init(decoder:)** function. Please check **JSONDecodable.swift** protocol and  **Event.swift** file for the implementation details.

 
## Collaborators
[<kbd>
<img width="50" alt="Andrei-Popilian" src="https://avatars2.githubusercontent.com/u/45980382?s=180&v=4">
</kbd>](https://github.com/Andrei-Popilian)


## Contributing

Feel free to contribute to this project by providing [ideas](https://github.com/Andrei-Popilian/CoreData-GP/issues) or opening [pull requests](https://github.com/Andrei-Popilian/CoreData-GP/pulls) with new good practices/tools or solving an existing issue.


## References

[Progressive CoreData Migration](https://williamboles.me/progressive-core-data-migration)

[Laws Of CoreData](https://davedelong.com/blog/2018/05/09/the-laws-of-core-data)

[Effective Core Data with Swift](https://www.youtube.com/watch?v=w7tFF7IfKVk)

[Apple's CoreData advanced Topic](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/Performance.html)
 
