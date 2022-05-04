//
//  ViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 2/5/2022.
//

import UIKit

class HomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = K.mainBlack
//        tabBar.standardAppearance = appearance
        
        let diaryVC = DiaryViewController()
        let writingVC = WritingDiaryViewController()
        let settingsVC = SettingsViewController()
        writingVC.delegate = diaryVC

        let nav1 = UINavigationController(rootViewController: diaryVC)
        let nav2 = UINavigationController(rootViewController: writingVC)
        let nav3 = UINavigationController(rootViewController: settingsVC)
        
        nav1.tabBarItem = UITabBarItem(title: "Diary", image: UIImage(systemName: "book.closed.fill"), tag: 0)
        nav2.tabBarItem = UITabBarItem(title: "Write", image: UIImage(systemName: "pencil"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)
        
        setViewControllers([nav1, nav2, nav3], animated: true)
    }


}

