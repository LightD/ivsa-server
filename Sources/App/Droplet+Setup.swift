//
//  Droplet+Setup.swift
//  ivsa
//
//  Created by Light Dream on 29/05/2017.
//
//

import Vapor
import AuthProvider
import Sessions

extension Droplet {
    public func setup() throws {
        let apiRouter = self.grouped("api")
        
        try self.collection(AdminWebRouter.self)
        try self.collection(WebRouter.self)
        
        try apiRouter.collection(AccountRouteCollection.self)
        try apiRouter.collection(AuthRouteCollection.self)
        try apiRouter.collection(AdminRouteCollection.self)
    }
    
}

