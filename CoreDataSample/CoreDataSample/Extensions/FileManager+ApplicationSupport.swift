//
//  FileManager+ApplicationSupport.swift
//  CoreDataSample
//
//  Created by Andrei Popilian on 9/20/19.
//  
//

import Foundation

extension FileManager {

  static func clearApplicationSupportDirectoryContents() {
    guard let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first, let applicationSupportDirectoryContents = try? FileManager.default.contentsOfDirectory(atPath: applicationSupportURL.path) else {
      return
    }
    applicationSupportDirectoryContents.forEach {
      let fileURL = URL(fileURLWithPath: applicationSupportURL.path, isDirectory: true).appendingPathComponent($0)
      try? FileManager.default.removeItem(atPath: fileURL.path)
    }
  }
}
