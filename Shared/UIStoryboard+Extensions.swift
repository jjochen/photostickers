import UIKit

extension UIStoryboard {

    class func main() -> UIStoryboard {
        return UIStoryboard(name: StoryboardNames.Main.rawValue, bundle: nil)
    }

    func viewControllerWithID(_ identifier: ViewControllerStoryboardIdentifier) -> UIViewController {
        return self.instantiateViewController(withIdentifier: identifier.rawValue)
    }
}
