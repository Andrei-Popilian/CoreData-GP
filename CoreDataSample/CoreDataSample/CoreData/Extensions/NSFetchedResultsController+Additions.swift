//
//  NSFetchedResultsController+Additions.swift
//  CoreDataSample
//
//  Created by Andrei Popilian on 9/18/19.
//  
//

import CoreData

extension NSFetchedResultsController {

  @objc func performSafeFetch(completionHandler: (Error?) -> Void) {
    do {
      try performFetch()
    } catch let error {
      print("NSFetchedResultsController performFetch failed with error:\(error.localizedDescription)")
      completionHandler(error)
    }

    completionHandler(nil)
  }
}
