//
//  DataAttachmentMigrationV1toV2.swift
//  CoreDataSample
//
//  Created by Andrei Popilian on 9/19/19.
//  
//

import CoreData


final class Event1ToEven2MigrationPolicy: NSEntityMigrationPolicy {

  override func createDestinationInstances(forSource sourceInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {

    try super.createDestinationInstances(forSource: sourceInstance, in: mapping, manager: manager)

    guard let destinationPost = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sourceInstance]).first else {
      fatalError("was expected a post")
    }

    var dataAttachmentInstance: NSManagedObject!
    let data = sourceInstance.value(forKey: "data") as! String

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DataAttachment")

    fetchRequest.predicate = NSPredicate(format: "data == %@", data)
    let results = try manager.destinationContext.fetch(fetchRequest)
    
    if let resultInstance = results.first as? NSManagedObject {
      dataAttachmentInstance = resultInstance
    } else {
      dataAttachmentInstance = NSEntityDescription.insertNewObject(forEntityName: "DataAttachment", into: destinationPost.managedObjectContext!)
      dataAttachmentInstance.setValue(data, forKey: "data")

    }

    destinationPost.setValue(dataAttachmentInstance, forKey: "dataAttachment")
  }
}
