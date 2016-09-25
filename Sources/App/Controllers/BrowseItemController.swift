import Vapor
import HTTP
import Fluent
import JSON

extension Sequence where Iterator.Element: NodeRepresentable{
    func makeJSON() throws -> JSON {
        return try self.makeNode().converted(to: JSON.self)
    }
}

func crap() -> [Fluent.Entity]? {
    return nil
}

final class BrowseItemController<T>: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        let posts = (try? BrowseItem.all()) ?? []
        
        
        return try JSON(["items" : posts.makeNode()])
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var todo = try request.post()
        try todo.save()
        return todo
    }

    
//    func show(request:Request) throws -> ResponseRepresentable {
//        guard let id = request.parameters["id"]?.string else {
//            throw Abort.notFound
//        }
//        
//        return try BrowseItem.find(id)!.makeJSON()
//    }
//
    func show(request: Request, post: BrowseItem) throws -> ResponseRepresentable {
        return post.makeJSON()
    }

    func delete(request: Request, post: BrowseItem) throws -> ResponseRepresentable {
        try post.delete()
        return JSON([:])
    }

    func clear(request: Request) throws -> ResponseRepresentable {
        try BrowseItem.query().delete()
        return JSON([])
    }

    func update(request: Request, post: BrowseItem) throws -> ResponseRepresentable {
        let new = try request.post()
        var post = post
        post.content = new.content
        try post.save()
        return post
    }

    func replace(request: Request, post: BrowseItem) throws -> ResponseRepresentable {
        try post.delete()
        return try create(request: request)
    }

    func makeResource() -> Resource<BrowseItem> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func post() throws -> BrowseItem {
        guard let json = json else { throw Abort.badRequest }
        return try BrowseItem(node: json)
    }
}
