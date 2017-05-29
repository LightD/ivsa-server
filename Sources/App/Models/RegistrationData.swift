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
}

extension Date {
    
    var stringDDmmYYYY: String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy"
        let string = dateformatter.string(from: self)
        return string
    }
}

struct PersonalInformation: NodeConvertible {
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
    var studentId: String
    
    init(node: Node) throws {
        self.name = try node.get("first_name")
        self.middleName = try node.get("middle_name")
        self.surname = try node.get("surname")
        self.nameTag = try node.get("name_tag")
        self.birthDate = try node.get("birth_date", transform: { (dateString: String) -> Date in
            guard let date = dateString.dateDDmmYYYY else {
                throw Abort(.badRequest, metadata: nil, reason: "Invalid format for birth date field")
            }
            return date
        })
        self.isMale = try node.get("sex")
        self.yearOfStudy = try node.get("study_year")
        self.nationality = try node.get("nationality")
        self.countryOfLegalResidence = try node.get("residency_country")
        self.passportNumber = try node.get("passport_number")
        self.studentId = try node.get("student_id")
    }
    
    func makeNode(in context: Context?) throws -> Node {
        
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

struct ContactDetails: NodeConvertible {
    var address: String
    var city: String
    var postalCode: String
    var state: String
    var country: String
    var phoneNum: String
    
    init(node: Node) throws {
        self.address = try node.get("address")
        self.city = try node.get("city")
        self.postalCode = try node.get("post_code")
        self.state = try node.get("state")
        self.country = try node.get("country")
        self.phoneNum = try node.get("phone_num")
    }
    
    func makeNode(in context: Context?) throws -> Node {
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

struct EmergencyContact: NodeConvertible {
    var name: String
    var association: String
    var phoneNum: String
    var email: String
    
    init(node: Node) throws {
        self.name = try node.get("name")
        self.association = try node.get("association")
        self.phoneNum = try node.get("phone_num")
        self.email = try node.get("email")
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "name": name,
            "association": association,
            "phone_num": phoneNum,
            "email": email
            ])
    }
}

struct IVSAChapterInformation: NodeConvertible {
    var chapterName: String
    var faculty: String
    var universityAddress: String
    var city: String
    var state: String
    var postalCode: String
    var country: String
    var positionAtLocalChapter: String
    
    init(node: Node) throws {
        self.chapterName = try node.get("name")
        self.faculty = try node.get("faculty")
        self.universityAddress = try node.get("university_address")
        self.city = try node.get("city")
        self.state = try node.get("state")
        self.postalCode = try node.get("post_code")
        self.country = try node.get("country")
        self.positionAtLocalChapter = try node.get("position")
    }
    
    func makeNode(in context: Context?) throws -> Node {
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

struct EventSpecificInfo: NodeConvertible {
    var vegetarian: Bool = false
    var comments: String
    var foodAllergies: String
    var chronicDisease: String
    var allergyToMedication: String
    var otherMedicalNeeds: String
    var tshirtSize: String
    
    init(node: Node) throws {
        self.vegetarian = try node.get("vegetarian")
        self.comments = try node.get("comments")
        self.foodAllergies = try node.get("food_allergies")
        self.chronicDisease = try node.get("chronic_disease")
        self.allergyToMedication = try node.get("medicine_allergies")
        self.otherMedicalNeeds = try node.get("medical_needs")
        self.tshirtSize = try node.get("tshirt_size")
    }
    
    func makeNode(in context: Context?) throws -> Node {
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

struct RegistrationData: NodeConvertible {
    
    var personalInfo: PersonalInformation
    var contactDetails: ContactDetails
    var emergencyContact: EmergencyContact
    var ivsaChapter: IVSAChapterInformation
    var eventSpecificInfo: EventSpecificInfo
    
    var whyShouldWeChooseYou: String
    var attendingPostCongress: Bool = false
    
    init(node: Node) throws {
        self.personalInfo = try PersonalInformation(node: try node.get("personal_information"))
        self.contactDetails = try ContactDetails(node: try node.get("contact_details"))
        self.emergencyContact = try EmergencyContact(node: try node.get("emergency_contact"))
        self.ivsaChapter = try IVSAChapterInformation(node: try node.get("ivsa_chapter"))
        self.eventSpecificInfo = try EventSpecificInfo(node: try node.get("event_info"))
        self.whyShouldWeChooseYou = try node.get("why_you")
        self.attendingPostCongress = try node.get("attending_postcongress")
        
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "personal_information": personalInfo,
            "contact_details": contactDetails,
            "emergency_contact": emergencyContact,
            "ivsa_chapter": ivsaChapter,
            "event_info": eventSpecificInfo,
            "why_you": whyShouldWeChooseYou,
            "attending_postcongress": self.attendingPostCongress
            ])
    }
}
