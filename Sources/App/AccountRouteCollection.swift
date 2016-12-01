//
//  Router.swift
//  ivsa
//
//  Created by Light Dream on 16/11/2016.
//
//

import Foundation
import Vapor
import HTTP
import Routing


final class AccountRouteCollection: RouteCollection {
    
    typealias Wrapped = HTTP.Responder
    
    private var authMiddleware: TokenAuthMiddleware
    
    init(authMiddleware: TokenAuthMiddleware) {
        self.authMiddleware = authMiddleware
    }
    
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        
        
        let authenticatedBuilder = builder.grouped(authMiddleware)
        
        authenticatedBuilder.post("register") { request in
            
            // now take the parameters from the request, and file a registration request
            var user = try request.user()
            user.applicationStatus = .inReview
            
            try user.save()
            
            return user
        }
        
        authenticatedBuilder.post("logout") { request in
            try request.ivsaAuth.logout()
            return JSON(["status": "OK"])
        }

        
        authenticatedBuilder.get("me") { request in
            return try request.user()
        }
        
    }

}
