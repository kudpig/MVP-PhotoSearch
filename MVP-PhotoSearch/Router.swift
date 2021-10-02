//
//  Router.swift
//  MVP-PhotoSearch
//
//  Created by Shinichiro Kudo on 2021/06/23.
//

import UIKit

final class Router {
    
    static func showRoot(window: UIWindow?) {
        let storyboard = UIStoryboard(name: "SearchPhoto", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SearchPhotoViewController
        let nav = UINavigationController(rootViewController: vc)
        
        let presenter = SearchPresenter(output: vc) // outputプロトコルに準拠しているものをプレゼンターの出力先として設定する
        vc.inject(presenter: presenter)
        
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
    
    
    private static func show(fromVC: UIViewController, nextVC: UIViewController) {
        if let nav = fromVC.navigationController {
            nav.pushViewController(nextVC, animated: true)
        } else {
            fromVC.present(nextVC, animated: true, completion: nil)
        }
    }
    
}
