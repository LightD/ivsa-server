//
//  AdminRouterCollection.swift
//  ivsa
//
//  Created by Light Dream on 01/12/2016.
//
//

import Foundation
import Vapor
import HTTP
import Routing
import FluentProvider
import AuthProvider

class AdminRouteCollection: RouteCollection, EmptyInitializable {
    
    typealias Wrapped = HTTP.Responder
    
    required init() throws { }
    
    func build(_ builder: RouteBuilder) throws {
        let authMiddleware = TokenAuthenticationMiddleware(IVSAAdmin.self)
        
        
        let adminRouteBuilder = builder.grouped("admin")
        let adminProtectedRouteBuilder = adminRouteBuilder.grouped(authMiddleware)
        
        adminRouteBuilder.post("login") { request in
            
            guard let username = request.json?["email"]?.string,
                let password = request.json?["password"]?.string else {
                    throw GeneralErrors.missingParams
            }
            
            let credentials = Password(username: username, password: password)
            let adminCredentials = try IVSAAdmin(credentials: credentials)
            request.auth.authenticate(adminCredentials)
            let admin: IVSAAdmin = try request.auth.assertAuthenticated()
            return try admin.makeJSON()
        }
        
        adminRouteBuilder.get("makenouradmin") { request in
            
            let credentials = Password(username: "admin@ivsa.com", password: "ivsa")
            let admin = try IVSAAdmin(credentials: credentials)
            try admin.save()
            
            return admin
        }
        
        
        adminRouteBuilder.get("me") { request in
            return try request.auth.assertAuthenticated(IVSAAdmin.self)
        }

        adminRouteBuilder.get("getallacceptedemails") { request in
            
            let users: [IVSAUser] =  try IVSAUser.makeQuery().filter("application_status", "accepted").all()
            
            let emails = users.map { $0.email }.joined(separator: ",")
            
            return try JSON(node: ["ok emails are: ": emails])
        }
        
        adminRouteBuilder.get("testemail") { request in
            
            let user = IVSAUser()
            user.email = "nourforgive@gmail.com"
            try MailgunClient.sendTransportationOptionsEmail(toUser: user, baseURL: request.baseURL)
            
            return try JSON(node: ["ok": "awesome"])
        }
        
        
        // accepted values for :application_status param are:
        // inReview
        // accepted
        // rejected
        adminProtectedRouteBuilder.get("delegates", String.parameter) { request in
            let appStatus: String = try request.parameters.next(String.self)
            let users: [IVSAUser] =  try IVSAUser.makeQuery().filter("application_status", appStatus).filter("registration_details", Filter.Comparison.notEquals, nil)
                .all()
//                .sort("registration_details.ivsa_chapter.country", Sort.Direction.ascending).all()
            
//            let sortedApplicants = users.filter { $0.registrationDetails != nil }.sorted(by: { (first, second) -> Bool in
//                // we can force unwrap safely coz we filter first
//                return first.registrationDetails!.ivsaChapter.country < second.registrationDetails!.ivsaChapter.country
//            })
//            let applicantsNode = try Node(node: )
            
            let json = try JSON(node: users)
            
            return json
        }
        
        adminProtectedRouteBuilder.get("applicant", IVSAUser.parameter) { request in
            let user = try request.parameters.next(IVSAUser.self)
            return JSON(node: try user.makeNode(in: nil))
        }

        adminProtectedRouteBuilder.post("accept", IVSAUser.parameter) { request in
            let user = try request.parameters.next(IVSAUser.self)

//            let originalStatus = user.applicationStatus
            
            user.applicationStatus = .accepted
//            var user = user
            try user.save()
            
            let node = try user.makeNode(in: nil)
//            do {
//                if originalStatus == .rejected {
//                    try MailgunClient.sendWaitlistAcceptanceEmail(toUser: user, baseURL: request.baseURL)
//                }
//                else {
//                    try MailgunClient.sendAcceptanceEmail(toUser: user, baseURL: request.baseURL)
//                }
//            } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
            
            return JSON(node: node)
        }
        
        adminProtectedRouteBuilder.post("reject", IVSAUser.parameter) { request in
            let user = try request.parameters.next(IVSAUser.self)
            user.applicationStatus = .rejected
            try user.save()
//
//            do {
//                try MailgunClient.sendRejectionEmail(toUser: user, baseURL: request.baseURL)
//            } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
//
            
            return JSON(node: try user.makeNode(in: nil))
        }
        
        adminProtectedRouteBuilder.post("confirmReject", IVSAUser.parameter) { request in
            let user = try request.parameters.next(IVSAUser.self)

            user.applicationStatus = .confirmedRejected
            try user.save()
            
            return JSON(node: try user.makeNode(in: nil))
        }
        
        adminProtectedRouteBuilder.get("sendPostcongressFeesUpdatesEmail") { request in
            let users: [IVSAUser] = try IVSAUser.makeQuery().filter("application_status", "accepted").all()
            
            for user in users {
                do {
                    try MailgunClient.sendPostcongressDetailsUpdatesEmail(toUser: user, baseURL: request.baseURL)
                } catch { }  // do nothing here!!!! we don't want the whole request to fail just because the mail client failed to initialize or send an email or whatever -_-
            }
            
            return try JSON(node: ["ok": 200])
        }
        
        
        adminProtectedRouteBuilder.post("updatePass", IVSAUser.parameter) { request in
            let user = try request.parameters.next(IVSAUser.self)

            guard let newPass = request.json?["newPass"]?.string else {
                throw Abort(.badRequest, reason: "Missing param")
            }
            try user.updatePassword(pass: newPass)
            try user.save()
            
            return try JSON(node: ["ok": 200])
        }
    }
    
}

