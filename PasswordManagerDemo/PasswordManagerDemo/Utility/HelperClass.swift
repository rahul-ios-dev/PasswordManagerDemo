//
//  HelperClass.swift
//  PasswordManagerDemo
//
//  Created by Rahul Acharya on 15/09/24.
//

import Foundation

struct HelperClass {
    static func printDocumentsDirectoryPath() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let documentsDirectory = paths.first {
            print("Documents Directory path: \(documentsDirectory.path)")
        }
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        // Regex pattern for validating email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
