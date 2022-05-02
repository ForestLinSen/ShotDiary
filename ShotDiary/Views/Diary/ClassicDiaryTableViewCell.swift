//
//  ClassicDiaryTableViewCell.swift
//  ShotDiary
//
//  Created by Sen Lin on 2/5/2022.
//

import UIKit

class ClassicDiaryTableViewCell: UITableViewCell{
    static let identifier = "ClassicDiaryTableViewCell"
    
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        //label.backgroundColor = .systemRed
        label.numberOfLines = 1
        return label
    }()
    
    private let contentPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        //label.backgroundColor = .systemMint
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        //label.backgroundColor = .systemGreen
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        
        contentView.addSubview(previewImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentPreviewLabel)
        contentView.addSubview(dateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = frame.height*0.6
        let imageYPos = (frame.height-imageSize)/2
        let titleHeight = CGFloat(20)
        let padding = CGFloat(20)
        
        previewImageView.frame = CGRect(x: padding, y: imageYPos, width: imageSize, height: imageSize)
        titleLabel.frame = CGRect(x: imageSize+padding*2, y: imageYPos, width: frame.width-imageSize-padding*3, height: titleHeight)
        dateLabel.frame = CGRect(x: imageSize+padding*2, y: imageYPos+titleHeight, width: 100, height: titleHeight)
        contentPreviewLabel.frame = CGRect(x: imageSize+padding*2, y: imageYPos+titleHeight*2,
                                           width: frame.width-imageSize-padding*2, height: frame.height-titleHeight*2-padding*2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
        titleLabel.text = nil
        contentPreviewLabel.text = nil
        dateLabel.text = nil
    }
    
    func configure(){
        previewImageView.image = UIImage(named: "Samoyed")
        titleLabel.text = "My dog has made a mess of himself"
        dateLabel.text = "May 2, 2022"
        contentPreviewLabel.text = "When 5-month-old Samoyed puppy Onni returned from a doggie playdate, his owners had quite the clean-up task ahead of them. The dog‘s strikingly white fur was covered in mud from head to paw — well, except for his adorable face, which maintained its color despite the dirt everywhere else."
    }
}
