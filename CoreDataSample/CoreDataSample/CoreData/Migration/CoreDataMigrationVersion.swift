//
//  CoreDataMigrationVersion.swift
//  CoreDataSample
//
//  Created by Andrei Popilian on 9/20/19.
//  
//

import CoreData

enum CoreDataMigrationVersion: String, CaseIterable {
  case version1 = "CoreDataSample"
  case version2 = "CoreDataSample_v2"
  
  static var current: CoreDataMigrationVersion {
    guard let latest = allCases.last else {
      fatalError("no model versions found")
    }
    
    return latest
  }
  
  func nextVersion() -> CoreDataMigrationVersion? {
    switch self {
    case .version1:
      return .version2
    case .version2:
      return nil
    }
  }
}

