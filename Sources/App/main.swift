import Vapor
import VaporMongo
import Auth
import Turnstile
import Sessions



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



let drop = Droplet()

// So even though we're using mongo, you still have to call prepare on your models, or else it won't be able to reference the database and kaboom
drop.preparations.append(IVSAUser.self)
drop.preparations.append(IVSAAdmin.self)

APIRouter.buildAPI(withDroplet: drop)

let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)
drop.middleware.append(sessions)


let webRouter = WebRouter.buildRouter(droplet: drop)
let authMiddleware = SessionAuthMiddleware()
webRouter.registerRoutes(authMiddleware: authMiddleware)



do {
    try drop.addProvider(VaporMongo.Provider.self)
}
catch let e {
    debugPrint("failed to add mongo provider \(e)")
}
drop.run()
