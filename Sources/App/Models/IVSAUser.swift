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
    case newApplicant
    case accepted
    case rejected
    case confirmedRejected

    init(node: Node, in context: Context) throws {
        // TODO: Add proper error handling here, instead of force unwrapping
        let status = node.string!
        self = ApplicationStatus(rawValue: status)!
    }

    func makeNode(context: Context) throws -> Node {
        return Node(stringLiteral: self.rawValue)
    }
}

//struct ProofOfPayment: NodeInitializable, NodeRepresentable {
//    var congressPaymentPaidDate: String
//    var congressPaymentRemarks: String
//
//    var postcongressPaidDate: String
//    var postcongressPaidRemarks: String
//
//    init(node: Node, in context: Context) throws {
//        self.congressPaymentPaidDate = try node.extract("congress_payment_date")
//        self.congressPaymentRemarks = try node.extract("congress_payment_remarks")
//        self.postcongressPaidDate = try node.extract("post_congress_payment_date")
//        self.postcongressPaidRemarks = try node.extract("post_congress_payment_remarks")
//    }
//
//    func makeNode(context: Context) throws -> Node {
//
//        return try Node(node: [
//            "congress_payment_date": congressPaymentPaidDate,
//            "congress_payment_remarks": congressPaymentRemarks,
//            "post_congress_payment_date": postcongressPaidDate,
//            "post_congress_payment_remarks": postcongressPaidRemarks
//            ])
//    }
//}

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
    var didSendCorrectionEmail: Bool = false

    init() {
        self.email = ""
        self.password = ""
        self.isVerified = false
        self.didSendCorrectionEmail = false
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
        do {
            didSendCorrectionEmail = try node.extract("correction_email_sent")
        } catch { didSendCorrectionEmail = false }
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

        do {
            didSendCorrectionEmail = try node.extract("correction_email_sent")
        } catch { didSendCorrectionEmail = false }
    }

    init(credentials: UsernamePassword) {
        self.email = credentials.username
        self.password = BCrypt.hash(password: credentials.password)
        self.accessToken =  BCrypt.hash(password: credentials.password)
        self.isVerified = false
    }

    func updatePassword(pass: String) {
        self.password = BCrypt.hash(password: pass)
    }

    func generateAccessToken() {
        self.accessToken =  BCrypt.hash(password: self.password)
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
            "verification_token": verificationToken,
            "correction_email_sent": didSendCorrectionEmail
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
            let alldadings = try IVSAUser.query()
                .filter("email", credentials.username)
                .run()
            debugPrint(alldadings)
            
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
