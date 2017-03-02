//
//  IVSAAdmin.swift
//  ivsa
//
//  Created by Light Dream on 01/12/2016.
//
//

import Foundation
import Vapor
import Fluent
import Turnstile
import TurnstileCrypto

final class IVSAAdmin: Model {
    // this is for fluent ORM
    var exists: Bool = false
    
    var id: Node?
    var email: String
    var password: String
    var accessToken: String? // when it's nil, the user is logged out
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("_id") // that's mongo's ID
        email = try node.extract("email")
        password = try node.extract("password")
        accessToken = try node.extract("access_token")
        
    }
    
    init(credentials: UsernamePassword) {
        self.email = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
        self.accessToken =  BCrypt.hash(password: credentials.password)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "_id": id,
            "email": email,
            "password": password,
            "access_token": accessToken,
            ])
    }
    
    func generateAccessToken() {
        self.accessToken =  BCrypt.hash(password: self.password)
    }
}

/// Since we are dealing with mongo, we don't need to implement this
extension IVSAAdmin: Preparation {
    static func prepare(_ database: Database) throws { }
    static func revert(_ database: Database) throws { }
}


import Auth

extension IVSAAdmin: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        var user: IVSAAdmin?
        
        switch credentials {
            
            
        case let credentials as UsernamePassword:
            let fetchedUser = try IVSAAdmin.query()
                .filter("email", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
        case let credentials as AccessToken:
            let fetchedUser = try IVSAAdmin
                .query()
                .filter("access_token", credentials.string)
                .first()
            
            if fetchedUser != nil {
                user = fetchedUser
            }
            
        default:
            throw Abort.custom(status: .badRequest, message: "Unsupported credentials.")
        }
        
        guard let u = user else {
            throw Abort.custom(status: .badRequest, message: "Incorrect credentials.")
        }
        
        return u
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        
        // create a user and
        var newUser: IVSAAdmin
        
        switch credentials {
        case let credentials as UsernamePassword:
            newUser = IVSAAdmin(credentials: credentials)
        default:
            throw Abort.custom(status: .badRequest, message: "Unsupported credentials.")
        }
        
        if try IVSAAdmin.query().filter("email", newUser.email).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw Abort.custom(status: .badRequest, message: "This email is in use, please login.")
        }
        
    }
}

import HTTP

extension Request {
    func admin() throws -> IVSAAdmin {
        
        return try self.adminAuth.admin()
    }
}
