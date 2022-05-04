//
//  GalleryCollectionViewCell.swift
//  ShotDiary
//
//  Created by Sen Lin on 3/5/2022.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell{
    static let identifier = "GalleryCollectionViewCell"
    
    private let diaryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(diaryImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        diaryImageView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        diaryImageView.image = nil
    }
    
    func configure(with image: UIImage){
        diaryImageView.image = image
    }
}
