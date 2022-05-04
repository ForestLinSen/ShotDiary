//
//  DiaryCollectionViewCell.swift
//  ShotDiary
//
//  Created by Sen Lin on 2/5/2022.
//

import UIKit

class DiaryCollectionViewCell: UICollectionViewCell {
    static let identifier = "DiaryCollectionViewCell"
    
    private let previewImage: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(previewImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        let imageSize = frame.width
        let labelHeight = frame.height/8
        let padding = CGFloat(5)

        previewImage.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        titleLabel.frame = CGRect(x: 0, y: imageSize+padding, width: frame.width, height: labelHeight)
        dateLabel.frame = CGRect(x: 0, y: imageSize+labelHeight+padding, width: frame.width, height: labelHeight)
    }
    
    func configure(with viewModel: DiaryViewModel){
        previewImage.image = viewModel.getPreviewImage()
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.date.description
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImage.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
    }
}
