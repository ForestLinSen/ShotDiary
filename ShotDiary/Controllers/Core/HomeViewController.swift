//
//  ViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 2/5/2022.
//

import UIKit
import MetricKit

class HomeViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetricKit()
        mxSignpost(.event, log: MXMetricManager.controllerLoad, name: "Debug: sign post")
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .white
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = K.mainNavyBackground
        
        
        let diaryVC = DiaryViewController()
        let writingVC = WritingDiaryViewController()
        let settingsVC = SettingsViewController()
        writingVC.delegate = diaryVC

        let nav1 = UINavigationController(rootViewController: diaryVC)
        let nav2 = UINavigationController(rootViewController: writingVC)
        let nav3 = UINavigationController(rootViewController: settingsVC)
        
        let bookImage = UIImage(systemName: "book.closed.fill",
                                withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18, weight: .bold), scale: .large))
        let penImage = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18, weight: .bold), scale: .large))
        let gearkImage = UIImage(systemName: "gear", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 18, weight: .bold), scale: .large))

        
        nav1.tabBarItem = UITabBarItem(title: "", image: bookImage!.withBaselineOffset(fromBottom: 15), tag: 0)
        nav2.tabBarItem = UITabBarItem(title: "", image: penImage!.withBaselineOffset(fromBottom: 15), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "", image: gearkImage!.withBaselineOffset(fromBottom: 15), tag: 2)
        
        setViewControllers([nav1, nav2, nav3], animated: true)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let kBarHeight = CGFloat(80);
        tabBar.frame.size.height = kBarHeight
        tabBar.frame.origin.y = view.frame.height - kBarHeight
    }
    
    private func setupMetricKit(){
        // https://www.raywenderlich.com/20952676-monitoring-for-ios-with-metrickit-getting-started
        let manager = MXMetricManager.shared
        manager.add(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

}


extension HomeViewController: MXMetricManagerSubscriber{
    func didReceive(_ payloads: [MXMetricPayload]) {
        
        payloads.forEach { payload in
            print("Debug: payload: \(String(describing: payload.dictionaryRepresentation()))")
        }
    }

}


extension MXMetricManager{
    static let controllerLoad = MXMetricManager.makeLogHandle(category: "controllerLoad")
}
