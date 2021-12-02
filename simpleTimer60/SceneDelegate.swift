//
//  SceneDelegate.swift
//  sipleTimer60
//
//  Created by 장은석 on 2021/07/13.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }

        // 셋팅값 기본 설정
        let plist = UserDefaults.standard
        plist.register(
            defaults: [
                "autohistory": true,
                "vibration": true,
                "alarmsound": true,
                "minute": 1,
                "pushnotice": false,
                "noticetime": "09:41"
            ]
        )
        plist.synchronize()
        print("scene", plist.bool(forKey: "autohistory"), plist.bool(forKey: "vibration"), plist.bool(forKey: "alarmsound"), plist.integer(forKey: "minute"), plist.bool(forKey: "pushnotice"))

        // 1. 루트 뷰 컨트롤러를 UITabBarController로 캐스팅한다.
        if let tbC = self.window?.rootViewController as? UITabBarController {
            // 2. 탭 바에서 탭 바 아이템 배열을 가져온다.
            if let tbItems = tbC.tabBar.items {
                // 3. 탭 바 아이템 배열을 가져온다.
//                tbItems[0].image = UIImage(named: "tab0")
                tbItems[1].image = UIImage(named: "tab1")
//                tbItems[2].image = UIImage(named: "tab2")

                // 4. 탭 바 아이템에 타이틀을 설정한다.
                tbItems[0].title = "log"
                tbItems[1].title = "60s"
                tbItems[2].title = "settings"

                // 5. 탭 바 아이템의 이미지 색상을 변경한다.
                tbC.tabBar.tintColor = UIColor(red: 97/256, green: 70/256, blue: 99/256, alpha: 1.0) // 선택된 탭 바 아이템의 색상
                tbC.tabBar.unselectedItemTintColor = .gray // 선택되지 않은 나머지 탭 바 아이템의 색상
                tbC.tabBar.backgroundColor = UIColor(red: 253/256, green: 156/256, blue: 156/256, alpha: 1.0)
                tbC.selectedIndex = 1
            }
        }

    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}
