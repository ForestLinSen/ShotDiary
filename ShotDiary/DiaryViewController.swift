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
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ in
        DiaryViewController.createLayout(for: .collection)
    }))
    
    private let classicTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setUpScrollView()
        setUpCollectionView()
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
        
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentOffset.x = CGFloat(sender.selectedSegmentIndex)*self.view.frame.width
        }
        
        
    }
    
    // MARK: - UI Set Up
    static func createLayout(for page: PageKind) -> NSCollectionLayoutSection{
        switch page {
        case .collection:
            
            let supplementaryViews = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.1)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            // item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10)
            
            // group
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.30), heightDimension: .fractionalHeight(0.18)), subitems: [item])
            
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = [supplementaryViews]
            
            return section
            
        case .gallery:
            // item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            
            // group
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.12), heightDimension: .fractionalHeight(1.0)), subitems: [item])
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            
            
            return section
        }
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
        classicTableView.register(ClassicDiaryTableViewCell.self, forCellReuseIdentifier: ClassicDiaryTableViewCell.identifier)
        classicTableView.delegate = self
        classicTableView.dataSource = self
        scrollView.addSubview(classicTableView)
    }
    
    private func setUpCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: DiaryCollectionViewCell.identifier)
        collectionView.register(DiaryCollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiaryCollectionViewHeaderView.identifier)
        scrollView.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //scrollView.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: view.frame.height)
        scrollView.frame = view.bounds
        classicTableView.frame = scrollView.bounds
        collectionView.frame = CGRect(x: scrollView.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
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


extension DiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiaryCollectionViewHeaderView.identifier, for: indexPath) as? DiaryCollectionViewHeaderView else {
            return UICollectionReusableView()
        }
        
        cell.configure(with: "May 2022")
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.identifier, for: indexPath) as? DiaryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure()
        
        return cell
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

