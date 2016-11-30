//
//  AdminMiddleware.swift
//  ivsa
//
//  Created by Light Dream on 01/12/2016.
//
//

import Foundation
import HTTP
import Vapor
import Auth

final class AdminAuthMiddleware: Middleware {
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

public final class AdminAuthHelper {
    let request: Request
    
    init(request: Request) { self.request = request }
    
    public var header: Authorization? {
        guard let authorization = request.headers["Authorization"] else {
            return nil
        }
        
        return Authorization(header: authorization)
    }
    
    func login(_ credentials: Credentials) throws -> IVSAAdmin {
        return try IVSAAdmin.authenticate(credentials: credentials) as! IVSAAdmin
    }
    
    func logout() throws {
        // first find the user, then update it with a clear session
        var admin = try self.admin()
        admin.accessToken = nil
        try admin.save()
    }
    
    func admin() throws -> IVSAAdmin {
        
        // first find the user
        guard let bearerToken = self.header?.bearer else {
            throw Abort.custom(status: .unauthorized, message: "Autenticate first, then try again.")
        }
        
        guard let admin = try IVSAAdmin.query().filter("access_token", bearerToken.string).first() else {
            throw Abort.custom(status: .unauthorized, message: "Invalid credentials.")
        }
        
        return admin
    }
}

extension Request {
    public var adminAuth: AdminAuthHelper {
        
        let helper = AdminAuthHelper(request: self)
        
        return helper
    }
}
