//
//  DiaryViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 2/5/2022.
//

import UIKit

class DiaryViewController: UIViewController {
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Classic", "Article", "Gallery"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let searchView: UISearchController = {
        let vc = UISearchController()
        vc.searchBar.placeholder = "Search your diary..."
        return vc
    }()
    
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()

        view.backgroundColor = .systemBackground
        navigationItem.titleView = segmentedControl
        navigationItem.searchController = searchView
    }
    
    private func setUpTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ClassicDiaryTableViewCell.self, forCellReuseIdentifier: ClassicDiaryTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

}


extension DiaryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ClassicDiaryTableViewCell.identifier, for: indexPath) as? ClassicDiaryTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
