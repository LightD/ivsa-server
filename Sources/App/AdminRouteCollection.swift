//
//  AdminRouterCollection.swift
//  ivsa
//
//  Created by Light Dream on 01/12/2016.
//
//

import Foundation
import Auth
import Turnstile
import Vapor
import HTTP
import Routing

class AdminRouteCollection: RouteCollection {
    
    typealias Wrapped = HTTP.Responder
    
    private var authMiddleware: AdminAuthMiddleware
    
    
    init(authMiddleware: AdminAuthMiddleware) {
        self.authMiddleware = authMiddleware
    }
    
    
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        let adminRouteBuilder = builder.grouped("admin")
        let adminProtectedRouteBuilder = adminRouteBuilder.grouped(self.authMiddleware)
        
        
        
        adminRouteBuilder.post("login") { request in
            
            guard let username = request.json?["email"]?.string,
                let password = request.json?["password"]?.string else {
                    throw GeneralErrors.missingParams.vaporError
            }
            
            let credentials = UsernamePassword(username: username, password: password)
            
            return try request.adminAuth.login(credentials)
        }
        
        adminRouteBuilder.get("makenouradmin") { request in
            
            let credentials = UsernamePassword(username: "admin@ivsa.com", password: "ivsa")
            var admin = IVSAAdmin(credentials: credentials)
            try admin.save()
            
            return admin
        }
        
        
        adminRouteBuilder.get("me") { request in
            return try request.admin()
        }
        
        // accepted values for :application_status param are:
        // inReview
        // accepted
        // rejected
        adminProtectedRouteBuilder.get("delegates", ":application_status") { request in
            let appStatus = try request.parameters.extract("application_status") as String
            let users: [IVSAUser] =  try IVSAUser.query().filter("application_status", appStatus).run()
            let json = try JSON(node: Node(node: users))
            debugPrint(json)
            
            return json
        }
//        
//        adminProtectedRouteBuilder.post("accept", IVSAUser.self) { request, user in
//            user.applicationStatus = .accepted
//            
//            var user = user
//            try user.save()
//            
//            return user
//        }
//        
//        adminProtectedRouteBuilder.post("reject", IVSAUser.self) { request, user in
//            user.applicationStatus = .rejected
//            
//            var user = user
//            try user.save()
//            
//            return user
//        }
        
    }
    
}

