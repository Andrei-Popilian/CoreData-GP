//
//  FileManager+Additions.swift
//  CoreDataSampleTests
//
//  Created by Andrei Popilian on 9/23/19.
//  
//

import Foundation

extension FileManager {
  
  static func clearTempDirectoryContents() {
    let tmpDirectoryContents = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
    tmpDirectoryContents.forEach {
      let fileURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent($0)
      try? FileManager.default.removeItem(atPath: fileURL.path)
    }
  }
  
  static func moveFileFromBundleToTempDirectory(filename: String) -> URL {
    let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(filename)
    try? FileManager.default.removeItem(at: destinationURL)
    let bundleURL = Bundle(for: CoreDataMigratorTests.self).resourceURL!.appendingPathComponent(filename)
    try? FileManager.default.copyItem(at: bundleURL, to: destinationURL)
    
    return destinationURL
  }
}
