import Foundation
import CoreData

@objc(Event)
final class Event: _Event, Codable, JSONDecodable {
  // Custom logic goes here.
  
  enum CodingKeys: String, CodingKey {
    case name = "firstName"
  }
  
  /// Decodes the Json into an Event object and inserts it into the database
  /// - Parameter decoder: the decoder used to decode the Event object
  /// - Note: Make sure you add the managed object context to the "decoder.userInfo" dictionary, under the "CodingUserInfoKey.context" key
  public required convenience init(from decoder: Decoder) throws {
    
    guard let contextKey = CodingUserInfoKey.context,
      let context = decoder.userInfo[contextKey] as? NSManagedObjectContext,
      let entity = Event.entity(managedObjectContext: context) else {
        fatalError("Failed to decode Event")
    }
    
    self.init(entity: entity, insertInto: context)
    
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
  }
  
  // MARK: - Encodable
  public func encode(to encoder: Encoder) throws {
    
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
  }
}
