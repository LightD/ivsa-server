//
//  MailSender.swift
//  ivsa
//
//  Created by Light Dream on 29/01/2017.
//
//

import Foundation
import SMTP
import Transport

extension SMTPClient {
    public static func makeMailgunClient() throws -> SMTPClient {
        return try SMTPClient(host: "smtp.mailgun.org", port: 587, securityLayer: .none)
    }
    
}

struct MailSender {
    
    static func sendMail(client: SMTPClient<TCPClientStream>) throws {
        
        let credentials = SMTP.SMTPCredentials(
            user: "ivsa@mycongresslah.com",
            pass: "IVSAcongress2017"
        )
        
        let from = SMTP.EmailAddress(name: "Fuck yo mamma",
                                     address: "mail@mycongresslah.com")
        let to = "khairina.halim@gmail.com"
        let email: SMTP.Email = Email(from: from,
                                      to: to,
                                      subject: "Yo mamma so faaaat......",
                                      body: "<html><body>This is inline image 1.<br/>Some text<br/>This is inline image 2.<br/>Some more text<br/>Re-used inline image 1.<br/></body></html>")
        
        try client.send(email, using: credentials)
        
        
    }
}
