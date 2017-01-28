import UIKit

extension UIStoryboard {

    class func app() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.App.rawValue, bundle: nil)
    }

    class func messageExtension() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.MessageExtension.rawValue, bundle: nil)
    }

    func viewController(withID identifier: ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewController(withIdentifier: identifier.rawValue)
    }
}
