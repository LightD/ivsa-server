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


#if Xcode
let parent = #file.characters.split(separator: "/").map(String.init).dropLast().joined(separator: "/")
let workDir = "/\(parent)/../.."
#else
let workDir = "./"
#endif

let mediaTypes: [String: String] = [
    "png": "image/png",
    "pdf": "application/pdf"
    // ...
]

extension EmailAttachment {
    init?(filename: String, in directory: String) {
        guard
            let suffix = filename.components(separatedBy: ".").last,
            let mediaType = mediaTypes[suffix]
            else {
                return nil
        }
        guard let data = NSData(contentsOfFile: directory.finished(with: "/") + filename) else {
            return nil
        }
        var bytes = [UInt8](repeating: 0, count: data.length)
        data.getBytes(&bytes, length: data.length)
        self.init(filename: filename, contentType: mediaType, body: bytes)
    }
}

func acceptDelegateEmail(baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"
    
    html += "<p> Thank you for your interest and we are delighted to receive your application to join as a delegate for the 66th International Veterinary Student Association (IVSA) Congress, which will be held from the 24th of July to the 4th of August 2017 in Malaysia. </p>"
    
    html += "<br /> <br />"
    
    html += "<h3 align='center' style='color: red;'> CONGRATULATIONS </h3>"
    
    html += "<br /> <br />"
    
    html += "<p> The IVSA Congress OC has conducted its stringent selection process and we are proud to announce that your application has been accepted.  It is with great pleasure to welcome you aboard and we look forward in having you with us. </p>"
    
    html += "<br /> <br />"
    
    html += "<p> Attached is the official acceptance letter for your reference. We would like to advise you to <b><u>READ IT THOROUGHLY</u></b> as it contains all the important deadlines and instructions for your next steps to be <b></u>CONFIRMED</u></b> as a delegate for the Congress. </p>"
    
    html += "<br /> <br />"
    
    html += "<p> IMPORTANT: By receiving this email, your seat as a delegate is temporarily reserved but <b><u>not confirmed</u></b> until you have completed the steps mentioned in the acceptance letter within the stipulated time frame. </p>"
    
    html += "<br />"
    
    html += "<p> Please do not hesitate to contact us if you have any further inquiries related to the 66th IVSA Congress 2017, we shall make every effort to be of assistance.  </p>"
    
    html += "<br /> <br />"
    
    html += "<p> Thank you. </p>"
    
    html += "<br /> <br /> <br />"
    
    html += "<p> Best regards, </p> <br /> <p> 66TH IVSA CONGRESS 2017, MALAYSIA OC Team </p>"
    
    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    
    html += "</body>"
    html += "</html>"
    
    
    return EmailBody(type: .html, content: html)
}

func rejectDelegateEmail(baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"
    
    html += "<p> Kindly refer to the attached document below. </p>"
    
    html += "<br /> <br /> <br />"
    
    html += "<p> We hope to hear from you soon."
    
    html += "<br /> <br /> <br />"
    
    html += "<p> Thank you. </p>"
    
    html += "<br /> <br /> <br />"
    
    html += "<p> Best regards, </p> <br /> <p> 66TH IVSA CONGRESS 2017, MALAYSIA OC Team </p>"
    
    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    
    html += "</body>"
    html += "</html>"
    
    
    return EmailBody(type: .html, content: html)
}


extension SMTPClient {
    public static func makeMailgunClient() throws -> SMTPClient {
        return try SMTPClient(host: "smtp.mailgun.org", port: 587, securityLayer: .none)
    }
    
}

enum EmailError: Swift.Error {
    case missingFile
}

struct MailgunClient {
    
    static func sendVerificationEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        // NOTE: for the userId, it will never come here if the user isn't properly populated, so force unwrap (!) is fine here :)
        let id = user.id!.string!
        let content = "<html><b>thank you </b> for signing up, all you need to do is click on the following link to verify your email: <a href='\(baseURL)/verify_email/\(id)/\(user.verificationToken)'> \(baseURL)/verify_email/\(id)/\(user.verificationToken) </a> </html>"
        
        
        try sendMail(client: client, to: user.email, subject: "Verify your email", body: EmailBody(type: .html, content: content))
        
    }
    
    static func sendAcceptanceEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()

        guard let testPDF = EmailAttachment(filename: "accept-letter.pdf", in: workDir) else {
            throw EmailError.missingFile
        }
        
        try sendMail(client: client, to: user.email, subject: "[APPLICATION RESULTS] 66th IVSA Congress 2017 in Malaysia", body: acceptDelegateEmail(baseURL: baseURL), attachment: testPDF)
    }
    
    static func sendRejectionEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        
        guard let testPDF = EmailAttachment(filename: "reject-letter.pdf", in: workDir) else {
            throw EmailError.missingFile
        }
        
        try sendMail(client: client, to: user.email, subject: "[APPLICATION RESULTS] 66th IVSA Congress 2017 in Malaysia", body: acceptDelegateEmail(baseURL: baseURL), attachment: testPDF)
    }
    
    private static func sendMail(client: SMTPClient<TCPClientStream>, to: String, subject: String, body: EmailBody, attachment: EmailAttachment? = nil) throws {
        
        let credentials = SMTP.SMTPCredentials(
            user: "ivsa@mycongresslah.com",
            pass: "IVSAcongress2017"
        )
        
        let from = SMTP.EmailAddress(name: "IVSA Malaysia OC Team",
                                     address: "mail@mycongresslah.com")
        
        
        
        let email: SMTP.Email = Email(from: from,
                                      to: to,
                                      subject: subject,
                                      body: body)
        
        if let file = attachment {
            email.attachments.append(file)
        }
        
        try client.send(email, using: credentials)
        
        
    }
}
