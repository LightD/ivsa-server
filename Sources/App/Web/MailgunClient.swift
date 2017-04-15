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

func postcongressCorrectionEmail(baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"
    
    html += "<p> Deal delegates,</p>"
    html += "<br />"
    
    html += "<p> Referring to your acceptance letters, there is a slight inconsistency that we have made in Item 3: Post-Congress Trip on page 6 and 8. </p>"
    html += "<br />"
    
    html += "<h3 align='center'> <span style='background-color: yellow; color: red;'> PLEASE NOTE THAT POST-CONGRESS PACKAGE D: THE DIVING COURSE COSTS 330 EUROS/PERSON AND NOT 315 EUROS AS STATED IN PAGE 6 </span> </h3>"
    html += "<br />"
    
    html += "<h3 align='center' style='margin-bottom: 0px;'> <span style='background-color: yellow; color: red;'> MARINE PARK FEE (PAYABLE DURING CHECK-IN) </span> </h3>"
    html += "<h3 align='center'> <span style='background-color: yellow; color: red;'> MYR 50.00 / PERSON </span> </h3>"
    html += "<h3 align='center'> <span style='background-color: yellow; color: red;'> (APPROX. 10-12 EUROS) </span> </h3>"
    html += "<br />"
    
    html += "<p> On page 6: </p>"
    html += "<br />"
    
    html += "<img src='\(baseURL)/images/page6-correction.png' />"
    html += "<br />"
    
    html += "<p> On page 8: </p>"
    html += "<br />"
    
    html += "<img src='\(baseURL)/images/page8-correction.png' />"
    html += "<br />"
    
    html += "<p> We apologise for the mistake. For those who have transferred the Post-Congress fee of 315 Euros (only for Package D) to us, the OC shall be collecting an extra 15 Euros from you upon arrival and registration in Malaysia. </p>"
    html += "<br />"
    
    html += "<p> Regards, </p> <br /> <p> OC </p>"
    
    
    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    
    html += "</body>"
    html += "</html>"
    
    
    return EmailBody(type: .html, content: html)
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
    
    html += "<p> Attached is the official acceptance letter for your reference. We would like to advise you to <b><u>READ IT THOROUGHLY</u></b> as it contains all the important deadlines and instructions for your next steps to be <b><u>CONFIRMED</u></b> as a delegate for the Congress. </p>"
    
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

func refrainFromPostcongresPaymentEmail(baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"
    
    html += "<p> Dear Ladies and Gentlemen and <u>chosen delegates of 66th IVSA Congress.</u> </p>"
    html += "<br />"
    
    html += "<p> <b> SPECIAL ATTENTION TO DELEGATES WHO ARE PLANNING TO ATTEND POST- CONGRESS, FOR ALL PACKAGES A,B,C & D. </b> </p>"
    
    
    html += "<p> Please <b><u><i style='color: red' >REFRAIN</i></u> <i>from booking your return flight FROM Kuala Lumpur AND <u><i style='color: red' >REFRAIN</i></u> from paying your post congress fees for now</b></i>, as this issue will be settled by <b style='font-size: large'>TODAY</b> itself. </p>"
    html += "<p> We apologize for this mishap at the moment due to managerial and unforeseen circumstances. </p>"
    
    html += "<p> We are changing the diving spots and Island to best suit as we promised (the most beautiful dive and beach that we can provide). <br /> <b><i>Emails to clarify on this issue will be sent as soon as possible from the OC. </i></b> <br /> <mark> (within the next 24 hours) </mark> </p>"
    
    html += "<p> <b>For those who have already paid for Post-Congress </b> and provided proof of payment, you shall be contacted personally as well! </p>"
    
    html += "<p>For any further inquiries, please do not hesitate to email us at:- ivsacongress.my@gmail.com </p>"
    
    html += "<p> Thank you for you patience and sorry for any inconvenience caused! </p>"
    
    html += "<p> <b><i>Deepest Gratitude, </i></b> <br/> Hugs, unicorns, and rainbows </p>"
    html += "<br /> <br />"
    
    
    html += "<p> <b>Khairina Abdul Halim</b> <br/> <i> Co-President, 66th IVSA Congress, Malaysia </i> <br /> <i> International Veterinary Students' Association </i> <br /> <i> +6017-685 6519 </i> </p>"
    html += "<br />"
    
    
    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    
    html += "</body>"
    html += "</html>"
    
    
    return EmailBody(type: .html, content: html)
}

func postcongressDetailsUpdatesEmail(baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"
    
    html += "<div>"
    
    html += "<div>"
    html += "<p style='margin: 0'> <b>1. First of all,</b> we would like to deeply apologize for <i>managerial and unforseen circumstances.</i></p>"
    html += "<p style='margin: 0'> &nbsp; &nbsp; As we also said in our previous email, <span style='font-size:12.8px'> we are changing the diving spots and Island to best suit as we promised, the most beautiful dive, snorkel, &nbsp;and beach that we can provide for our dearest delegates.</span> </p>"
    html += "</div>"
    
    html += "<div>"
    html += "<p> <span style='line-height:14.95px'><b>2.</b> We have changed our <b>Post-Congress trip location</b> to the <u>AS BEAUTIFUL and AS AMAZING</u> <i><span style='color: blue'> clear blue waters </span> & <span style='color: blue'> flourishing marine life </span></i> of <b> Redang Island</b> (PUlau Redang)"
    html += "<br> <br> <b>3. ATTACHED, </b>to this email are the following PDF Files:- "
    html += "</span> </p>"
    
    html += "<blockquote style='margin:0px 0px 0px 40px;border:none;padding:0px'><p style='margin: 0'><b>a) 4 Days 3 Nights Packages (B,C,D,E)<br>b) 5 Days 4 Nights Packages (A,B,C,D,E)<br>c) Itinerary for all days involved</b></p></blockquote>"
    html += "<blockquote style='margin:0px 0px 0px 40px;border:none;padding:0px'><p style='margin: 0'><b>IMPORTANT : OPEN WATER DIVING LICENSE&nbsp;<span style='background-color:rgb(255,0,255)'>(PACKAGE A)</span>&nbsp;IS NOT MADE AVAILABLE IN&nbsp;<font color='#ff0000'>4DAYS 3NIGHTS</font>&nbsp;PACKAGES DUE TO THE FOLLOWING REASONS FOUND COMPELLING TO THE OC:-<br></b></p></blockquote>"
    html += "<blockquote style='margin:0px 0px 0px 40px;border:none;padding:0px'><blockquote style='margin:0px 0px 0px 40px;border:none;padding:0px'><p style='margin: 0'><b>i)</b>&nbsp;<u>4D3N</u>&nbsp;is exactly JUST ENOUGH TIME for you to complete your diving license course.&nbsp;<br></p></blockquote></blockquote>"
    html += "<blockquote style='margin:0px 0px 0px 40px;border:none;padding:0px'><blockquote style='margin:0px 0px 0px 40px;border:none;padding:0px'><blockquote style='margin:0px 0px 0px 40px;border:none;padding:0px'><p style='margin: 0'>The training diving spots (due to safety reasons) are not similar to the licensed \"Fun Dive Spots\" that are more beautiful.</p></blockquote></blockquote></blockquote>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><p style='margin: 0'><b>ii)</b><u>&nbsp;5D3N</u>&nbsp;will give you enough time to complete the diving course + 1 day for 3 extra \"Fun Dives\"<br></p></blockquote></blockquote>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><p style='margin: 0'>Price difference from the last Open Water Diving License Package is only an extra of 80euros for:-</p></blockquote></blockquote></blockquote>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><p style='margin: 0'>- Better beach location and marine life<br>- One (1) extra Day of sun and sea, and one extra Night of accomodation in Air-conditioned room<br>- Three (3) Extra Fun Dives to beautiful diving spots<br>- One (1) extra Buffet Breakfast</p><p style='margin: 0'>- One (1) extra Buffet Lunch<br>- One (1) extra Buffet Tea Break<br>- One (1) extra Buffet Dinner</p></blockquote></blockquote></blockquote>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><b>As for&nbsp;</b><span style=\"font-weight:bold;background-color:rgb(255,0,255)\">PACKAGE B,C,D &amp; E</span><b>&nbsp;</b>we are giving you the options of either staying<font color=\"#ff0000\">&nbsp;<b>4D3N</b></font>&nbsp;or&nbsp;<b><font color=\"#ff0000\">5D4N</font>\" (refer to PDF attachments for pricing)\"</b>.&nbsp;<br>Just e-mail us at;&nbsp;<font color=\"#0000ff\" size=\"4\" style=\"font-weight:bold\">&nbsp;</font><font color=\"#0000ff\"><b><a href=\"mailto:ivsacongress.my@gmail.com\" target=\"_blank\">ivsacongress.my@gmail.com</a></b></font></blockquote>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><font color=\"#000000\">&nbsp;the following template:-<br><br><b>POST-CONGRESS REPLY TEMPLATE<br><br>1) Package: &nbsp;</b>(e.g; 4D3N, Package C)<br><b>2) \"Other Activities\" (Discover Scuba):&nbsp;</b>&nbsp;(e.g; Yes/No)<br></font></blockquote></blockquote>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><font color=\"#000000\"><i>One session (1) of Discover Scuba is&nbsp;<u>already included</u>&nbsp;in&nbsp;<b style=\"background-color:rgb(255,0,255)\">Package D</b>&nbsp;for both 4D3N &amp; 5D4N.<br>Payment for&nbsp;<u><b>extra</b></u>&nbsp;Discover Scuba session or for those who want to&nbsp;<b>try</b>&nbsp;Discover Scuba (especially&nbsp;those taking&nbsp;<span style=\"background-color:rgb(255,0,255)\">Package E</span>) should bring extra cash of RM200 which will be collected upon Congress Registration</i></font></blockquote></blockquote></blockquote>"
    
    html += "<div><p style='margin: 0'><span style=\"line-height:14.95px\"><b><br></b></span></p><p  style='margin: 0'><span style=\"line-height:14.95px\"><b><br></b></span></p><p  style='margin: 0'><span style=\"line-height:14.95px\"><b>4. Post-Congress spots</b>&nbsp;are of&nbsp;<b><u>FIRST-COME-FIRST-SERVED</u></b>&nbsp;bas<wbr>is, whereby upon paying the&nbsp;<b>full payment</b>&nbsp;for the post-congress fee, your seat shall be confirmed.<br><br></span></p></div>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><p style='margin: 0'><span style=\"line-height:14.95px\"><span style=\"line-height:14.95px;background-image:initial;background-position:initial;background-size:initial;background-repeat:initial;background-origin:initial;background-clip:initial\"><span style=\"font-family:calibri,sans-serif;font-size:large;background-color:aqua\">First&nbsp;</span><b style=\"font-family:calibri,sans-serif;font-size:large;background-color:aqua\"><u>100 (ONE HUNDRED)</u></b><span style=\"font-family:calibri,sans-serif;font-size:large;background-color:aqua\">&nbsp;delegates who paid for the trip&nbsp;</span><b style=\"font-family:calibri,sans-serif;font-size:large;background-color:aqua\"><u>FULLY</u></b><span style=\"font-family:calibri,sans-serif;font-size:large;background-color:aqua\">&nbsp;shall have a confirmed spot.</span><br></span></span></p></blockquote></blockquote>"
    
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><p style='margin: 0'><br></p></blockquote></blockquote>"
    
    html += "<div><p style='margin: 0'><span style=\"line-height:14.95px\"><span style=\"line-height:14.95px;font-family:calibri,sans-serif;background:aqua\"><font size=\"4\"><br><br></font></span><b>5. For those of you who are taking Scuba Diving License Packages:-<br></b></span></p></div>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><p style='margin: 0'><b>- Reading Manuals for the course will be given upon Congress Registration</b></p></blockquote>"
    html += "<blockquote style=\"margin:0px 0px 0px 40px;border:none;padding:0px\"><p style='margin: 0'><b>- Compulsory Dive safety and Procedures related \"Videos\" for those who successfully&nbsp;fully-paid for a Diving License course will be emailed to individuals and can be accessed (via dropbox or drive) as soon as we get a hold of the DVD!</b></p></blockquote>"
    
    html += "<div><p  style='margin: 0'><span style=\"line-height:14.95px\"><b><br></b></span></p><p  style='margin: 0'><span style=\"line-height:14.95px\"><b>6. DELEGATES WHO HAVE ALREADY PAID FOR POST-CONGRESS</b></span></p><ul><li><b style=\"background-color:rgb(255,255,0)\">IF YOU HAVE PAID FOR POST-CONGRESS &amp; WE HAVE NOT CONTACTED YOU WITHIN THE NEXT 48 HOURS; DO DROP US AN EMAIL WITH YOUR PROOF OF PAYMENT AGAIN.<br></b>We would not like to miss out on anybody who has paid and would like to provide the opportunity to change packages if desired.<br><br></li><li><b><span style=\"line-height:14.95px\">Post-Congress fee can be transferred along with Congress Delegate Fee. Please state that both fees are transferred to us via email attached with a copy of the transfer slip.</span></b><br></li><li><b><span style=\"line-height:14.95px\"><b style=\"color:red\">PAYMENT WILL NOT BE REFUNDED FOR ANY CANCELLATION OF REGISTRATION OR NO-SHOW.</b></span></b></li></ul></div>"
    html += "</div>"
    
    html += "<p>The full itinerary for all days involved will be emailed by next week</p>"
    
    html += "<br style='clear: both'>"

    html += "</div>"
    
    html += "<p style='margin: 0'> Deepest Gratitude,</p>"
    html += "<p style='margin: 0'> Hugs and rainbows,</p>"
    html += "<br >"
    
    html += "<p style=' margin: 0'><b><font face=\"times new roman, serif\" size=\"4\">Khairina Binti Abdul Halim</b></font></p>"
    html += "<p style='margin: 0;'>Co-President, 66th IVSA Congress, Malaysia</p>"
    html += "<p style='margin: 0;'>International Veterinary Students' Association</p>"
    html += "<p style='margin: 0;'>DVM Class of 2017, Universiti Putra Malaysia</p>"
    html += "<p style='margin: 0;'>+6017-685 6519</p>"
    
    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    html += "<br >"

    html += "</body>"
    html += "</html>"
    
    
    return EmailBody(type: .html, content: html)
}

extension SMTPClient {
    public static func makeMailgunClient() throws -> SMTPClient {
        return try SMTPClient(host: "smtp.gmail.com", port: 587, securityLayer: .tls(nil))
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

        guard let acceptLetterPDF = EmailAttachment(filename: "accept-letter.pdf", in: workDir) else {
            throw EmailError.missingFile
        }
        
        try sendMail(client: client, to: user.email, subject: "[APPLICATION RESULTS] 66th IVSA Congress 2017 in Malaysia", body: acceptDelegateEmail(baseURL: baseURL), attachments: [acceptLetterPDF])
    }
    
    static func sendRejectionEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        
        guard let rejectLetterPDF = EmailAttachment(filename: "reject-letter.pdf", in: workDir) else {
            throw EmailError.missingFile
        }
        
        try sendMail(client: client, to: user.email, subject: "[APPLICATION RESULTS] 66th IVSA Congress 2017 in Malaysia", body: rejectDelegateEmail(baseURL: baseURL), attachments: [rejectLetterPDF])
    }

    static func sendPostcongressCorrectionEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        
        
        try sendMail(client: client, to: user.email, subject: "66th IVSA Congress 2017 - Post-Congress Trip: Minor Changes", body: postcongressCorrectionEmail(baseURL: baseURL))
    }
    
    static func sendPostCongressReferainFromPayment(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()

        try sendMail(client: client, to: user.email, subject: "ATTN: POST-CONGRESS FURTHER INFORMATION", body: refrainFromPostcongresPaymentEmail(baseURL: baseURL))
    }
    
    static func sendPostcongressDetailsUpdatesEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        
        
        guard let package4d3nPDF = EmailAttachment(filename: "4Day-3Night-Package.pdf", in: workDir) else {
            throw EmailError.missingFile
        }
        
        guard let package5d4nPDF = EmailAttachment(filename: "5Day-4Night-Package.pdf", in: workDir) else {
            throw EmailError.missingFile
        }
        
        try sendMail(client: client, to: user.email, subject: "POST CONGRESS DETAILS AND FEE UPDATES (Exclusive) lol", body: postcongressDetailsUpdatesEmail(baseURL: baseURL), attachments: [package4d3nPDF, package5d4nPDF])
    }
    
    private static func sendMail(client: SMTPClient<TCPClientStream>, to: String, subject: String, body: EmailBody, attachments: [EmailAttachment] = []) throws {
        
        let credentials = SMTP.SMTPCredentials(
            user: "ivsacongress.my@gmail.com",
            pass: "66ivsacongressmalaysia"
        )
        
        let from = SMTP.EmailAddress(name: "IVSA Malaysia OC Team",
                                     address: "ivsacongress.my@gmail.com")
        
        
        
        let email: SMTP.Email = Email(from: from,
                                      to: to,
                                      subject: subject,
                                      body: body)
        
        for file in attachments {
            email.attachments.append(file)
        }
        
        try client.send(email, using: credentials)
        
        
    }
}
