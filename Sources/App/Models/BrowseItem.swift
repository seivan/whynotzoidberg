import Vapor
import Fluent
import Foundation

final class BrowseItem: Model {
    var id: Node?
    var content: String
    
    init(content: String) {
//        self.id = UUID().uuidString.makeNode()
        self.content = content
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        content = try node.extract("content")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content
        ])
    }
}

// MARK: Database Preparations


extension BrowseItem {
    /**
        This will automatically fetch from database, using example here to load
        automatically for example. Remove on real models.
    */
    public convenience init?(from string: String) throws {
        self.init(content: string)
    }
}

extension BrowseItem: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("browseitems") { posts in
            posts.id()
            posts.string("content", optional: false)
        }
        
    }

    static func revert(_ database: Database) throws {
        //
    }
}
