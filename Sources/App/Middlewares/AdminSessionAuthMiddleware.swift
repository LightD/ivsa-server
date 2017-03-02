//
//  AdminSessionAuthMiddleware.swift
//  ivsa
//
//  Created by Light Dream on 26/02/2017.
//
//

import Foundation
import HTTP
import Vapor
import Auth
import TurnstileWeb

final class AdminSessionAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        do {
            // check if the access token is valid
            guard let _ = try request.adminSessionAuth.admin() else {
                throw "admin wasn't found"
            }
            
            
            // authenticated and everything, perform the request
            return try next.respond(to: request)
            
        }
        catch {
            // if there's an error, we redirect to root page, and that one decides
            return Response(redirect: "/admin")
        }
    }
    
}

public final class AdminSessionAuthHelper {
    let request: Request
    
    init(request: Request) { self.request = request }
    
    public var header: Authorization? {
        guard let authorization = request.headers["Authorization"] else {
            return nil
        }
        
        return Authorization(header: authorization)
    }
    
    func login(_ credentials: Credentials) throws -> IVSAAdmin {
        let user = try IVSAAdmin.authenticate(credentials: credentials) as! IVSAAdmin
        try request.session().data["user_id"] = user.id
        
        return user
    }
    
    func logout() throws {
        try request.session().destroy()
    }
    
    func admin() throws -> IVSAAdmin? {
        let userId: String? = try request.session().data["user_id"]?.string
        
        guard let id = userId else {
            return nil
        }
        
        
        guard let user = try IVSAAdmin.find(id) else {
            return nil
        }
        
        return user
    }
}

extension Request {
    public var adminSessionAuth: AdminSessionAuthHelper {
        
        let helper = AdminSessionAuthHelper(request: self)
        
        return helper
    }
}
