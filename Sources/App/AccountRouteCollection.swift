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
//
//            throw Abort.custom(status: .badRequest, message: "Sorry, but the registration  has been closed. For further inquiries please contact us on our fb page.")
//            // now take the parameters from the request, and file a registration request
            guard let registrationJSON = request.json?["registration_data"] else {
                throw Abort.custom(status: .badRequest, message: "no json with `registration_data` found")
            }
            
            let registrationData: RegistrationData = try registrationJSON.converted()
            
            var user = try request.user()
            user.applicationStatus = .newApplicant
            user.registrationDetails = registrationData
            
            try user.save()
            
            return user
        }
        
        authenticatedBuilder.post("connect", "facebook") { request in
            
            
            return JSON(["status", "ok"])
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
