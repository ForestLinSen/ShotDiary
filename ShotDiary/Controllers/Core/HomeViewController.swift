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
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = K.mainNavy
        appearance.selectionIndicatorTintColor = .white
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .systemBlue

        
        let diaryVC = DiaryViewController()
        let writingVC = WritingDiaryViewController()
        let settingsVC = SettingsViewController()
        writingVC.delegate = diaryVC

        let nav1 = UINavigationController(rootViewController: diaryVC)
        let nav2 = UINavigationController(rootViewController: writingVC)
        let nav3 = UINavigationController(rootViewController: settingsVC)
        
        let bookImage = UIImage(systemName: "book.closed.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .bold), scale: .large))
        let penImage = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .bold), scale: .large))
        let gearkImage = UIImage(systemName: "gear", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .bold), scale: .large))

        nav1.tabBarItem = UITabBarItem(title: "Diary", image: bookImage, tag: 0)
        nav2.tabBarItem = UITabBarItem(title: "Write", image: penImage, tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Settings", image: gearkImage, tag: 2)
        
        setViewControllers([nav1, nav2, nav3], animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let kBarHeight = CGFloat(93);
        tabBar.frame.size.height = kBarHeight
        tabBar.frame.origin.y = view.frame.height - kBarHeight
    }

}

