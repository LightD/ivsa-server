//
//  User.swift
//  ivsa
//
//  Created by Light Dream on 14/11/2016.
//
//

import Foundation
import Vapor
import Fluent
import Turnstile
import TurnstileCrypto

final class IVSAUser: Model {
    // this is for fluent ORM
    var exists: Bool = false
    
    
    var id: Node?
    var email: String
    var accessToken: String?
    var isDelegate: Bool = false
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("_id")
        email = try node.extract("email")
        accessToken = try node.extract("access_token")
        isDelegate = try node.extract("is_delegate")
    }
    
    init(credentials: UsernamePassword) {
        self.email = credentials.username
        self.accessToken = BCrypt.hash(password: credentials.password)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "email": email,
            "access_token": accessToken,
            "is_delegate": false
            ])
    }
    
}

/// Since we are dealing with mongo, we don't need to implement this
extension IVSAUser: Preparation {
    static func prepare(_ database: Database) throws { }
    static func revert(_ database: Database) throws { }
}


import Auth

extension IVSAUser: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: IVSAUser?
        
        switch credentials {
        
        
        case let credentials as UsernamePassword:
            let fetchedUser = try IVSAUser.query()
                .filter("email", credentials.username)
                .first()
            if let password = fetchedUser?.accessToken,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
        case let credentials as AccessToken:
            let fetchedUser = try IVSAUser
                .query()
                .filter("access_token", credentials.string)
                .first()
            
            if fetchedUser != nil {
                user = fetchedUser
            }
        
        default:
            throw UnsupportedCredentialsError()
        }
        
        guard let u = user else {
            throw IncorrectCredentialsError()
        }
        
        return u
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        
        // create a user and 
        var newUser: IVSAUser
        
        switch credentials {
        case let credentials as UsernamePassword:
            newUser = IVSAUser(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
        
        if try IVSAUser.query().filter("email", newUser.email).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
        
    }
}

import HTTP

extension Request {
    func user() throws -> IVSAUser {
        
        return try ivsaAuth.user()
    }
}
