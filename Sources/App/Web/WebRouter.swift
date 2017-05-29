//
//  WebRouter.swift
//  ivsa
//
//  Created by Light Dream on 29/01/2017.
//
//

import Foundation
import Vapor
import HTTP
import Routing
import Sessions
import AuthProvider
import FluentProvider

final class WebRouter: RouteCollection, EmptyInitializable {
    
    /// Mark: AUTH
//    private var authMiddleware: PasswordAuthenticationMiddleware<IVSAUser>
//    
//    
    typealias Wrapped = HTTP.Responder

    func build(_ builder: RouteBuilder) throws {
        try self.registerRoutes()
    }
    
    init() throws { }
    
    func registerRoutes() throws {
        try self.buildIndex(drop)
        try self.buildEmails(drop)
        try self.buildLogin(drop)
        try self.buildSignup(drop)

        let persistMiddleware = PersistMiddleware(IVSAUser.self)
        let authMiddleware = PasswordAuthenticationMiddleware(IVSAUser.self)

        let authGroup = drop.grouped([persistMiddleware, authMiddleware])

        try self.buildRegistration(authGroup)
        try self.buildLogout(authGroup)
    }

    private func buildIndex(_ builder: RouteBuilder) throws {
        
        builder.get { request in

            do {
                let _ = try request.auth.assertAuthenticated(IVSAUser.self)
                
                return Response(redirect: "/register")

//                switch user.applicationStatus {
//                case .nonApplicant, .inReview:
//                default:
//                    // TODO: redirect to home page or something?
//                    throw "just because i have a global catch, i can do this as i please :3"
//                }


            }
            catch {
                return Response(redirect: "/signup")
            }

        }
    }

    private func buildEmails(_ builder: RouteBuilder) throws {

        builder.get("verify_email", IVSAUser.parameter, String.parameter) { request in
            // FIXME: New syntax, make sure it works
            let user: IVSAUser = try request.parameters.next(IVSAUser.self)
            let verificationToken = try request.parameters.next(String.self)
            do {

                if user.verificationToken != verificationToken {
                    throw "It will just show a generic error, what is this? why they try fool me?"
                }
                // since it's a success, you can now update the shit
                user.isVerified = true
                try user.save()

                return try drop.view.make("verification_success")
            }
            catch {
                let errorNode = try Node(node: ["error": true,
                                            "baseURL": request.baseURL,
                                            "userId": user.id?.string ?? ""])
                return try drop.view.make("verification_success", errorNode)
            }

        }

        builder.get("resend_verification_email", IVSAUser.parameter) { request in
            let user: IVSAUser = try request.parameters.next(IVSAUser.self)
            do {
                try MailgunClient.sendVerificationEmail(toUser: user, baseURL: request.baseURL)
                return try drop.view.make("verification_sent")
            }
            catch {
                let errorNode = try Node(node: ["error": true,
                                                "baseURL": request.baseURL,
                                                "userId": user.id?.string ?? ""])
                return try drop.view.make("verification_success", errorNode)
            }

        }

    }

    private func buildLogin(_ builder: RouteBuilder) throws {
        
        builder.get("login") { request in
            return try drop.view.make("login")
        }

        builder.post("login") { request in
            guard let username = request.formURLEncoded?["username"]?.string,
                let password = request.formURLEncoded?["password"]?.string else {
                    return try drop.view.make("login", ["flash": "Missing username or password"])
            }
            let credentials = Password(username: username, password: password)
            do {
                let userCredentials = try IVSAUser(credentials: credentials)
                guard let _ = try IVSAUser.makeQuery().filter("email", credentials.username).filter("password", credentials.password).first() else {
                    throw Abort(.badRequest, reason: AuthErrors.invalidEmail.rawValue)
                }
                
                _ = try request.auth.authenticate(userCredentials, persist: true)

                return Response(redirect: "/")
            } catch let e as Abort {
                return try drop.view.make("login", ["flash": e.reason])
            }
        }
    }

    private func buildSignup(_ builder: RouteBuilder) throws {
        builder.get("signup") { request in
            return try drop.view.make("signup")
        }

        builder.post("signup") { request in
            guard let username = request.formURLEncoded?["username"]?.string,
                let password = request.formURLEncoded?["password"]?.string else {
                    return try drop.view.make("login", ["flash": "Missing username or password"])
            }
            let credentials = Password(username: username, password: password)

            do {
                
                let userCredentials = try IVSAUser(credentials: credentials)
                // FIXME: Do actual creation of user
                let _ = try IVSAUser.makeQuery().filter("email", credentials.username).filter("password", credentials.password).first()
                
                try request.auth.authenticate(userCredentials, persist: true)
                let user: IVSAUser = try request.auth.assertAuthenticated()
                do {
                    // send a verification email from here? this happens once only anyway.. it's exactly where we need it
                    try MailgunClient.sendVerificationEmail(toUser: user, baseURL: request.baseURL)
                } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
                
                return Response(redirect: "/")
            }
            catch let e as Abort {
                
                return try drop.view.make("signup", ["flash": e.reason])
//                default:
//                    return try drop.view.make("signup", ["flash": "Something went wrong. Please try again later!"])
//                }
            }
        }
    }

    private func buildRegistration(_ builder: RouteBuilder) throws {
        builder.get("register") { request in
            let user: IVSAUser = try request.auth.assertAuthenticated()
            var data = ["user": try user.makeNode(in: nil)]
            var node = try Node(node: data)

            if user.applicationStatus == .nonApplicant {
                return try drop.view.make("registration", node)
            }
            
            if let studentId = user.registrationDetails?.personalInfo.studentId, studentId.isEmpty {
                data["flash"] = "You must fill in your student ID to continue using the rest of the functionality"
            }
            node = try Node(node: data)
            return try drop.view.make("application_in_review", node)
            
//            return try drop.view.make("registration", ["flash": "Sorry, but the registration  has been closed. For further inquiries please contact us on our fb page."])
        }

        builder.get("edit_registration") { request in

            let user: IVSAUser = try request.auth.assertAuthenticated()
            if user.accessToken == nil {
                try user.generateAccessToken()
                try user.save()
            }

            let node = try Node(node: ["isEditMode": true, "accessToken": user.accessToken ?? ""])

            return try drop.view.make("registration", node)
        }

        builder.post("register") { request in
            let user: IVSAUser = try request.auth.assertAuthenticated()
                
            // now take the parameters from the request, and file a registration request
            guard let registrationJSON = request.data["registration_data"] else {
                throw Abort(.badRequest, reason: "no json with `registration_data` found")
            }

            let registrationData: RegistrationData = try registrationJSON.converted()

            user.registrationDetails = registrationData
            user.applicationStatus = .newApplicant
            try user.save()
//            try request.sessionAuth.logout()
            return Response(redirect: "/")

//            return try drop.view.make("registration", ["flash": "Sorry, but the registration  has been closed. For further inquiries please contact us on our fb page."])
        }
    }

    private func buildLogout(_ builder: RouteBuilder) throws {
        builder.post("logout") { request in
            try request.auth.unauthenticate()
            return Response(redirect: "/")
        }
        
        builder.get("unsubscribed") { request in
            return try drop.view.make("unsubscribe")
        }
    }
}
