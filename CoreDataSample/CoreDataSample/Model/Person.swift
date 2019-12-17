import CoreData

@objc(Person)
open class Person: _Person {
  
  enum PersonErrorType: Error {
    case invalidAge
    case invalidAgeMinValue
    case invalidAgeMaxValue
    case invalidName
    case invalidNameMaxChars
    //etc
  }

  @nonobjc
  class func fetchCustomRequest() -> NSFetchRequest<Person> {
    return NSFetchRequest(entityName: self.entityName())
  }
  
  /// Validate interproperty before inserting
  override open func validateForInsert() throws {
    try super.validateForInsert()
    
    //do interproperty Validation HERE
    //e.g if firstname and lastname are identical
  }
  
  /// Validate interproperty before updating the entitity
  override open func validateForUpdate() throws {
    try super.validateForUpdate()
  }
  
  /// Validate interproperty before deleting an entity
  override open func validateForDelete() throws {
    try super.validateForDelete()
  }
  
  override open func validateValue(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKey key: String) throws {
    try super.validateValue(value, forKey: key)
    
    //do property Validation HERE
    
    switch key {
    case PersonAttributes.age.rawValue:
      try doAgeValidation(value)
      
    case PersonAttributes.name.rawValue:
      try doNameValidation(value)
      
    default:
      return
    }
  }
}

private extension Person {
  
  func doAgeValidation(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
    print("Doing Age Validation...")
  }
  
  func doNameValidation(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
    print("Doing Name Validation...")
  }
}
