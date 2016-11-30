//
//  DelegateProtectMiddleware.swift
//  ivsa
//
//  Created by Light Dream on 19/11/2016.
//
//

import Foundation
import HTTP
import Vapor
import Auth

final class DelegateProtectMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        let user = try request.user()
        switch user.applicationStatus {
        case .inReview, .nonApplicant, .rejected:
            throw Abort.custom(status: .forbidden, message: "Unauthorized to perform this action.")
        default: break
        }
        
        
        return try next.respond(to: request)
    }
}
//final class TokenAuthMiddleware: Middleware {
//    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
//        
//        
//        // if there's no access token, we flip nigga!!
//        
//        
//        guard let accessToken = request.auth.header?.bearer else {
//            throw Abort.custom(status: .networkAuthenticationRequired, message: "Unauthenticated users request this.")
//        }
//        
//        do {
//            // check if the access token is valid
//            let _ = try request.ivsaAuth.login(accessToken)
//        }
//        catch {
//            throw Abort.custom(status: .badRequest, message: "Invalid authentication credentials")
//        }
//        
//        // authenticated and everything, perform the request
//        return try next.respond(to: request)
//    }
//    
//    
//}
