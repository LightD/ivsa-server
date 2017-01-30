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

extension String: Error {
    
}

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
                
                // TODO: check the application status and redirect based on that one.
                switch user.applicationStatus {
                default: break
                }
                
                return Response(redirect: "/register")
            }
            catch {
                return Response(redirect: "/signup")
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
            return try self.drop.view.make("registration", node)
        }
    }
    
    private func buildLogout<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        builder.post("logout") { request in
            try request.sessionAuth.logout()
            return Response(redirect: "/")
        }
    }
}

