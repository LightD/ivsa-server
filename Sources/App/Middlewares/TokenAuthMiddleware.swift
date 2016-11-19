//
//  TokenAuthMiddleware.swift
//  ivsa
//
//  Created by Light Dream on 19/11/2016.
//
//

import Foundation
import HTTP
import Vapor
import Auth

final class TokenAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        
        // if there's no access token, we flip nigga!!
        
        
        guard let accessToken = request.auth.header?.bearer else {
            throw Abort.custom(status: .networkAuthenticationRequired, message: "Unauthenticated users request this.")
        }
        
        do {
            // check if the access token is valid
            let _ = try request.ivsaAuth.login(accessToken)
        }
        catch {
            throw Abort.custom(status: .badRequest, message: "Invalid authentication credentials")
        }
    
        // authenticated and everything, perform the request
        return try next.respond(to: request)
    }
    
    
}

public final class TokenAuthHelper {
    let request: Request
    
    init(request: Request) { self.request = request }
    
    public var header: Authorization? {
        guard let authorization = request.headers["Authorization"] else {
            return nil
        }
        
        return Authorization(header: authorization)
    }
    
    func login(_ credentials: Credentials) throws -> IVSAUser {
        return try IVSAUser.authenticate(credentials: credentials) as! IVSAUser
    }
    
    func logout() throws {
        // first find the user, then update it with a clear session
        var user = try self.user()
        user.accessToken = nil
        try user.save()
    }
    
    func user() throws -> IVSAUser {
        
        // first find the user
        guard let bearerToken = self.header?.bearer else {
            throw Abort.custom(status: .unauthorized, message: "Autenticate first, then try again.")
        }
        
        guard let user = try IVSAUser.query().filter("access_token", bearerToken.string).first() else {
            throw Abort.custom(status: .unauthorized, message: "Invalid credentials.")
        }
        
        return user
    }
}

extension Request {
    public var ivsaAuth: TokenAuthHelper {
        
        let helper = TokenAuthHelper(request: self)
        
        return helper
    }
}
