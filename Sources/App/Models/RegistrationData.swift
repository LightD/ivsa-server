//
//  RegistrationData.swift
//  ivsa
//
//  Created by Light Dream on 15/12/2016.
//
//

import Foundation
import Vapor

extension String {
    var dateDDmmYYYY: Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy"
        let date = dateformatter.date(from: self)
        return date
    }
    
    var fullDateTime: Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateformatter.date(from: self)
        return date
    }
}

extension Date {
    
    var stringDDmmYYYY: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy"
        let string = dateformatter.string(from: self)
        return string
    }
    
    var stringFullDateTime: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let string = dateformatter.string(from: self)
        return string
    }
}

struct PersonalInformation: NodeInitializable, NodeRepresentable {
    var name: String
    var middleName: String
    var surname: String
    var nameTag: String
    var birthDate: Date
    var isMale: Bool = true // if false, iz female. das is all.
    var yearOfStudy: String
    var nationality: String
    var countryOfLegalResidence: String
    var passportNumber: String
    var studentId: String?
    
    init(node: Node, in context: Context) throws {
        self.name = try node.extract("first_name")
        self.middleName = try node.extract("middle_name")
        self.surname = try node.extract("surname")
        self.nameTag = try node.extract("name_tag")
        self.birthDate = try node.extract("birth_date", transform: { (dateString: String) -> Date in
            guard let date = dateString.dateDDmmYYYY else {
                throw Abort.custom(status: .badRequest, message: "Invalid format for birth date field")
            }
            return date
        })
        self.isMale = try node.extract("sex")
        self.yearOfStudy = try node.extract("study_year")
        self.nationality = try node.extract("nationality")
        self.countryOfLegalResidence = try node.extract("residency_country")
        self.passportNumber = try node.extract("passport_number")
        self.studentId = try node.extract("student_id")
        
        
    }
    
    func makeNode(context: Context) throws -> Node {
        
        return try Node(node: [
            "first_name": name,
            "middle_name": middleName,
            "surname": surname,
            "name_tag": nameTag,
            "birth_date": birthDate.stringDDmmYYYY,
            "sex": isMale,
            "study_year": yearOfStudy,
            "nationality": nationality,
            "residency_country": countryOfLegalResidence,
            "passport_number": passportNumber,
            "student_id": studentId
            ])
    }
}

struct FlightDetails: NodeConvertible {
    
    var arrival: FlightInfo
    var departure: FlightInfo
    
    init(node: Node, in context: Context) throws {
        self.arrival = try node.extract("arrival")
        self.departure = try node.extract("departure")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "arrival": arrival,
            "departure": departure
            ])
    }
}

struct FlightInfo: NodeConvertible {
    
    var datetime: Date
    var airportName: String
    var flightNumber: String
    
    init(node: Node, in context: Context) throws {
        self.datetime = try node.extract("datetime", transform:{ (dateString: String) -> Date in
            
            guard let date = dateString.fullDateTime else {
                throw Abort.custom(status: .badRequest, message: "Invalid format for flight datetime field :\(dateString)")
            }
            return date
        })
        self.airportName = try node.extract("airport_name")
        self.flightNumber = try node.extract("flight_num")
        
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "datetime": datetime.stringFullDateTime,
            "airport_name": airportName,
            "flight_num": flightNumber
            ])
    }
}

//struct Flight

struct ContactDetails: NodeInitializable, NodeRepresentable {
    var address: String
    var city: String
    var postalCode: String
    var state: String
    var country: String
    var phoneNum: String
    
    init(node: Node, in context: Context) throws {
        self.address = try node.extract("address")
        self.city = try node.extract("city")
        self.postalCode = try node.extract("post_code")
        self.state = try node.extract("state")
        self.country = try node.extract("country")
        self.phoneNum = try node.extract("phone_num")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "address": address,
            "city": city,
            "post_code": postalCode,
            "state": state,
            "country": country,
            "phone_num": phoneNum
            ])
    }
}

struct EmergencyContact: NodeInitializable, NodeRepresentable {
    var name: String
    var association: String
    var phoneNum: String
    var email: String
    
    init(node: Node, in context: Context) throws {
        self.name = try node.extract("name")
        self.association = try node.extract("association")
        self.phoneNum = try node.extract("phone_num")
        self.email = try node.extract("email")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "name": name,
            "association": association,
            "phone_num": phoneNum,
            "email": email
            ])
    }
}

struct IVSAChapterInformation: NodeInitializable, NodeRepresentable {
    var chapterName: String
    var faculty: String
    var universityAddress: String
    var city: String
    var state: String
    var postalCode: String
    var country: String
    var positionAtLocalChapter: String
    
    init(node: Node, in context: Context) throws {
        self.chapterName = try node.extract("name")
        self.faculty = try node.extract("faculty")
        self.universityAddress = try node.extract("university_address")
        self.city = try node.extract("city")
        self.state = try node.extract("state")
        self.postalCode = try node.extract("post_code")
        self.country = try node.extract("country")
        self.positionAtLocalChapter = try node.extract("position")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "name": chapterName,
            "faculty": faculty,
            "university_address": universityAddress,
            "city": city,
            "state": state,
            "post_code": postalCode,
            "country": country,
            "position": positionAtLocalChapter
            ])
    }
}

struct EventSpecificInfo: NodeInitializable, NodeRepresentable {
    var vegetarian: Bool = false
    var comments: String
    var foodAllergies: String
    var chronicDisease: String
    var allergyToMedication: String
    var otherMedicalNeeds: String
    var tshirtSize: String
    
    init(node: Node, in context: Context) throws {
        self.vegetarian = try node.extract("vegetarian")
        self.comments = try node.extract("comments")
        self.foodAllergies = try node.extract("food_allergies")
        self.chronicDisease = try node.extract("chronic_disease")
        self.allergyToMedication = try node.extract("medicine_allergies")
        self.otherMedicalNeeds = try node.extract("medical_needs")
        self.tshirtSize = try node.extract("tshirt_size")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "vegetarian": vegetarian,
            "comments": comments,
            "food_allergies": foodAllergies,
            "chronic_disease": chronicDisease,
            "medicine_allergies": allergyToMedication,
            "medical_needs": otherMedicalNeeds,
            "tshirt_size": tshirtSize
            ])
    }
}

struct RegistrationData: NodeInitializable, NodeRepresentable {
    
    var personalInfo: PersonalInformation
    var flightDetails: FlightDetails? = nil// because this was added later, so could be optional
    var contactDetails: ContactDetails
    var emergencyContact: EmergencyContact
    var ivsaChapter: IVSAChapterInformation
    var eventSpecificInfo: EventSpecificInfo
    
    
    var whyShouldWeChooseYou: String
    var attendingPostCongress: Bool = false
    
    init(node: Node, in context: Context) throws {
        self.personalInfo = try PersonalInformation(node: try node.extract("personal_information"), in: context)
        
        let flightInfo: Node? = try node.extract("flight_details")
        if let flights = flightInfo {
            self.flightDetails = try FlightDetails(node: flights, in: context)
        }
        self.contactDetails = try ContactDetails(node: try node.extract("contact_details"), in: context)
        self.emergencyContact = try EmergencyContact(node: try node.extract("emergency_contact"), in: context)
        self.ivsaChapter = try IVSAChapterInformation(node: try node.extract("ivsa_chapter"), in: context)
        self.eventSpecificInfo = try EventSpecificInfo(node: try node.extract("event_info"), in: context)
        self.whyShouldWeChooseYou = try node.extract("why_you")
        self.attendingPostCongress = try node.extract("attending_postcongress")
        
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "personal_information": personalInfo,
            "flight_details": flightDetails,
            "contact_details": contactDetails,
            "emergency_contact": emergencyContact,
            "ivsa_chapter": ivsaChapter,
            "event_info": eventSpecificInfo,
            "why_you": whyShouldWeChooseYou,
            "attending_postcongress": self.attendingPostCongress
            ])
    }
}
