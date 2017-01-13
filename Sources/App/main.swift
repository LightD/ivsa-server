import Vapor
import VaporMongo
import Auth
import Turnstile


let drop = Droplet()

// So even though we're using mongo, you still have to call prepare on your models, or else it won't be able to reference the database and kaboom
drop.preparations.append(IVSAUser.self)
drop.preparations.append(IVSAAdmin.self)

let auth = TokenAuthMiddleware()
let adminAuth = AdminAuthMiddleware()

let authRoutes = AuthRouteCollection()
let accountRoutes = AccountRouteCollection(authMiddleware: auth)
let adminRoutes = AdminRouteCollection(authMiddleware: adminAuth)

drop.collection(authRoutes)
drop.collection(accountRoutes)
drop.collection(adminRoutes)

protocol IVSAError: Error {
    var vaporError: Abort { get }
}

enum GeneralErrors: IVSAError {
    case missingParams
    
    var vaporError: Abort {
        switch self {
        case .missingParams:
            return Abort.custom(status: .forbidden, message: "Required parameters were missing from the request")
        }
    }
}

drop.get("hello") { request in
    return try JSON(node: ["Hello, world!": "FUCK YAAH :D"])
}
drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

do {
    try drop.addProvider(VaporMongo.Provider.self)
}
catch let e {
    debugPrint("failed to add mongo provider \(e)")
}
drop.run()
