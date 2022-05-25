//
//  SearchResultsViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 8/5/2022.
//

import UIKit

class SearchResultsViewController: UIViewController {

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
        SearchVideosViewController.createCollectionViewLayout()
    }))

    private var viewModels = [SearchVideoViewModel]()
    weak var delegate: SearchVideoCollectionViewCellDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search Results ViewController"
        configureCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(SearchVideoCollectionViewCell.self, forCellWithReuseIdentifier: SearchVideoCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func configure(with videoResponse: VideosResponse) {
        videoResponse.videos.forEach { video in
            guard let videoURL = URL(string: video.video_files.first?.link ?? ""), let previewURL = URL(string: video.image) else { return }
            viewModels.append(SearchVideoViewModel(videoURL: videoURL, previewImageURL: previewURL))
        }

        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchVideoCollectionViewCell.identifier, for: indexPath) as? SearchVideoCollectionViewCell else {
            return UICollectionViewCell()
        }

        let viewModel = viewModels[indexPath.row]
        cell.configure(with: viewModel)
        cell.delegate = self.delegate
        return cell
    }
}
