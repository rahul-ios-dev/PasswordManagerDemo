//
//  Account+CoreDataProperties.swift
//  PasswordManagerDemo
//
//  Created by Rahul Acharya on 15/09/24.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var password: String?

}

extension Account : Identifiable {

}
