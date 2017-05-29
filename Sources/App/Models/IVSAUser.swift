//
//  User.swift
//  ivsa
//
//  Created by Light Dream on 14/11/2016.
//
//

import Foundation
import Vapor
import FluentProvider
import Random
import AuthProvider
import BCrypt
import HTTP

enum ApplicationStatus: String, NodeConvertible {
    case nonApplicant
    case inReview
    case newApplicant
    case accepted
    case rejected
    case confirmedRejected
    
    init(node: Node) throws {
        guard let status = ApplicationStatus(rawValue: node.string!) else {
            throw "Unknown ApplicationStatus value"
        }
        self = status
    }
    
//    
//    init(node: Node, in context: Context) throws {
//        // TODO: Add proper error handling here, instead of force unwrapping
//        
//    }

    func makeNode(in context: Context?) throws -> Node {
        return Node(stringLiteral: self.rawValue)
    }
    
    
}

struct ProofOfPayment: NodeConvertible {
    var congressPaymentPaidDate: String
    var congressPaymentRemarks: String

    var postcongressPaidDate: String
    var postcongressPaidRemarks: String

    init(node: Node) throws {
        self.congressPaymentPaidDate = try node.get("congress_payment_date")
        self.congressPaymentRemarks = try node.get("congress_payment_remarks")
        self.postcongressPaidDate = try node.get("post_congress_payment_date")
        self.postcongressPaidRemarks = try node.get("post_congress_payment_remarks")
    }

    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "congress_payment_date": congressPaymentPaidDate,
            "congress_payment_remarks": congressPaymentRemarks,
            "post_congress_payment_date": postcongressPaidDate,
            "post_congress_payment_remarks": postcongressPaidRemarks
            ])
    }
}

struct FlightDetails {
    
}

final class IVSAUserToken: Model {
    
    let storage = Storage()
    
    let token: String
    let userId: Identifier
    
    var user: Parent<IVSAUserToken, IVSAUser> {
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
extension IVSAUserToken: Preparation {
    static func prepare(_ database: Database) throws { }
    static func revert(_ database: Database) throws { }
}

final class IVSAUser: Model {

    let storage = Storage()

    var email: String
    var password: String
    var accessToken: String? // when it's nil, the user is logged out
    var applicationStatus: ApplicationStatus = .nonApplicant
    var registrationDetails: RegistrationData? // this is nil before the user registers.
    var isVerified: Bool
    var verificationToken: String = ""
    var proofOfPayment: ProofOfPayment?
    var didSendCorrectionEmail: Bool = false

    init() {
        self.email = ""
        self.password = ""
        self.isVerified = false
        self.didSendCorrectionEmail = false
    }

    convenience init(node: Node) throws {
        try self.init(node: node, in: nil)
    }

    init(node: Node, in context: Context?) throws {
        email = try node.get("email")
        password = try node.get("password")
        accessToken = try node.get("access_token")
        applicationStatus = try node.get("application_status")
        registrationDetails = try node.get("registration_details")
        isVerified = try node.get("is_verified")
        verificationToken = try node.get("verification_token")
        didSendCorrectionEmail = try node.get("correction_email_sent") ?? false
        proofOfPayment = try node.get("proof_of_payment")
    
    }

    init(credentials: Password) throws {
        self.email = credentials.username
        self.password = try drop.hash.make(credentials.password.makeBytes()).makeString()
        //try Hash.make(message: credentials.password.makeBytes()).makeString() ////BCrypt.hash(password: credentials.password)
        self.accessToken = try Hash.make(message: credentials.password.makeBytes(), with: Salt()).makeString() //  BCrypt.hash(password: credentials.password)
        self.isVerified = false
    }

    func updatePassword(pass: String) throws {
        
        // FIXME: check which hash to use
        // for reference: https://docs.vapor.codes/2.0/vapor/hash/
        let wee = try drop.hash.make(pass).makeString()
        debugPrint(wee)
        self.password = try Hash.make(message: pass.makeBytes()).makeString()
        debugPrint(self.password)
    }

    func generateAccessToken() throws {
        self.accessToken = try Hash.make(message: self.password.makeBytes(), with: Salt()).makeString()
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "email": email,
            "password": password,
            "access_token": accessToken as Any?,
            "application_status": applicationStatus,
            "registration_details": registrationDetails as Any?,
            "is_verified": isVerified,
            "verification_token": verificationToken,
            "correction_email_sent": didSendCorrectionEmail,
            "proof_of_payment": proofOfPayment as Any?
            ])
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("email", email)
        try row.set("password", password)
        try row.set("access_token", accessToken as Any?)
        try row.set("application_status", applicationStatus)
        try row.set("registration_details", registrationDetails as Any?)
        try row.set("is_verified", isVerified)
        try row.set("verification_token", verificationToken)
        try row.set("correction_email_sent", didSendCorrectionEmail)
        try row.set("proof_of_payment", proofOfPayment as Any?)
        
        return row
    }
    
    init(row: Row) throws {
        email = try row.get("email")
        password = try row.get("password")
        accessToken = try row.get("access_token")
        applicationStatus = try row.get("application_status")
        registrationDetails = try row.get("registration_details")
        isVerified = try row.get("is_verified")
        verificationToken = try row.get("verification_token")
        didSendCorrectionEmail = try row.get("correction_email_sent")
        proofOfPayment = try row.get("proof_of_payment")
    }
}
extension IVSAUser: TokenAuthenticatable {
    typealias TokenType = IVSAUserToken
//    static var tokenKey: String {
//        return "access_token"
//    }
}
extension IVSAUser: SessionPersistable { }
extension IVSAUser: PasswordAuthenticatable {
    var hashedPassword: String? {
        return self.password
    }
}

/// Since we are dealing with mongo, we don't need to implement this
extension IVSAUser: Preparation {
    static func prepare(_ database: Database) throws { }
    
    static func revert(_ database: Database) throws { }
}

extension IVSAUser: JSONRepresentable {
    func makeJSON() throws -> JSON {
        let json = JSON(try makeNode(in: jsonContext))
//        try json.set("_id", id?.string)// FIXME: wut?
        return json
    }
}

extension IVSAUser: ResponseRepresentable { }

extension IVSAUser {
    // FIXME: do like this but for admin
    static func register(credentials: Credentials) throws -> IVSAUser {

        // create a user and
        var newUser: IVSAUser

        switch credentials {
        case let credentials as Password:
            newUser = try IVSAUser(credentials: credentials)
        default:
            throw Abort(.badRequest, reason: "Unsupported credentials.")
        }

        if try IVSAUser.makeQuery().filter("email", newUser.email).first() == nil {

            try newUser.save()

            return newUser
        } else {
            throw Abort(.badRequest, reason: "This email is already in use, please login instead!")
        }

    }
}

//
//extension IVSAUser: User {
//    static func authenticate(credentials: Credentials) throws -> Auth.User {
//        var user: IVSAUser?
//        debugPrint("authenticating user with credentials: \(credentials)")
//        switch credentials {
//
//
//        case let credentials as Identifier:
//            user = try IVSAUser.find(credentials.id)
//
//        case let credentials as UsernamePassword:
//            let alldadings = try IVSAUser.query()
//                .filter("email", credentials.username)
//                .run()
//            debugPrint(alldadings)
//            
//            let fetchedUser = try IVSAUser.query()
//                .filter("email", credentials.username)
//                .first()
//
//            if let password = fetchedUser?.password,
//                password != "",
//                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
//                user = fetchedUser
//            }
//
//        case let credentials as AccessToken:
//
//            user = try IVSAUser
//                .query()
//                .filter("access_token", "\(credentials.string)")
//                .first()
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
//        var newUser: IVSAUser
//
//        switch credentials {
//        case let credentials as UsernamePassword:
//            newUser = IVSAUser(credentials: credentials)
//        default:
//            throw Abort.custom(status: .badRequest, message: "Unsupported credentials.")
//        }
//
//        if try IVSAUser.query().filter("email", newUser.email).first() == nil {
//
//            try newUser.save()
//
//            return newUser
//        } else {
//            throw Abort.custom(status: .badRequest, message: "This email is already in use, please login instead!")
//        }
//
//    }
//}
