import UIKit

extension UIStoryboard {

    class func app() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Main.rawValue, bundle: nil)
    }

    class func messageExtension() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.MainInterface.rawValue, bundle: nil)
    }

    func viewController(withID identifier: ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewController(withIdentifier: identifier.rawValue)
    }
}
