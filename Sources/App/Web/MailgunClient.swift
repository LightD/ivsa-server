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


func optionsForTransportationsEmail(baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"
    html += "<p> Dear Delegates, </p>"
    
    html += "<p> Warmest greetings from Malaysia! We hope you are as excited as we are to be hosting you this summer! </p>"
    
    html += "<p>IF YOU HAVE NOT PAID FOR POST-CONGRESS BUT WOULD LIKE TO JOIN, THERE ARE VERY <b>LIMITED SPOTS</b> STILL AVAILABLE! <br />"
    html += "APPLY NOW ON A FIRST COME FIRST SERVE BASIS!  <br />"
    html += "<b>PACKAGE PRICES</b> HAVE BEEN SENT ON <b>LAST EMAIL REGARDING POST-CONGRESS. </b> <br /> </p>"
    
    html += "<h2 style='text-align:center;'><b >PLEASE DISREGARD THIS EMAIL IF YOU ARE NOT PARTICIPATING FOR THE POST-CONGRESS TRIP TO REDANG ISLAND</b></h2>"
    
    html += "<p><font size='4'>We shall be giving you more options for the transportation to our beautiful Post-Congress destination:<b> <u>Redang Island!</u></b></font></p>"
    
    html += "<p><br>Based on the<b> Ferry tentative schedule</b>:-<br><ul><li>We have to be at Shahbandar Jetty (to go to the Island): <u>Before 8.00am</u> on the 5th August 2017.<br></li><li>From the Island back to Shahbandar Jetty: <u>12.00pm</u> on the day chosen in your package (8th/9th August).<br></li><li>Ferry journey duration: <u>2 hours</u></li></ul><br><b>Therefore</b>, the transport options to and from Shahbandar Jetty is as follows:-<br><br></p>"
    
    html += "<p><font size='4'><b>1. Bus (Duration: approx. 6 hours)</b></font></p>"
    
    html += "<p>Buses will be provided by the OC for those who are joining the Post-Congress trip. The bus shall be departing from our meeting place/hotel to the jetty of Redang Island at approx. 12am on 4th August 2017. We shall be arriving at the Shahbandar Jetty by 6am on the 5th August 2017 to catch the earliest ferry to Redang Island."
    
    html += "<br>"
    
    html += "Bus ride per person: RM45/person/way - approx. 10 Euros/person/way<br>(Not Included in Post-Congress Fee, will be collected upon registration)"
    
    html += "<br>"
    html += "<br></p>"
    
    html += "<p><font size='4'><b>2. Plane (Duration: 55 mins)</b></font></p>"
    
    
    html += "<p>Direct flights are available to Kuala Terengganu, then a cab can be taken from the airport to the jetty. The distance between the airport to the jetty is approx. 13km (journey time estimated to be around 20-30 minutes, if unexpected jam, can take up to an hour)"
    html += "<br>"
    
    html += "There are two airlines providing direct flights from Kuala Lumpur International Airport (KLIA) to Kuala Terengganu, namely AirAsia (budget airline) and Malaysia Airlines. Please note that the Post-Congress fee <b><u>DOES NOT</u></b> cover the flight, and<b><u> if you choose to fly, it is entirely on your own arrangement (i.e. you would have to buy tickets yourself)</u></b>"
    html += "<br></p>"
    
    html += "<p><b>Route: Kuala Lumpur (KLIA/KLIA2) to Kuala Terengganu Airport</b><br>"
    html += "Departure Date: 5th August 2017 <br>"
    html += "Recommended ARRIVAL time at Kuala Terengganu Airport: 6.00-7.00am on 5th August<br>(This is because we have to be at Shahbandar Jetty before 8am)<br>"
    html += "<br></p>"
    
    html += "<p><b>Route: Kuala Terengganu Airport to Kuala Lumpur (KLIA/KLIA2)</b> <br>"
    html += "Departure Date: (4D3N) 8th August 2017 / (5D4N) 9th August 2017 <br>"
    html += "Recommended DEPARTURE time from Kuala Terengganu: 4.30pm onwards would be safe <br>"
    html += "Flight Duration: 55 mins<br><br><b>(Transport to and from KT Airport to Shahbandar Jetty)</b><br><b>Route:&nbsp;Kuala Terengganu Airport to Shahbandar Jetty AND/OR&nbsp;</b><b>Shahbandar Jetty to&nbsp;</b>&nbsp;<b>Kuala Terengganu Airport</b><br>Can be provided by the Resort that we are staying at (<b style='color:rgb(0,0,0)'>NEED TO INFORM OC IN ADVANCED)</b><br>Cost: RM15/pax/way, OR RM30/pax for return trip<br></p>"
    
    html += "<p><font size='4'><b><u>Please reply to us ASAP on your options for travelling to and fro Kuala Terengganu.</u></b></font>&nbsp;</p>"
    
    html += "<p>Note that you can choose to fly or take the bus for any of the routes (either departing to Kuala Terengganu or Kuala Lumpur). Please specify your preference to us clearly.</p>"
    
    html += "<p><b><u><font size='4'>An <font color='#ff0000'>example</font> of reply is as follow:</font></u></b><br></p>"
    
    html += "<p>Dear OC,</p>"
    
    html += "<p>These are my option for transportation for my Post-Congress Trip:</p>"
    html += "<p><i><b><font size='4'>For Bus:</font></b></i></p>"
    
    html += "<p>I will be taking the bus the OC have prepared from Kuala Lumpur to Kuala Terengganu. My chosen Post-Congress is 4D3N, Package E. My flight back to my home country is on the <i>(insert date of your departure flight from Kuala Lumpur)</i>.<br><br><b><font size='4'>OR</font></b></p>"
    
    html += "<p><i><b><font size='4'>For Flight:</font></b></i></p>"
    
    html += "<div><table style='width: 568px;' border='1' cellspacing='0' cellpadding='0'> <tbody> <tr> <td style='width: 567px;' colspan='2' valign='top'> <p><strong>DEPARTURE (KUALA LUMPUR &ndash; KUALA TERENGGANU)</strong></p> </td> </tr> <tr> <td style='width: 255px;' valign='top'> <p>Preferred Mode of Transport</p> </td> <td style='width: 312px;' valign='top'> <p>Flight</p> </td> </tr> <tr> <td style='width: 255px;' valign='top'> <p>Date</p> </td> <td style='width: 312px;' valign='top'> <p>5<sup>th</sup> August 2017</p> </td> </tr> <tr> <td style='width: 255px;' valign='top'> <p>Departure Time</p> </td> <td style='width: 312px;' valign='top'> <p>6.10am</p> </td> </tr> <tr> <td style='width: 255px;' valign='top'> <p>Estimated Arrival Time</p> </td> <td style='width: 312px;' valign='top'> <p>7.10am</p> </td> </tr> <tr> <td style='width: 255px;' valign='top'> <p>Transport from KT Airport to Jetty?</p> </td> <td style='width: 312px;' valign='top'><p>Yes/No?</p></td> </tr> <tr> <td style='width: 567px;' colspan='2' valign='top'> <p>I understand that the arrangement of flight to Kuala Terengganu and transportation to Shahbandar Jetty are entirely on my own. I will not hold the OC responsible should there be any delays, accidents etc. that may happen throughout my journey to Shahbandar Jetty. I will send my flight details to the OC once I have booked my flights for the Post-Congress trip.</p> </td> </tr> </tbody> </table></div>"
    html += "<div><br></div>"
    
    html += "<div><table style='width: 568px;' border='1' cellspacing='0' cellpadding='0'> <tbody> <tr> <td style='width: 567px;' colspan='2' valign='top'> <p><strong>DEPARTURE (KUALA TERENGGANU - KUALA LUMPUR)</strong></p> </td> </tr> <tr> <td style='width: 236px;' valign='top'> <p>Preferred Mode of Transport</p> </td> <td style='width: 331px;' valign='top'> <p>Flight</p> </td> </tr> <tr> <td style='width: 236px;' valign='top'> <p>Date</p> </td> <td style='width: 331px;' valign='top'> <p>8th August 2017 (4D3N)</p> </td> </tr> <tr> <td style='width: 236px;' valign='top'> <p>Departure Time</p> </td> <td style='width: 331px;' valign='top'><p>5.00pm</p></td> </tr> <tr> <td style='width: 236px;' valign='top'> <p>Estimated Arrival Time</p> </td> <td style='width: 331px;' valign='top'><p>6.00pm</p></td> </tr> <tr> <td style='width: 236px;' valign='top'> <p>Transport from Jetty to KT Airport?</p> </td> <td style='width: 331px;' valign='top'><p>Yes/No?</p></td> </tr> <tr> <td style='width: 567px;' colspan='2' valign='top'> <p>I understand that the arrangement of flight to Kuala Lumpur and transportation to Sultan Mahmud Airport, Kuala Terengganu are entirely on my own. I will not hold the OC responsible should there be any delays, accidents etc. that may happen throughout my journey to the airport.&nbsp; I will send my flight details to the OC once I have booked my flights for the Post-Congress trip.</p> </td> </tr> </tbody> </table></div>"
    html += "<br>"
    
    html += "<p> Please get back to us within 2 weeks (14 days) from the day you receive this email. Failure to reply to us will mean that you are taking the bus prepared by the OC. </p>"
    
    html += "<p> Email us your response to ivsacongress.my@gmail.com </>"
    
    html += "<p>If you have any inquiries, feel free to send us an email stating your questions and we shall reply to you as soon as possible. </p>"
    
    html += "<p> Regards, <br /> OC </p>"
    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    
    html += "<p> If you wish, you can unsubscribe <a href='\(baseURL)/unsubscribe'> here </a>"
    
    html += "</body>"
    html += "</html>"

    return EmailBody(type: .html, content: html)
}

func acceptWaitlistDelegateEmail(baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"

    html += "<p> Dear Future Delegate, </p>"

    html += "<p> CONGRATULATIONS! You have been selected to join the 66th IVSA Congress 2017 in Malaysia. :) </p>"

    html += "<p> We have bumped you up into our acceptance list as there are several delegates who could not make it to our event. Attached is the acceptance letter we have sent to all delegates, please do read it carefully. Note that the new deadline for confirmation is <mark style='font-size: large; color: red;'><u> <b> 30th APRIL 2017. </b> </u></mark> </p>"

    html += "<p><mark style='font-size: large; color: red;'><u><b> Payment Deadline: 12th May 2017 </b> </u></mark></p>"

    html += "<p><mark style='color: red;'><b> For Post-Congress, please refer to the other attached document for the latest amendment. </b></mark></p>"

    html += "<p> Please get back to us soon on your RSVP. </p>"

    html += "<p> Thank you! </p>"

    html += "<p> Regards, <br /> OC </p>"

    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    html += "<br >"


    html += "</body>"
    html += "</html>"


    return EmailBody(type: .html, content: html)
}

func emailVerificationEmail(forUser user: IVSAUser, baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"
    
    html += "<p> Dear Future Delegate, </p>"

    // NOTE: for the userId, it will never come here if the user isn't properly populated, so force unwrap (!) is fine here :)
    html += "<p> <b>Thank you </b> for signing up, all you need to do is click on the following link to verify your email: <a href='\(baseURL)/verify_email/\(user.id!.string!)/\(user.verificationToken)'> \(baseURL)/verify_email/\(user.id!.string!)/\(user.verificationToken) </a>  </p>"
    
    html += "<p> Regards, <br /> OC </p>"
    
    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    html += "<br >"
    
    
    html += "</body>"
    html += "</html>"
    return EmailBody(type: .html, content: html)
}

func resetPasswordEmail(forUser user: IVSAUser, baseURL: String) -> EmailBody {
    var html = ""
    html += "<!DOCTYPE html>"
    html += "<html>"
    html += "<body>"
    
    html += "<p> Dear Delegate, </p>"
    
    html += "<p> You have requested a password reset for the email: \(user.email). <br> To choose a password and complete resetting your password, please click: <a href='\(baseURL)/reset_password/\(user.id!.string!)/\(user.resetPasswordToken)'> \(baseURL)/reset_password/\(user.id!.string!)/\(user.resetPasswordToken) </a>  </p>"
    
    
    html += "<br /> <p> Regards, <br /> OC </p>"
    
    html += "<img width='170' height='200' src='\(baseURL)/images/ivsamalaysiawhitebg.jpg' />"
    html += "<br >"
    
    
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
        return try SMTPClient(host: "smtp.mailgun.org", port: 587, securityLayer: .none)
    }

}

enum EmailError: Swift.Error {
    case missingFile
}

struct MailgunClient {

    static func sendVerificationEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        
        try sendMail(client: client, to: user.email, subject: "Verify your email", body: emailVerificationEmail(forUser: user, baseURL: baseURL))

    }
    
    static func sendResetPasswordEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        
        try sendMail(client: client, to: user.email, subject: "Reset your password", body: resetPasswordEmail(forUser: user, baseURL: baseURL))
    }

    static func sendAcceptanceEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()

        guard let acceptLetterPDF = EmailAttachment(filename: "accept-letter.pdf", in: workDir) else {
            throw EmailError.missingFile
        }

        try sendMail(client: client, to: user.email, subject: "[APPLICATION RESULTS] 66th IVSA Congress 2017 in Malaysia", body: acceptDelegateEmail(baseURL: baseURL), attachments: [acceptLetterPDF])
    }

    static func sendWaitlistAcceptanceEmail(toUser user: IVSAUser, baseURL: String) throws {

        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()

        guard let acceptLetterPDF = EmailAttachment(filename: "accept-letter.pdf", in: workDir) else {
            throw EmailError.missingFile
        }

        guard let package4d3nPDF = EmailAttachment(filename: "4Day-3Night-Package.pdf", in: workDir) else {
            throw EmailError.missingFile
        }

        guard let package5d4nPDF = EmailAttachment(filename: "5Day-4Night-Package.pdf", in: workDir) else {
            throw EmailError.missingFile
        }

        try sendMail(client: client, to: user.email, subject: "[WAITING LIST STATUS REFRESHED] 66th IVSA Congress 2017", body: acceptWaitlistDelegateEmail(baseURL: baseURL), attachments: [acceptLetterPDF, package4d3nPDF, package5d4nPDF])
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
    
    static func sendTransportationOptionsEmail(toUser user: IVSAUser, baseURL: String) throws {
        let client = try SMTPClient<TCPClientStream>.makeMailgunClient()
        try sendMail(client: client, to: user.email, subject: "[POST CONGRESS] Options for Transportation", body: optionsForTransportationsEmail(baseURL: baseURL))
        
    }

    private static func sendMail(client: SMTPClient<TCPClientStream>, to: String, subject: String, body: EmailBody, attachments: [EmailAttachment] = []) throws {


        let credentials = SMTP.SMTPCredentials(
            user: "ivsa@mycongresslah.com",
            pass: "IVSAcongress2017"
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
