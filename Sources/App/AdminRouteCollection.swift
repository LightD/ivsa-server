//
//  AdminRouterCollection.swift
//  ivsa
//
//  Created by Light Dream on 01/12/2016.
//
//

import Foundation
import Auth
import Turnstile
import Vapor
import HTTP
import Routing
import Fluent

class AdminRouteCollection: RouteCollection {
    
    typealias Wrapped = HTTP.Responder
    
    private var authMiddleware: AdminAuthMiddleware
    
    
    init(authMiddleware: AdminAuthMiddleware) {
        self.authMiddleware = authMiddleware
    }
    
    
    func build<B: RouteBuilder>(_ builder: B) where B.Value == Wrapped {
        let adminRouteBuilder = builder.grouped("admin")
        let adminProtectedRouteBuilder = adminRouteBuilder.grouped(self.authMiddleware)
        
        adminRouteBuilder.post("login") { request in
            
            guard let username = request.json?["email"]?.string,
                let password = request.json?["password"]?.string else {
                    throw GeneralErrors.missingParams.vaporError
            }
            
            let credentials = UsernamePassword(username: username, password: password)
            
            return try request.adminAuth.login(credentials)
        }
        
        adminRouteBuilder.get("makenouradmin") { request in
            
            let credentials = UsernamePassword(username: "admin@ivsa.com", password: "ivsa")
            var admin = IVSAAdmin(credentials: credentials)
            try admin.save()
            
            return admin
        }
        
        
        adminRouteBuilder.get("me") { request in
            return try request.admin()
        }

        adminRouteBuilder.get("getallacceptedemails") { request in
            
            let users: [IVSAUser] =  try IVSAUser.query().filter("application_status", "accepted").run()
            let emails = users.map { $0.email }.joined(separator: ",")
            print("emails are: \(emails)")
            print(emails)
            return try JSON(node: ["ok emails are: ": emails])
        }
        
        adminRouteBuilder.get("testemail") { request in
            
            let user = IVSAUser()
            user.email = "nourforgive@gmail.com"
            try MailgunClient.sendCongressGuideEmail(toUser: user, baseURL: request.baseURL)
            
            return try JSON(node: ["ok": "awesome"])
        }
        
        adminRouteBuilder.get("uniqueCountries") { request in
            let users = try IVSAUser.query().filter("application_status", "accepted").run()
            // 1. get distinct countries
            let countries = users.map { $0.registrationDetails?.personalInfo.countryOfLegalResidence }.filter { $0 != nil }.map { $0!.lowercased() }
            let uniqueCountries = countries.unique()
            let node = try Node(node: uniqueCountries)
            
            return try JSON(node: node)
        }
        
        adminRouteBuilder.get("trythis") { request in
            let users = try IVSAUser.query().filter("application_status", "accepted").run()
            // 1. get distinct countries
            let countries = users.map { $0.registrationDetails?.personalInfo.countryOfLegalResidence }.filter { $0 != nil }.map { $0!.lowercased() }
            let uniqueCountries = countries.unique()
            print("unique countries: \(uniqueCountries)")
            // 2.
            
            return try JSON(node: [:])
        }
        
        // accepted values for :application_status param are:
        // inReview
        // accepted
        // rejected
        adminProtectedRouteBuilder.get("delegates", ":application_status") { request in
            let appStatus = try request.parameters.extract("application_status") as String
            let users: [IVSAUser] =  try IVSAUser.query().filter("application_status", appStatus).run()
            
            let sortedApplicants = users.filter { $0.registrationDetails != nil }.sorted(by: { (first, second) -> Bool in
                // we can force unwrap safely coz we filter first
                return first.registrationDetails!.ivsaChapter.country < second.registrationDetails!.ivsaChapter.country
            })
            let applicantsNode = try Node(node: sortedApplicants)
            
            let json = try JSON(node: applicantsNode)
            
            return json
        }
        
        adminProtectedRouteBuilder.get("applicant", IVSAUser.self) { request, user in
            return try JSON(node: try user.makeNode())
        }

        adminProtectedRouteBuilder.post("accept", IVSAUser.self) { request, user in
            
//            let originalStatus = user.applicationStatus
            
            user.applicationStatus = .accepted
            var user = user
            try user.save()
            
            let node = try user.makeNode()
//            do {
//                if originalStatus == .rejected {
//                    try MailgunClient.sendWaitlistAcceptanceEmail(toUser: user, baseURL: request.baseURL)
//                }
//                else {
//                    try MailgunClient.sendAcceptanceEmail(toUser: user, baseURL: request.baseURL)
//                }
//            } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
            
            return try JSON(node: node)
        }
        
        adminProtectedRouteBuilder.post("reject", IVSAUser.self) { request, user in
            user.applicationStatus = .rejected
            
            var user = user
            try user.save()
//            
//            do {
//                try MailgunClient.sendRejectionEmail(toUser: user, baseURL: request.baseURL)
//            } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
//            
            
            return try JSON(node: try user.makeNode())
        }
        
        adminProtectedRouteBuilder.post("confirmReject", IVSAUser.self) { request, user in
            user.applicationStatus = .confirmedRejected
            var user = user
            try user.save()
            
            return try JSON(node: try user.makeNode())
        }
        
        adminProtectedRouteBuilder.get("sendPostcongressFeesUpdatesEmail") { request in
            let users: [IVSAUser] = try IVSAUser.query().filter("application_status", "accepted").run()
            
            for user in users {
                do {
                    try MailgunClient.sendPostcongressDetailsUpdatesEmail(toUser: user, baseURL: request.baseURL)
                } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
            }
            
            return try JSON(node: ["ok": 200])
        }
        
        
        adminProtectedRouteBuilder.post("updatePass", IVSAUser.self) { request, user in
            
            guard let newPass = request.json?["newPass"]?.string else {
                throw Abort.custom(status: .badRequest, message: "Missing param")
            }
            
            var mutableUser = user
            mutableUser.updatePassword(pass: newPass)
            try mutableUser.save()
            
            return try JSON(node: ["ok": 200])
        }
    }
    
}

