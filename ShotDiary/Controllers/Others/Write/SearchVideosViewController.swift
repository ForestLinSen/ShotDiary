//
//  SearchVideosViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 7/5/2022.
//

import UIKit

class SearchVideosViewController: UIViewController {
    
    private var viewModels = [SearchVideoViewModel]()
    
    private let searchViewController: UISearchController = {
        let resultsVC = SearchResultsViewController()
        let searchVC = UISearchController(searchResultsController: resultsVC)
        searchVC.searchBar.placeholder = "Search Videos From Pexels"
        return searchVC
    }()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
        SearchVideosViewController.createCollectionViewLayout()
    }))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchViewController
        
        configureCollectionView()
        
        APIManager.shared.getPopularVideo {[weak self] result in
            switch result{
                
            case .success(let response):
                response.videos.forEach { video in
                    if let videoUrl = URL(string: video.video_files.first?.link ?? ""), let previewURL = URL(string: video.image){
                        self?.viewModels.append(SearchVideoViewModel(videoURL: videoUrl, previewImageURL: previewURL))
                    }
                }
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
                
            case .failure(_):
                break
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    static func createCollectionViewLayout() -> NSCollectionLayoutSection{
        // item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        // group
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.33)), subitem: item, count: 2)
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    func configureCollectionView(){
        view.addSubview(collectionView)
        collectionView.register(SearchVideoCollectionViewCell.self, forCellWithReuseIdentifier: SearchVideoCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}


extension SearchVideosViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchVideoCollectionViewCell.identifier, for: indexPath) as? SearchVideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let viewModel = viewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    
}
