//
//  AuthRouterCollection.swift
//  ivsa
//
//  Created by Light Dream on 19/11/2016.
//
//

import Foundation
import Vapor
import Routing
import AuthProvider

final class AuthRouteCollection: RouteCollection, EmptyInitializable {
    
    typealias Wrapped = HTTP.Responder

    func build(_ builder: RouteBuilder) throws {
        
        builder.post("login") { request in
            
            guard let username = request.json?["email"]?.string,
                let password = request.json?["password"]?.string else {
                    throw GeneralErrors.missingParams
            }
            if username.isEmpty || password.isEmpty {
                throw AuthErrors.emptyParams
            }
            
            let credentials = Password(username: username, password: password)
            let userCredentials = try IVSAUser(credentials: credentials)
            // check if user exists
            let _ = try IVSAUser.makeQuery().filter("email", credentials.username).filter("password", credentials.password).first()
            
            request.auth.authenticate(userCredentials)
            return try request.auth.assertAuthenticated(IVSAUser.self)
//            return try request.auth.authenticate(<#T##ap: Persistable & Authenticatable##Persistable & Authenticatable#>, persist: <#T##Bool#>)
        }
        
        builder .post("signup") { request in
            guard let username = request.json?["email"]?.string,
                let password = request.json?["password"]?.string else {
                    throw GeneralErrors.missingParams
            }
            
            if username.isEmpty || password.isEmpty {
                throw AuthErrors.emptyParams
            }
//            
//            do {
//                
//                try Email.validate(input: username)
//            }
//            catch _ as ValidationErrorProtocol {
//                throw AuthErrors.invalidEmail
//            }
            
            let credentials = Password(username: username, password: password)
            
            let user = try IVSAUser.register(credentials: credentials)
            do {
                // send a verification email from here? this happens once only anyway.. it's exactly where we need it
                try MailgunClient.sendVerificationEmail(toUser: user, baseURL: request.baseURL)
            } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
            
            request.auth.authenticate(user)
            return try request.auth.assertAuthenticated(IVSAUser.self)
            
        }
        
    }
}

enum AuthErrors: String, Error {
    case emptyParams
    case invalidEmail
}

