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

struct MailgunClient {
    
    static func sendVerificationEmail(toUser user: IVSAUser) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        // NOTE: for the userId, it will never come here if the user isn't properly populated, so force unwrap (!) is fine here :)
        let id = user.id!.string!
        let content = "<html><b>thank you </b> for signing up, all you need to do is click on the following link to verify your email: <a href='http://127.0.0.1:8080/verify_email/\(id)/\(user.verificationToken)'> http://127.0.0.1:8080/verify_email/\(id)/\(user.verificationToken) </a> </html>"
        
        
        try sendMail(client: client, to: user.email, subject: "Verify your email", body: EmailBody(type: .html, content: content))
        
    }
    
    
    private static func sendMail(client: SMTPClient<TCPClientStream>, to: String, subject: String, body: EmailBody) throws {
        
        let credentials = SMTP.SMTPCredentials(
            user: "ivsa@mycongresslah.com",
            pass: "IVSAcongress2017"
        )
        
        let from = SMTP.EmailAddress(name: "OC Team",
                                     address: "mail@mycongresslah.com")

        let email: SMTP.Email = Email(from: from,
                                      to: to,
                                      subject: subject,
                                      body: body)
        
        try client.send(email, using: credentials)
        
        
    }
}
