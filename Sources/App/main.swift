import HTTP
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


extension String: Error {
    
}

extension Request {
    // Base URL returns the hostname, scheme, and port in a URL string form.
    var baseURL: String {
        return uri.scheme + "://" + uri.host + (uri.port == nil ? "" : ":\(uri.port!)")
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


let adminWeb = AdminWebRouter.buildRouter(droplet: drop)
let adminAuthSessionMiddleware = AdminSessionAuthMiddleware()
adminWeb.registerRoutes(authMiddleware: adminAuthSessionMiddleware)


do {
    let provider = try VaporMongo.Provider(database: "ivsalocal", user: "", password: "")
    drop.addProvider(provider)
}
catch let e {
    debugPrint("failed to add mongo provider \(e)")
}
drop.run()
