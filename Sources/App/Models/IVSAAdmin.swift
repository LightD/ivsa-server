//
//  IVSAAdmin.swift
//  ivsa
//
//  Created by Light Dream on 01/12/2016.
//
//

import Foundation
import Vapor
import FluentProvider
import Random
import AuthProvider
import BCrypt

final class IVSAAdmin: Model {
    
    let storage = Storage()
    
    var email: String
    var password: String
    var accessToken: String? // when it's nil, the user is logged out
    
    init(node: Node) throws {
        email = try node.get("email")
        password = try node.get("password")
        accessToken = try node.get("access_token")
        
    }
    
    init(credentials: Password) throws {
        self.email = credentials.username
        self.password = try Hash.make(message: credentials.password.makeBytes()).makeString()
        self.accessToken = try Hash.make(message: credentials.password.makeBytes(), with: Salt()).makeString()
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "email": email,
            "password": password,
            "access_token": accessToken as Any?,
            ])
    }
    
    func generateAccessToken() throws {
        self.accessToken = try Hash.make(message: self.password.makeBytes(), with: Salt()).makeString()
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("email", email)
        try row.set("password", password)
        try row.set("access_token", accessToken as Any?)
        return row
    }
    init(row: Row) throws {
        email = try row.get("email")
        password = try row.get("password")
        accessToken = try row.get("access_token")
    }
}

/// Since we are dealing with mongo, we don't need to implement this
extension IVSAAdmin: Preparation {
    static func prepare(_ database: Database) throws { }
    static func revert(_ database: Database) throws { }
}

extension IVSAAdmin: SessionPersistable { }

extension IVSAAdmin: JSONRepresentable {
    func makeJSON() throws -> JSON {
        return JSON(try makeNode(in: jsonContext))
    }
}
extension IVSAAdmin: ResponseRepresentable { }

extension IVSAAdmin: TokenAuthenticatable {
    typealias TokenType = IVSAAdminToken
    static var tokenKey: String {
        return "access_token"
    }
}

extension IVSAAdmin: PasswordAuthenticatable {
    
}

final class IVSAAdminToken: Model {
    
    let storage = Storage()
    
    let token: String
    let userId: Identifier
    
    var user: Parent<IVSAAdminToken, IVSAAdmin> {
        return parent(id: userId)
    }
    
    init(userId: Identifier, token: String) throws {
        self.token = try Hash.make(message: token.makeBytes(), with: Salt()).makeString()
        self.userId = userId
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("user_id", userId)
        return row
    }
    
    init(row: Row) throws {
        self.token = try row.get("token")
        self.userId = try row.get("user_id")
    }
}
extension IVSAAdminToken: Preparation {
    static func prepare(_ database: Database) throws { }
    static func revert(_ database: Database) throws { }
}



//
//extension IVSAAdmin: Auth.User {
//    static func authenticate(credentials: Credentials) throws -> Auth.User {
//        var user: IVSAAdmin?
//        
//        switch credentials {
//            
//            
//        case let credentials as UsernamePassword:
//            let fetchedUser = try IVSAAdmin.query()
//                .filter("email", credentials.username)
//                .first()
//            if let password = fetchedUser?.password,
//                password != "",
//                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
//                user = fetchedUser
//            }
//        case let credentials as AccessToken:
//            let fetchedUser = try IVSAAdmin
//                .query()
//                .filter("access_token", credentials.string)
//                .first()
//            
//            if fetchedUser != nil {
//                user = fetchedUser
//            }
//            
//        default:
//            throw Abort.custom(status: .badRequest, message: "Unsupported credentials.")
//        }
//        
//        guard let u = user else {
//            throw Abort.custom(status: .badRequest, message: "Incorrect credentials.")
//        }
//        
//        return u
//    }
//    
//    static func register(credentials: Credentials) throws -> Auth.User {
//        
//        // create a user and
//        var newUser: IVSAAdmin
//        
//        switch credentials {
//        case let credentials as UsernamePassword:
//            newUser = IVSAAdmin(credentials: credentials)
//        default:
//            throw Abort.custom(status: .badRequest, message: "Unsupported credentials.")
//        }
//        
//        if try IVSAAdmin.query().filter("email", newUser.email).first() == nil {
//            try newUser.save()
//            return newUser
//        } else {
//            throw Abort.custom(status: .badRequest, message: "This email is in use, please login.")
//        }
//        
//    }
//}
//
//import HTTP
//
//extension Request {
//    func admin() throws -> IVSAAdmin {
//        
//        return try self.adminAuth.admin()
//    }
//}
