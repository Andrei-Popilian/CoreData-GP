//
//  AppDelegate.swift
//  CoreDataSample
//
//  Created by Andrei Popilian on 9/16/19.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    if isRunningTests() {
      print("IS RUNNING TESTS")
      //do something
    }
    
    return true
  }
  
  //MARK: - Private Zone
  private func isRunningTests() -> Bool {
    let value = ProcessInfo.processInfo.environment["APP_IS_RUNNING_TESTS"]
    return value != nil
  }
}


