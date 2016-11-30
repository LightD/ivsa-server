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
        
        adminRouteBuilder.get("makenouradmin", IVSAUser.self) { request, user in
            guard let password = request.data["password"]?.string else {
                throw Abort.custom(status: .badRequest, message: "Missing param: password")
            }
            
            let credentials = UsernamePassword(username: user.email, password: password)
            var admin = IVSAAdmin(credentials: credentials)
            try admin.save()
            
            return admin
        }
        
        adminProtectedRouteBuilder.post("accept", IVSAUser.self) { request, user in
            user.applicationStatus = .accepted
            
            var user = user
            try user.save()
            
            return user
        }
        
        adminProtectedRouteBuilder.post("reject", IVSAUser.self) { request, user in
            user.applicationStatus = .rejected
            
            var user = user
            try user.save()
            
            return user
        }
        
    }
    
}

