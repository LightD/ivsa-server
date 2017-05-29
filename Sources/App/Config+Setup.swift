//
//  Config+Setup.swift
//  ivsa
//
//  Created by Light Dream on 29/05/2017.
//
//

import Vapor
import MongoProvider
import FluentProvider
import Sessions
import LeafProvider

extension Config {
    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]//, IVSAUser.self, IVSAAdmin.self, IVSAUserToken.self, IVSAAdminToken.self]
        
        try setupProviders()
        try setupPreparations()
        try setupMiddlewares()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MongoProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(IVSAUser.self)
        preparations.append(IVSAAdmin.self)
        preparations.append(IVSAUserToken.self)
        preparations.append(IVSAAdminToken.self)
    }
    
    private func setupMiddlewares() throws {
        let sessionsMiddleware = SessionsMiddleware(MemorySessions())
        self.addConfigurable(middleware: sessionsMiddleware, name: "sessions")
        
    }
}
