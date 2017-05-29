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
import FluentProvider
import AuthProvider
import Routing
import Sessions

struct AdminWebRouter: RouteCollection, EmptyInitializable {

    typealias Wrapped = HTTP.Responder
//
//    private var authMiddleware: PasswordAuthenticationMiddleware<IVSAAdmin>
    
    init() throws {
    
    }
    
    func build(_ builder: RouteBuilder) throws {
        try self.registerRoutes()
    }

    func registerRoutes() throws {
        
        let persistMiddleware = PersistMiddleware(IVSAAdmin.self)
        let authMiddleware = PasswordAuthenticationMiddleware(IVSAAdmin.self)
        
        let adminBuilder = drop.grouped("admin")
        let authBuilder = adminBuilder.grouped([persistMiddleware, authMiddleware])

        try self.buildIndex(adminBuilder)
        try self.buildAuth(adminBuilder)

        try self.buildHome(authBuilder)
    }

    
    
    private func buildIndex(_ builder: RouteBuilder) throws {
        builder.get { request in
            do {
                let _ = try request.auth.assertAuthenticated(IVSAUser.self)
                return Response(redirect: "/admin/registration")
            }
            catch {
                return Response(redirect: "/admin/login")
            }

        }
    }

    private func buildAuth(_ builder: RouteBuilder) throws {
        builder.get("login") { request in
            return try drop.view.make("admin/login")
        }

        builder.post("login") { request in
            guard let username = request.formURLEncoded?["username"]?.string,
                let password = request.formURLEncoded?["password"]?.string else {
                    return try drop.view.make("admin/login", ["flash": "Missing username or password"])
            }
            let credentials = Password(username: username, password: password)
            do {
                let adminCredentials = try IVSAAdmin(credentials: credentials)
                let _ = try request.auth.authenticate(adminCredentials, persist: true)
//                _ = try request.adminSessionAuth.login(credentials)

                return Response(redirect: "/admin")
            } catch let e as Abort {
                return try drop.view.make("admin/login", ["flash": e.reason])
//                default:
//                    return try drop.view.make("admin/login", ["flash": "Something went wrong. Please try again later!"])
//                }
            }

        }
    }

    private func buildHome(_ builder: RouteBuilder) throws {
        try self.buildRegistration(builder)
    }
    
    private func buildRegistration(_ builder: RouteBuilder) throws {
        
        builder.get("register_delegate") { request in
            let admin: IVSAAdmin = try request.auth.assertAuthenticated()
            
            if admin.accessToken == nil {
                try admin.generateAccessToken()
                try admin.save()
            }
            let adminNode = try Node(node: admin.makeNode(in: nil))

            return try drop.view.make("admin/register_delegate", ["register_delegate": true, "user": adminNode])
            
        }
        
        builder.get("registration") { request in

            let admin: IVSAAdmin = try request.auth.assertAuthenticated()
            
            if admin.accessToken == nil {
                try admin.generateAccessToken()
                try admin.save()
            }

            let adminNode = try Node(node: admin.makeNode(in: nil))

            return try drop.view.make("admin/registration", ["registration": true, "user": adminNode])
        }

        builder.get("applicant_details", String.parameter) { request in
            let applicantID = try request.parameters.next(String.self)
            let admin: IVSAAdmin = try request.auth.assertAuthenticated()

            if admin.accessToken == nil {
                try admin.generateAccessToken()
                try admin.save()
            }
//            let data = Node(value: ["accessToken": admin.accessToken!, "applicantID": applicantID])
            
            return try drop.view.make("admin/applicant_details", ["accessToken": admin.accessToken!, "applicantID": applicantID])
        }

        builder.get("waiting_list") { request in
            let admin: IVSAAdmin = try request.auth.assertAuthenticated()

            print("before making the node with admin: \(admin)")
            let node = try Node(node: ["waitlist": true, "user": try admin.makeNode(in: nil)])
            print("after making the node: \(node)")
            return try drop.view.make("admin/waitinglist", node)
        }
        
        
        builder.get("new_applicants") { request in
            let admin: IVSAAdmin = try request.auth.assertAuthenticated()

            print("before making the node with admin: \(admin)")
            let node = try Node(node: ["newapplicants": true, "user": admin.makeNode(in: nil)])
            print("after making the node: \(node)")
            return try drop.view.make("admin/new_applicants", node)
        }

    }
}
