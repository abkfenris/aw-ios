import CoreData
import Foundation

protocol ReachFetchRequestControllerType {
    var managedObjectContext: NSManagedObjectContext? { get set }
    var fetchedResultsController: NSFetchedResultsController<Reach>? { get set }
    var predicates: [NSPredicate] { get set }
}

extension ReachFetchRequestControllerType {
    func initializeFetchedResultController() -> NSFetchedResultsController<Reach>? {
        guard let moc = managedObjectContext else { return nil }

        let request = NSFetchRequest<Reach>(entityName: "Reach")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: moc,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }

    func difficultiesPredicate() -> NSCompoundPredicate? {
        var classPredicates: [NSPredicate] = []

        for difficulty in DefaultsManager.classFilter {
            classPredicates.append(NSPredicate(format: "difficulty\(difficulty) == TRUE"))
        }
        if classPredicates.count == 0 {
            return nil
        }
        return NSCompoundPredicate(orPredicateWithSubpredicates: classPredicates)
    }

    func regionsPredicate() -> NSPredicate? {
        let regions = DefaultsManager.regionsFilter
        if regions.count == 0 {
            return nil
        }
        return NSPredicate(format: "state IN %@", regions)
    }

    func distancePredicate() -> NSPredicate? {
        let distance = DefaultsManager.distanceFilter
        if distance == 0 { return nil }
        let predicates: [NSPredicate] = [
            NSPredicate(format: "distance <= %lf", distance),
            NSPredicate(format: "distance != 0")] // hide invalid distances
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
