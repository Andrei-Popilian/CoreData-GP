//
//  CoreDataMigrationStep.swift
//  CoreDataSample
//
//  Created by Andrei Popilian on 9/20/19.
//  
//

import CoreData

struct CoreDataMigrationStep {

  let sourceModel: NSManagedObjectModel
  let destinationModel: NSManagedObjectModel
  let mappingModel: NSMappingModel

  init(sourceVersion: CoreDataMigrationVersion, destinationVersion: CoreDataMigrationVersion) {
    let sourceModel = NSManagedObjectModel.managedObjectModel(forResource: sourceVersion.rawValue)
    let destinationModel = NSManagedObjectModel.managedObjectModel(forResource: destinationVersion.rawValue)

    guard let mappingModel = CoreDataMigrationStep.mappingModel(fromSourceModel: sourceModel, toDestinationModel: destinationModel) else {
      fatalError("Expected modal mapping not present")
    }

    self.sourceModel = sourceModel
    self.destinationModel = destinationModel
    self.mappingModel = mappingModel
  }

  private static func mappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
    guard let customMapping = customMappingModel(fromSourceModel: sourceModel, toDestinationModel: destinationModel) else {
      return inferredMappingModel(fromSourceModel:sourceModel, toDestinationModel: destinationModel)
    }

    return customMapping
  }

  private static func inferredMappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
    return try? NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
  }

  private static func customMappingModel(fromSourceModel sourceModel: NSManagedObjectModel, toDestinationModel destinationModel: NSManagedObjectModel) -> NSMappingModel? {
    return NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel)
  }
}
