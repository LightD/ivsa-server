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
            if username.isEmpty || password.isEmpty {
                throw AuthErrors.emptyParams
            }
            
            
            let credentials = UsernamePassword(username: username, password: password)
            
            return try request.ivsaAuth.login(credentials)
        }
        
        builder .post("signup") { request in
            guard let username = request.json?["email"]?.string,
                let password = request.json?["password"]?.string else {
                    throw GeneralErrors.missingParams.vaporError
            }
            
            if username.isEmpty || password.isEmpty {
                throw AuthErrors.emptyParams
            }
            
            do {
                try Email.validate(input: username)
            }
            catch _ as ValidationErrorProtocol {
                throw AuthErrors.invalidEmail
            }
            
            let credentials = UsernamePassword(username: username, password: password)
            
            let user = try IVSAUser.register(credentials: credentials) as! IVSAUser
            do {
                // send a verification email from here? this happens once only anyway.. it's exactly where we need it
                try MailgunClient.sendVerificationEmail(toUser: user, baseURL: request.baseURL)
            } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
            
            return try request.ivsaAuth.login(credentials)
            
        }
        
    }
    
}

enum AuthErrors: IVSAError {
    case emptyParams
    case invalidEmail
    
    var vaporError: Abort {
        switch self {
        case .emptyParams:
            return Abort.custom(status: .forbidden, message: "You can't submit empty values!")
        case .invalidEmail:
            return Abort.custom(status: .forbidden, message: "Invalid email, please provide a valid email and try again!")
        }
    }
}

