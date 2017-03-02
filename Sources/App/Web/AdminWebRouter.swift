//
//  AdminWebRouter.swift
//  ivsa
//
//  Created by Light Dream on 26/02/2017.
//
//

import Foundation
import Vapor
import HTTP
import Turnstile
import Routing

struct AdminWebRouter {
    
    typealias Wrapped = HTTP.Responder
    
    private let drop: Droplet
    
    init(droplet: Droplet) {
        self.drop = droplet
    }
    
    static func buildRouter(droplet: Droplet) -> AdminWebRouter {
        return AdminWebRouter(droplet: droplet)
    }
    
    func registerRoutes(authMiddleware: AdminSessionAuthMiddleware) {
        let adminBuilder = drop.grouped("admin")
        let authBuilder = adminBuilder.grouped(authMiddleware)
        
        self.buildIndex(adminBuilder)
        self.buildAuth(adminBuilder)
        
        self.buildHome(authBuilder)
    }
    
    private func buildIndex<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        builder.get { request in
            do {
                guard let _ = try request.adminSessionAuth.admin() else {
                    throw "redirect to auth page"
                }
                
                return Response(redirect: "/admin/registration")
            }
            catch {
                return Response(redirect: "/admin/login")
            }
            
        }
    }
    
    private func buildAuth<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        builder.get("login") { request in
            return try self.drop.view.make("admin/login")
        }
        
        builder.post("login") { request in
            guard let username = request.formURLEncoded?["username"]?.string,
                let password = request.formURLEncoded?["password"]?.string else {
                    return try self.drop.view.make("admin/login", ["flash": "Missing username or password"])
            }
            let credentials = UsernamePassword(username: username, password: password)
            do {
                _ = try request.adminSessionAuth.login(credentials)
                
                return Response(redirect: "/admin")
            } catch let e as Abort {
                switch e {
                case .custom(_, let message):
                    return try self.drop.view.make("admin/login", ["flash": message])
                default:
                    return try self.drop.view.make("admin/login", ["flash": "Something went wrong. Please try again later!"])
                }
            }

        }
    }
    
    private func buildHome<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        self.buildRegistration(builder)
    }
    
    private func buildRegistration<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        builder.get("registration") { request in
            let adminNode = try Node(node: request.adminSessionAuth.admin()?.makeNode())
            
            let applicants: [IVSAUser] =  try IVSAUser.query().filter("application_status", "inReview").run()
            let applicantsNode = try Node(node: applicants)
            
            return try self.drop.view.make("admin/registration", ["registration": true, "user": adminNode, "applicants": applicantsNode, "applicants_num": applicants.count])
        }
    }
}
