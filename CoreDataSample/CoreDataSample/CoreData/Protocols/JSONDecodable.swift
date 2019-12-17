//
//  JSONDecodable.swift
//  CoreDataSample
//
//  Created by Andrei Popilian on 30/09/2019.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

protocol JSONDecodable where Self: NSManagedObject & Decodable {
  
  @discardableResult
  static func parsedToManagedObjectFromJson(_ jsonData: Data, onContext context: NSManagedObjectContext, decoder: JSONDecoder) -> Result<Self, CommonFailure>
  
  @discardableResult
  static func parsedToManagedObjectsFromJson(_ jsonData: Data, onContext context: NSManagedObjectContext, decoder: JSONDecoder) -> Result<[Self], CommonFailure>
}

extension JSONDecodable {
  
  static func parsedToManagedObjectFromJson(_ jsonData: Data, onContext context: NSManagedObjectContext, decoder: JSONDecoder) -> Result<Self, CommonFailure> {
    decoder.userInfo[CodingUserInfoKey.context!] = context
    
    do {
      let object = try decoder.decode(Self.self, from: jsonData)
      return .success(object)
      
    } catch let error {
      print("Failure while parsing Json of type \(Self.self)")
      return .failure(.error(error))
    }
  }
  
  static func parsedToManagedObjectsFromJson(_ jsonData: Data, onContext context: NSManagedObjectContext, decoder: JSONDecoder) -> Result<[Self], CommonFailure> {
    decoder.userInfo[CodingUserInfoKey.context!] = context
    
    do {
      let object = try decoder.decode([Self].self, from: jsonData)
      return .success(object)
      
    } catch let error {
      print("Failure while parsing Json of type \(Self.self)")
      return .failure(.error(error))
    }
  }
}
