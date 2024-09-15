//
//  AccountModel.swift
//  PasswordManagerDemo
//
//  Created by Rahul Acharya on 15/09/24.
//

import Foundation

struct AccountModel: Identifiable {
    let id: UUID
    let userName: String
    let email: String
    let pass: String
}
