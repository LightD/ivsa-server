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
import AuthProvider

final class AccountRouteCollection: RouteCollection, EmptyInitializable {


    
    typealias Wrapped = HTTP.Responder
    
//    private var authMiddleware: TokenAuthenticationMiddleware<IVSAUser>
//    
//    init(authMiddleware: TokenAuthenticationMiddleware<IVSAUser>) {
//        self.authMiddleware = authMiddleware
//    }
    
    
    
    func build(_ builder: RouteBuilder) throws {
        let authMiddleware = TokenAuthenticationMiddleware(IVSAUser.self)

        
        let authenticatedBuilder = builder.grouped(authMiddleware)
        
        authenticatedBuilder.post("register") { request in
//
//            throw Abort.custom(status: .badRequest, message: "Sorry, but the registration  has been closed. For further inquiries please contact us on our fb page.")
//            // now take the parameters from the request, and file a registration request
            guard let registrationJSON = request.data["registration_data"] else {
                
                throw Abort(.badRequest, reason: "no json with `registration_data` found")
            }
            
            let registrationData: RegistrationData = try registrationJSON.converted()
            
            let user = try request.auth.assertAuthenticated(IVSAUser.self)
            user.applicationStatus = .newApplicant
            user.registrationDetails = registrationData
            try user.save()
            
            return user
        }
        
        authenticatedBuilder.post("connect", "facebook") { request in
            
            
            return JSON(["status", "ok"])
        }
        
        authenticatedBuilder.post("logout") { request in
            try request.auth.unauthenticate()
            return JSON(["status": "OK"])
        }
        
        authenticatedBuilder.get("me") { request in
            return try request.auth.assertAuthenticated(IVSAUser.self)
        }
        
    }
    
}
