//
//  DelegatesSessionAuthMiddleware.swift
//  ivsa
//
//  Created by Light Dream on 30/01/2017.
//
//

import Foundation
import HTTP
import Vapor
import Auth
import TurnstileWeb

final class SessionAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        
        // if there's no access token, we flip nigga!!
        
        
        do {
            // check if the access token is valid
            let _ = try request.sessionAuth.user()
        }
        catch {
            throw Abort.custom(status: .badRequest, message: "Invalid authentication credentials")
        }
        
        // authenticated and everything, perform the request
        return try next.respond(to: request)
    }
    
    
}

public final class SessionAuthHelper {
    let request: Request
    
    init(request: Request) { self.request = request }
    
    public var header: Authorization? {
        guard let authorization = request.headers["Authorization"] else {
            return nil
        }
        
        return Authorization(header: authorization)
    }
    
    func login(_ credentials: Credentials) throws -> IVSAUser {
        let user = try IVSAUser.authenticate(credentials: credentials) as! IVSAUser
        try request.session().data["user_id"] = user.id
        
        return user
    }
    
    func logout() throws {
        try request.session().destroy()
    }
    
    func user() throws -> IVSAUser? {
        let userId: String? = try request.session().data["user_id"]?.string
        
        guard let id = userId else {
            return nil
        }
        
        
        guard let user = try IVSAUser.find(id) else {
            return nil
        }
        
        return user
    }
}

extension Request {
    public var sessionAuth: SessionAuthHelper {
        
        let helper = SessionAuthHelper(request: self)
        
        return helper
    }
}
