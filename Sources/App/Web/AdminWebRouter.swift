//
//  AdminWebRouter.swift
//  ivsa
//
//  Created by Light Dream on 26/02/2017.
//
//

import Foundation
import Vapor
import Fluent
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
        
        builder.get("register_delegate") { request in
            guard var admin = try request.adminSessionAuth.admin() else {
                throw "admin not found"
            }
            if admin.accessToken == nil {
                admin.generateAccessToken()
                try admin.save()
            }
            let adminNode = try Node(node: admin.makeNode())

            return try self.drop.view.make("admin/register_delegate", ["register_delegate": true, "user": adminNode])

            
        }
        
        builder.get("registration") { request in

            guard var admin = try request.adminSessionAuth.admin() else {
                throw "admin not found"
            }
            if admin.accessToken == nil {
                admin.generateAccessToken()
                try admin.save()
            }

            let adminNode = try Node(node: admin.makeNode())

            return try self.drop.view.make("admin/registration", ["registration": true, "user": adminNode])
        }

        builder.get("applicant_details", String.self) { request, applicantID in


            guard var admin = try request.adminSessionAuth.admin() else {
                throw "admin not found"
            }
            if admin.accessToken == nil {
                admin.generateAccessToken()
                try admin.save()
            }
//            let data = Node(value: ["accessToken": admin.accessToken!, "applicantID": applicantID])

            return try self.drop.view.make("admin/applicant_details", ["accessToken": admin.accessToken!, "applicantID": applicantID])
        }

        builder.get("waiting_listz", String.self) { request, _ in
            guard let admin = try request.adminSessionAuth.admin() else {
                throw "admin not found"
            }
            print("before making the node with admin: \(admin)")
            let node = try Node(node: ["waitlist": true, "user": admin.makeNode()])
            print("after making the node: \(node)")
            return try self.drop.view.make("admin/waitinglist", node)
        }

    }
}
