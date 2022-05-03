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
        

        let diaryVC = UINavigationController(rootViewController: DiaryViewController())
        let writingVC = UINavigationController(rootViewController: WritingDiaryViewController())
        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        
        diaryVC.tabBarItem = UITabBarItem(title: "Diary", image: UIImage(systemName: "book.closed.fill"), tag: 0)
        writingVC.tabBarItem = UITabBarItem(title: "Write", image: UIImage(systemName: "pencil"), tag: 1)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)
        
        setViewControllers([diaryVC, writingVC, settingsVC], animated: true)
    }


}

