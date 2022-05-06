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
        let control = UISegmentedControl(items: ["Classic", "Collection", "Gallery"])
        //let titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        control.setTitleTextAttributes([.foregroundColor: UIColor.lightText], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.backgroundColor = K.mainNavy
        control.selectedSegmentTintColor = K.mainBlueTitleColor
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
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ in
        DiaryViewController.createLayout(for: .collection)
    }))
    
    private let galleryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ in
        DiaryViewController.createLayout(for: .gallery)
    }))
    
    private let classicTableView = UITableView()
    
    private var diaryViewModels = [DiaryViewModel]()
    private var groupedSections = [GroupedDiaryViewModel]()

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
             
        searchView.searchBar.delegate = self
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        
        fetchData()
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = K.mainBlack
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.standardAppearance = navBarAppearance
    }
    
    private func fetchData(){
        CoreDataManager.shared.getAllItems {[weak self] viewModels in
            guard let viewModels = viewModels else {
                return
            }

            self?.diaryViewModels = viewModels
            
            let groupedViewModels = Dictionary(grouping: viewModels) { $0.group }
            self?.groupedSections = groupedViewModels.map {GroupedDiaryViewModel(sectionName: $0.key, viewModels: $0.value)}
            self?.sortData()
        }
    }
    
    private func sortData(){
        
        diaryViewModels.sort { prev, next in
            return prev.date > next.date
        }
        
        groupedSections.sort(by: { prev, next in
            return (prev.viewModels.first?.date ?? Date()) > (next.viewModels.first?.date ?? Date())
        })
        
        groupedSections.forEach{ $0.viewModels.sort { prev, next in
            prev.date > next.date
        }}
    }
    
    
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl){
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentOffset.x = CGFloat(sender.selectedSegmentIndex)*self.view.frame.width
            if self.scrollView.contentOffset.x < self.view.frame.width*2 && self.navigationItem.searchController == nil{
                self.navigationItem.searchController = self.searchView
            }
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
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 10)
            
            // group
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.30), heightDimension: .fractionalHeight(0.18)), subitems: [item])
            
            
            // section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = [supplementaryViews]
            
            return section
            
        case .gallery:
            // item
            let horizontalItemOne = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)))
            let horizontalItemTwo = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1.0)))
            let horizontalGroupOne = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)), subitems: [horizontalItemOne, horizontalItemTwo])
            
            let bigItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.4)))
            
            let horizontalItemThree = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
            let horizontalItemFour = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
            let horizontalGroupTwo = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)), subitems: [horizontalItemThree, horizontalItemFour])
            
            let horizontalItemFive = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
            let horizontalItemSix = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0)))
            let horizontalGroupThree = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)), subitems: [horizontalItemFive, horizontalItemSix])

            
            // group
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.7)), subitems: [horizontalGroupOne, bigItem, horizontalGroupTwo, horizontalGroupThree])
            
            // section
            let section = NSCollectionLayoutSection(group: group)

            return section
        }
    }
                                                  
    private func setUpNavBar(){
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: K.mainNavy]
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.standardAppearance = navBarAppearance
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
        classicTableView.backgroundColor = .systemBackground
        scrollView.addSubview(classicTableView)
    }
    
    private func setUpCollectionView(){
        // CollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: DiaryCollectionViewCell.identifier)
        collectionView.register(DiaryCollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiaryCollectionViewHeaderView.identifier)
        collectionView.backgroundColor = .systemBackground
        
        // Gallery collectionView
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        galleryCollectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.identifier)
        
        scrollView.addSubview(collectionView)
        scrollView.addSubview(galleryCollectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //scrollView.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: view.frame.height)
        scrollView.frame = view.bounds
        classicTableView.frame = scrollView.bounds
        collectionView.frame = CGRect(x: scrollView.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
        galleryCollectionView.frame = CGRect(x: scrollView.frame.width*2, y: 0, width: view.frame.width, height: view.frame.height)
    }

}


// MARK: Set Up TableView
extension DiaryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ClassicDiaryTableViewCell.identifier, for: indexPath) as? ClassicDiaryTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: diaryViewModels[indexPath.row])
        cell.loadTestVideo(filePath: URL(string: diaryViewModels[indexPath.row].fileURL)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(DiaryCellViewController(viewModel: diaryViewModels[indexPath.row]), animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}


// MARK: Set Up CollectionView
extension DiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView == self.collectionView{
            return groupedSections.count
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: DiaryCollectionViewHeaderView.identifier, for: indexPath) as? DiaryCollectionViewHeaderView else {
            return UICollectionReusableView()
        }
        
        cell.configure(with: groupedSections[indexPath.section].displayedSectionName ?? "Unknown")
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionView{
            return groupedSections[section].viewModels.count
        }else{
            return diaryViewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryCollectionViewCell.identifier, for: indexPath) as? DiaryCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let viewModel = groupedSections[indexPath.section].viewModels[indexPath.row]
            cell.configure(with: viewModel)

            return cell
        }else if collectionView == self.galleryCollectionView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.identifier, for: indexPath) as? GalleryCollectionViewCell else{
                return UICollectionViewCell()
            }
            
            if let image = diaryViewModels[indexPath.row].getPreviewImage(){
                cell.configure(with: image)
            }
                
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(DiaryCellViewController(viewModel: diaryViewModels[indexPath.row]), animated: true)
    }
    
    
}


extension DiaryViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offset = scrollView.contentOffset.x

        if offset > view.frame.width*0.6{
            segmentedControl.selectedSegmentIndex = 1
            if navigationItem.searchController == nil{
                navigationItem.searchController = searchView
            }
        }
        
        if offset > view.frame.width*1.6{
            segmentedControl.selectedSegmentIndex = 2
            navigationItem.searchController = nil
        }
        
        if offset < view.frame.width*0.6 && offset > 1{
            segmentedControl.selectedSegmentIndex = 0
            if navigationItem.searchController == nil{
                navigationItem.searchController = searchView
            }
        }
    }
}


extension DiaryViewController: UISearchControllerDelegate{
    
}


extension DiaryViewController: UISearchBarDelegate{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
}


extension DiaryViewController: WritingDiaryViewControllerDelegate{
    func writingDiaryViewControllerDidFinishPosting(_ controller: WritingDiaryViewController, newItem: DiaryViewModel) {
        self.diaryViewModels.append(newItem)

        var found = false
        
        for groupedViewModel in groupedSections{
            if groupedViewModel.sectionName == newItem.group{
                groupedViewModel.viewModels.append(newItem)
                found = true
            }
        }
        
        if !found{
            groupedSections.append(GroupedDiaryViewModel(sectionName: newItem.group, viewModels: [newItem]))
        }
        
        self.sortData()
        self.collectionView.reloadData()
        self.galleryCollectionView.reloadData()
        self.classicTableView.reloadData()
    }
    

}
