import UIKit

class HomeTabBarController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prevent navigation back to Login
        navigationItem.hidesBackButton = true
        
        //Create tab icons
        viewControllers?.forEach {
            $0.tabBarItem.setTitleTextAttributes(Constants.FONT_AWESOME_ATTRIBUTES_TABS, for: .normal)
            $0.tabBarItem.titlePositionAdjustment = .init(horizontal: 0, vertical: Constants.TABS_VERTICAL_OFFSET)
            
            switch($0){
                case is HomeViewController:
                    $0.tabBarItem.title = String.fontAwesomeIcon(name: .home)
                    break
                case is GamesViewController:
                    $0.tabBarItem.title = String.fontAwesomeIcon(name: .dollar)
                    break
                case is ProfileViewController:
                    $0.tabBarItem.title = String.fontAwesomeIcon(name: .user)
                    break
                case is SearchViewController:
                    $0.tabBarItem.title = String.fontAwesomeIcon(name: .search)
                    break
                case is SettingsTableViewController:
                    $0.tabBarItem.title = String.fontAwesomeIcon(name: .cog)
                    break
                default:break
            }

        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        edgesForExtendedLayout = []
    
        //Keep FCM up to date.
        if SessionManager.isLoggedIn() {
            MyFSRef.updateUserFCMToken(userId: SessionManager.getUserId()).always {}
        }
    
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("the selected index is : \(tabBar.items?.index(of: item))")
    }
}
