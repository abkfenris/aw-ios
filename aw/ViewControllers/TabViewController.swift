import CoreData
import UIKit

class TabViewController: UITabBarController, MOCViewControllerType {
    var managedObjectContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 1
        DefaultsManager.fetchingreaches = false

        self.delegate = self

        // MARK: - Inject CoreData dependencies
        for childVC in childViewControllers {
            if let navVC = childVC as? UINavigationController,
                var destinationVC = navVC.childViewControllers[0] as? MOCViewControllerType {
                destinationVC.managedObjectContext = managedObjectContext
            }
        }

        if let context = managedObjectContext {
            let request = NSFetchRequest<Reach>(entityName: "Reach")
            request.predicate = NSPredicate(format: "favorite = TRUE" )
            if let count = try? context.count(for: request), count > 0 {
                self.selectedIndex = 2
            }
        }
    }
}

// MARK: - TabBarControllerDelegate
extension TabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {

        if let navController = viewControllers?[selectedIndex] as? UINavigationController {
            for controller in navController.viewControllers.compactMap({ $0 as? RunListTableViewController }) {
                controller.dismissSearch()
            }
        }
        return true
    }
}
