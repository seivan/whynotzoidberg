import URI
import Vapor
//import MongoKitten
import FluentMongo


public final class MongoDBProvider: Vapor.Provider {
    public let provided: Vapor.Providable
    
    public enum MongoDBError: Swift.Error {
        case noMongoDBError
        case missingConfig(String)
        
    }
    
    public let driver: MongoDriver
    
    public convenience init(config: Config) throws {
        guard let mongodb = config["mongodb"]?.object else { throw MongoDBError.noMongoDBError }
        if let url = mongodb["url"]?.string { try self.init(url: url ) }
        else {
            guard let host = mongodb["host"]?.string else { throw MongoDBError.missingConfig("host") }
            guard let user = mongodb["user"]?.string else { throw MongoDBError.missingConfig("user") }
            guard let password = mongodb["password"]?.string else { throw MongoDBError.missingConfig("password") }
            guard let database = mongodb["database"]?.string else { throw MongoDBError.missingConfig("database") }
            let port = mongodb["port"]?.int
            try self.init(
                host: host,
                user: user,
                password: password,
                database: database,
                port: port
            )
        }
    }
    
    public convenience init(url: String) throws {
        let uri = try URI(url)
        guard
            let user = uri.userInfo?.username,
            let pass = uri.userInfo?.info else { throw MongoDBError.missingConfig("UserInfo") }
        
        let db = uri.path
            .characters
            .split(separator: "/")
            .map(String.init)
            .joined(separator: "")
        
        try self.init(
            host: uri.host,
            user: user,
            password: pass,
            database: db,
            port: uri.port.flatMap(Int.init)
        )
    }
    
 
    public init(
        host: String,
        user: String,
        password: String,
        database: String,
        port: Int? = nil
        ) throws {
        let driver = try MongoDriver(
            database: database,
            user: user,
            password: password,
            host: host,
            port: port ?? 27017
        )
        
        self.driver = driver
        let db = Database(driver)
        provided = Providable(database: db)
        
    }
    
    /**
     Called after the Droplet has completed
     initialization and all provided items
     have been accepted.
     */
    public func afterInit(_ drop: Droplet) {
        
    }
    
    /**
     Called before the Droplet begins serving
     which is @noreturn.
     */
    public func beforeRun(_ drop: Droplet) {
        
    }
}

let drop = Droplet(
    preparations: [BrowseItem.self],
    providers:[MongoDBProvider.self]
)



drop.get { req in
    let lang = req.headers["Accept-Language"]?.string ?? "en"
    return try drop.view.make("welcome", [
    	"message": Node.string(drop.localization[lang, "welcome", "title"])
    ])
}

drop.resource("viewables", BrowseItemController<BrowseItem>())
drop.resource("browseitems", BrowseItemController<BrowseItem>())

drop.resource("/", BrowseItemController<BrowseItem>())
drop.get("blitz-me") { req in
    let posts = (try? BrowseItem.all()) ?? []

    var p = BrowseItem(content: "CREATING \(posts.count+1)")
    try p.save()
    return p.makeJSON()

}
drop.run()
