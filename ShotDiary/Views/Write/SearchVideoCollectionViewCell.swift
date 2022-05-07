//
//  SearchVideoCollectionViewCell.swift
//  ShotDiary
//
//  Created by Sen Lin on 8/5/2022.
//

import UIKit
import AVKit

class SearchVideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchVideoCollectionViewCell"
    
    private let playerController = AVPlayerViewController()
    
    private let chosenButton: UIButton = {
        let button = UIButton()
        button.tintColor = K.mainNavy
        button.setTitle("Choose", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(playerController.view)
        contentView.addSubview(chosenButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerController.view.frame = bounds
        
        let buttonWidth = frame.width*0.7
        let buttonHeight = CGFloat(25)
        chosenButton.frame = CGRect(x: (frame.width-buttonWidth)/2, y: frame.height-buttonHeight-10,
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
    }
    
}
