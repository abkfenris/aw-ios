import CoreData
import Foundation
import UIKit

struct AWArticleAPIHelper {
    typealias ArticlesCallback = ([AWArticle]) -> Void
    typealias UpdateCallback = () -> Void

    static func fetchArticles(callback: @escaping ArticlesCallback) {
        let url = URL(string: "https://www.americanwhitewater.org/content/News/all/type/frontpagenews/subtype//page/0/.json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
            guard let data = data, let json = try? decoder.decode(AWArticleResponse.self, from: data) else {
                print("Unable to decode articles")
                return
            }
            callback(json.articles.articles)
        }
        task.resume()
    }

    private static func findOnNewArticle(newArticle: AWArticle, context: NSManagedObjectContext) -> Article {
        let request: NSFetchRequest<Article> = Article.fetchRequest()
        request.predicate = NSPredicate(format: "articleID == %@", newArticle.articleID)

        guard let result = try? context.fetch(request), let fetchedArticle = result.first else {
            let article = Article(context: context)
            article.articleID = newArticle.articleID
            return article
        }
        return fetchedArticle
    }

    private static func createOrUpdateArticle(newArticle: AWArticle, context: NSManagedObjectContext) {
        let article = findOnNewArticle(newArticle: newArticle, context: context)

        article.abstract = newArticle.abstract
        article.abstractPhoto = newArticle.abstractPhoto
        article.author = newArticle.author
        article.contact = newArticle.contact
        article.contents = newArticle.contents
        article.contentsPhoto = newArticle.contentsPhoto
        article.posted = newArticle.date
        article.title = newArticle.title
    }

    static func updateArticles(viewContext: NSManagedObjectContext, callback: @escaping UpdateCallback) {
        let dispatchGroup = DispatchGroup()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        dispatchGroup.enter()
        fetchArticles { (newArticles) in
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.parent = viewContext

            context.perform {
                for newArticle in newArticles {
                    createOrUpdateArticle(newArticle: newArticle, context: context)
                }
                do {
                    try context.save()
                    print("background context saved")
                } catch {
                    let error = error as NSError
                    print("Unable to save background context \(error) \(error.userInfo)")
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            viewContext.perform {
                viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

                do {
                    try viewContext.save()
                    print("Saved view context")
                } catch {
                    let error = error as NSError
                    print("Unable to save view context \(error) \(error.userInfo)")
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            DefaultsManager.articlesLastUpdated = Date()
            callback()
        }
    }
}
