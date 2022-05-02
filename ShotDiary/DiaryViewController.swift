//
//  DiaryViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 2/5/2022.
//

import UIKit

class DiaryViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Classic", "Article", "Gallery"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let searchView: UISearchController = {
        let vc = UISearchController()
        vc.searchBar.placeholder = "Search your diary..."
        vc.searchBar.backgroundColor = .systemBackground
        return vc
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let classicTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setUpScrollView()
        setUpTableView()
        setUpNavBar()

        view.backgroundColor = .systemBackground
        navigationItem.titleView = segmentedControl
        navigationItem.searchController = searchView
        navigationItem.hidesSearchBarWhenScrolling = false
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
    }
    
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl){
        print("Debug: segmented control value did change: \(sender.selectedSegmentIndex)")
    }
    
    private func setUpNavBar(){
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.systemBackground]
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    private func setUpScrollView(){
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.width*3, height: view.frame.height)
        scrollView.delegate = self
        searchView.delegate = self
    }
    
    private func setUpTableView(){
        classicTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        classicTableView.register(ClassicDiaryTableViewCell.self, forCellReuseIdentifier: ClassicDiaryTableViewCell.identifier)
        classicTableView.delegate = self
        classicTableView.dataSource = self
        scrollView.addSubview(classicTableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //scrollView.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: view.frame.height)
        scrollView.frame = view.bounds
        classicTableView.frame = scrollView.bounds
        
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
        return 140
    }
}


extension DiaryViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offset = scrollView.contentOffset.x

        if offset > view.frame.width*0.6{
            segmentedControl.selectedSegmentIndex = 1
        }
        
        if offset > view.frame.width*1.6{
            segmentedControl.selectedSegmentIndex = 2
        }
        
        if offset < view.frame.width*0.6{
            segmentedControl.selectedSegmentIndex = 0
        }
    }
}

extension DiaryViewController: UISearchControllerDelegate{
    
}
