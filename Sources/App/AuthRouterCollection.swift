//
//  AuthRouterCollection.swift
//  ivsa
//
//  Created by Light Dream on 19/11/2016.
//
//

import Foundation
import Auth
import Turnstile
import Vapor
import HTTP
import Routing


final class AuthRouteCollection: RouteCollection {
    
    typealias Wrapped = HTTP.Responder
    
    
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        
        builder.post("login") { request in
            
            guard let username = request.json?["email"]?.string,
                let password = request.json?["password"]?.string else {
                    throw GeneralErrors.missingParams.vaporError
            }
            
            let credentials = UsernamePassword(username: username, password: password)
            
            return try request.ivsaAuth.login(credentials)
        }
        
        builder.post("signup") { request in
            guard let username = request.json?["email"]?.string,
                let password = request.json?["password"]?.string else {
                    throw GeneralErrors.missingParams.vaporError
            }
            
            let credentials = UsernamePassword(username: username, password: password)
            
            let _ = try IVSAUser.register(credentials: credentials)
            
            return try request.ivsaAuth.login(credentials)
            
            
        }
        
    }
    
}
