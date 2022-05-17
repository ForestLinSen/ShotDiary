//
//  SearchVideoCollectionViewCell.swift
//  ShotDiary
//
//  Created by Sen Lin on 8/5/2022.
//

import UIKit
import AVKit

protocol SearchVideoCollectionViewCellDelegate: UIViewController{
    func searchVideoCollectionViewCell(_ cell: SearchVideoCollectionViewCell, didChooseVideo video: SearchVideoViewModel)
}

class SearchVideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchVideoCollectionViewCell"
    
    private let playerController = AVPlayerViewController()
    weak var delegate: SearchVideoCollectionViewCellDelegate?
    var viewModel: SearchVideoViewModel?
    
    private let chosenButton: UIButton = {
        let button = UIButton()
        button.tintColor = K.mainNavy
        button.setTitle("Choose", for: .normal)
        button.backgroundColor = K.mainNavy
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 15
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(playerController.view)
        contentView.addSubview(chosenButton)
        
        chosenButton.addTarget(self, action: #selector(didTapChooseButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerController.view.frame = bounds
        
        let buttonWidth = frame.width*0.6
        let buttonHeight = CGFloat(35)
        let padding = CGFloat(10)
        chosenButton.frame = CGRect(x: frame.width-buttonWidth-padding, y: frame.height-buttonHeight-padding,
                                    width: buttonWidth, height: buttonHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerController.player?.pause()
        playerController.player = nil
    }
    
    func configure(with viewModel: SearchVideoViewModel){
        print("Debug: player url: \(viewModel.videoURL)")
        playerController.player = AVPlayer(url: viewModel.videoURL)
        playerController.videoGravity = .resizeAspectFill
        self.viewModel = viewModel
    }
    
    @objc func didTapChooseButton(){
        
        guard let viewModel = viewModel else {
            return
        }

        delegate?.searchVideoCollectionViewCell(self, didChooseVideo: viewModel)
        delegate?.dismiss(animated: true)
    }
    
}
