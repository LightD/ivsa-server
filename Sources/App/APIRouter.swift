//
//  APIRouter.swift
//  ivsa
//
//  Created by Light Dream on 28/01/2017.
//
//

import Foundation
import Auth
import Turnstile
import Vapor

struct APIRouter {
    
    static func buildAPI(withDroplet drop: Droplet) {
        
        let auth = TokenAuthMiddleware()
        let adminAuth = AdminAuthMiddleware()
        
        let authRoutes = AuthRouteCollection()
        let accountRoutes = AccountRouteCollection(authMiddleware: auth)
        let adminRoutes = AdminRouteCollection(authMiddleware: adminAuth)
        
        let apiRouter = drop.grouped("api")
        
        authRoutes.build(apiRouter)
        accountRoutes.build(apiRouter)
        adminRoutes.build(apiRouter)
        

    }
}
