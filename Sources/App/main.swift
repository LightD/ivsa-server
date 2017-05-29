import HTTP
import Vapor

enum GeneralErrors: Error {
    case missingParams
}


extension String: Error {
    
}

extension Request {
    // Base URL returns the hostname, scheme, and port in a URL string form.
    var baseURL: String {
        return uri.scheme + "://" + uri.hostname + (uri.port == nil ? "" : ":\(uri.port!)")
    }
    
}

let config = try Config()
try config.setup()

let drop = try Droplet(config)
try drop.setup()

try drop.run()
