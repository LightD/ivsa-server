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
import Turnstile
import Routing

struct WebRouter {
    
    typealias Wrapped = HTTP.Responder
    
    private let drop: Droplet
    
    init(droplet: Droplet) {
        self.drop = droplet
    }
    
    static func buildRouter(droplet: Droplet) -> WebRouter {
        return WebRouter(droplet: droplet)
    }
    
    /// Mark: AUTH
    
    func registerRoutes(authMiddleware: SessionAuthMiddleware) {
        self.buildIndex(drop)
        self.buildEmails(drop)
        self.buildLogin(drop)
        self.buildSignup(drop)
        
        let authGroup = drop.grouped(authMiddleware)
        
        self.buildRegistration(authGroup)
        self.buildLogout(authGroup)
    }
    
    private func buildIndex<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        
        builder.get { request in
            
            do {
                guard let user: IVSAUser = try request.sessionAuth.user() else {
                    throw "redirect to auth page"
                }
                
                switch user.applicationStatus {
                case .nonApplicant, .inReview:
                    return Response(redirect: "/register")
                default:
                    // TODO: redirect to home page or something?
                    throw "just because i have a global catch, i can do this as i please :3"
                }
                
                
            }
            catch {
                return Response(redirect: "/signup")
            }
            
        }
    }
    
    private func buildEmails<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        
        builder.get("verify_email", IVSAUser.self, String.self) { request, user, verificationToken in
            
            do {
                
                if user.verificationToken != verificationToken {
                    throw "It will just show a generic error, what is this? why they try fool me?"
                }
                // since it's a success, you can now update the shit
                user.isVerified = true
                
                var mutableUser = user
                try mutableUser.save()
                
                return try self.drop.view.make("verification_success")
            }
            catch {
                let errorNode = try Node(node: ["error": true,
                                            "baseURL": request.baseURL,
                                            "userId": user.id?.string])
                return try self.drop.view.make("verification_success", errorNode)
            }
            
        }
        
        builder.get("resend_verification_email", IVSAUser.self) { request, user in
            do {
                try MailgunClient.sendVerificationEmail(toUser: user, baseURL: request.baseURL)
                return try self.drop.view.make("verification_sent")
            }
            catch {
                let errorNode = try Node(node: ["error": true,
                                                "baseURL": request.baseURL,
                                                "userId": user.id?.string])
                return try self.drop.view.make("verification_success", errorNode)
            }
            
        }
        
    }
    
    private func buildLogin<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        builder.get("login") { request in
            return try self.drop.view.make("login")
        }
        
        builder.post("login") { request in
            guard let username = request.formURLEncoded?["username"]?.string,
                let password = request.formURLEncoded?["password"]?.string else {
                    return try self.drop.view.make("login", ["flash": "Missing username or password"])
            }
            let credentials = UsernamePassword(username: username, password: password)
            do {
                _ = try request.sessionAuth.login(credentials)
                
                return Response(redirect: "/")
            } catch let e as Abort {
                switch e {
                case .custom(_, let message):
                    return try self.drop.view.make("login", ["flash": message])
                default:
                    return try self.drop.view.make("login", ["flash": "Something went wrong. Please try again later!"])
                }
            }
        }
    }
    
    private func buildSignup<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        builder.get("signup") { request in
            return try self.drop.view.make("signup")
        }
        
        builder.post("signup") { request in
            guard let username = request.formURLEncoded?["username"]?.string,
                let password = request.formURLEncoded?["password"]?.string else {
                    return try self.drop.view.make("login", ["flash": "Missing username or password"])
            }
            let credentials = UsernamePassword(username: username, password: password)
            
            do {
                let _ = try IVSAUser.register(credentials: credentials)
                _ = try request.sessionAuth.login(credentials)
                
                return Response(redirect: "/")
            }
            catch let e as Abort {
                switch e {
                case .custom(_, let message):
                    return try self.drop.view.make("signup", ["flash": message])
                default:
                    return try self.drop.view.make("signup", ["flash": "Something went wrong. Please try again later!"])
                }
            }
        }
    }
    
    private func buildRegistration<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        builder.get("register") { request in
            let user = try request.sessionAuth.user()
            let node = try Node(node: ["user": try user?.makeNode()])
            
            if user?.applicationStatus == .inReview {
                return try self.drop.view.make("application_in_review", node)
            }
            
//            return try self.drop.view.make("registration", node)

            return try self.drop.view.make("registration", ["flash": "Sorry, but the registration  has been closed. For further inquiries please contact us on our fb page."])
        }
        
        builder.get("edit_registration") { request in
            
            let user = try request.sessionAuth.user()
            if var user = user, user.accessToken == nil {
                user.generateAccessToken()
                try user.save()
            }
            
            let node = try Node(node: ["isEditMode": true, "accessToken": user!.accessToken])
            
            return try self.drop.view.make("registration", node)
        }
        
        builder.post("register") { request in
            guard var user = try request.sessionAuth.user() else {
                return Response(redirect: "/")
            }
            // now take the parameters from the request, and file a registration request
            guard let registrationJSON = request.json?["registration_data"] else {
                throw Abort.custom(status: .badRequest, message: "no json with `registration_data` found")
            }
            
            let registrationData: RegistrationData = try registrationJSON.converted()
            
            user.registrationDetails = registrationData
            user.applicationStatus = .inReview
            try user.save()
            
            return Response()
    
//            return try self.drop.view.make("registration", ["flash": "Sorry, but the registration  has been closed. For further inquiries please contact us on our fb page."])
        }
    }
    
    private func buildLogout<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        builder.post("logout") { request in
            try request.sessionAuth.logout()
            return Response(redirect: "/")
        }
    }
}

