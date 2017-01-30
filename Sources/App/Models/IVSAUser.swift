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
import Transport
import SMTP

enum ApplicationStatus: String, NodeInitializable, NodeRepresentable {
    case nonApplicant
    case inReview
    case accepted
    case rejected
    
    init(node: Node, in context: Context) throws {
        // TODO: Add proper error handling here, instead of force unwrapping
        let status = node.string!
        self = ApplicationStatus(rawValue: status)!
    }
    
    func makeNode(context: Context) throws -> Node {
        return Node(stringLiteral: self.rawValue)
    }
}

final class IVSAUser: Model, NodeInitializable {
    // this is for fluent ORM
    var exists: Bool = false
    
    
    var id: Node?
    var email: String
    var password: String
    var accessToken: String? // when it's nil, the user is logged out
    var applicationStatus: ApplicationStatus = .nonApplicant
    var registrationDetails: RegistrationData? // this is nil before the user registers.
    var isVerified: Bool
    var verificationToken: String = URandom().secureToken
    
    init() {
        self.email = ""
        self.password = ""
        self.isVerified = false
    }
    
    init(node: Node) throws {
        id = try node.extract("_id") // that's mongo's ID
        email = try node.extract("email")
        password = try node.extract("password")
        accessToken = try node.extract("access_token")
        applicationStatus = try node.extract("application_status")
        registrationDetails = try node.extract("registration_details")
        isVerified = try node.extract("is_verified")
        verificationToken = try node.extract("verification_token")
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("_id") // that's mongo's ID
        email = try node.extract("email")
        password = try node.extract("password")
        accessToken = try node.extract("access_token")
        applicationStatus = try node.extract("application_status")
        registrationDetails = try node.extract("registration_details")
        isVerified = try node.extract("is_verified")
        verificationToken = try node.extract("verification_token")
    }
    
    init(credentials: UsernamePassword) {
        self.email = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
        self.accessToken =  BCrypt.hash(password: credentials.password)
        self.isVerified = false
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "_id": id,
            "email": email,
            "password": password,
            "access_token": accessToken,
            "application_status": applicationStatus,
            "registration_details": registrationDetails,
            "is_verified": isVerified,
            "verification_token": verificationToken
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
        debugPrint("authenticating user with credentials: \(credentials)")
        switch credentials {
        
            
        case let credentials as Identifier:
            user = try IVSAUser.find(credentials.id)
            
        case let credentials as UsernamePassword:
            let fetchedUser = try IVSAUser.query()
                .filter("email", credentials.username)
                .first()
            
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
            
        case let credentials as AccessToken:
            
            user = try IVSAUser
                .query()
                .filter("access_token", "\(credentials.string)")
                .first()
        
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
        var newUser: IVSAUser
        
        switch credentials {
        case let credentials as UsernamePassword:
            newUser = IVSAUser(credentials: credentials)
        default:
            throw Abort.custom(status: .badRequest, message: "Unsupported credentials.")
        }
        
        
        if try IVSAUser.query().filter("email", newUser.email).first() == nil {
            
            try newUser.save()
            do {
                // send a verification email from here? this happens once only anyway.. it's exactly where we need it
                try MailgunClient.sendVerificationEmail(toUser: newUser)
            } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
            
            return newUser
        } else {
            throw Abort.custom(status: .badRequest, message: "This email is already in use, please login instead!")
        }
        
    }
}

import HTTP

extension Request {
    func user() throws -> IVSAUser {
        
        return try ivsaAuth.user()
    }
}
