//
//  SceneDelegate.swift
//  1_project_hitlist
//
//  Created by Boris Bolshakov on 27.11.21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
        guard let sceneWin = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: sceneWin)

        let navVC = UINavigationController(rootViewController: ViewController())
        navVC.navigationBar.prefersLargeTitles = true
        
        window.rootViewController = navVC
        window.makeKeyAndVisible()
        self.window = window
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
       
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

