//
//  SwitchTableViewCell.swift
//  ShotDiary
//
//  Created by Sen Lin on 21/5/2022.
//

import Foundation
import UIKit

class SwitchTableViewCell: UITableViewCell {
    static let identifier = "SwitchTableViewCell"

    private let imageLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "icloud")
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.isOn = false
        return switchButton
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imageLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let padding = CGFloat(10)
        let imageSize = frame.height - padding
        let switchSize = frame.height - padding

        imageLabel.frame = CGRect(x: padding, y: (frame.height-imageSize)/2, width: imageSize, height: imageSize)
        titleLabel.frame = CGRect(x: imageSize+padding+padding, y: (frame.height-imageSize)/2, width: 150, height: imageSize)
        switchButton.frame = CGRect(x: frame.width-switchSize-padding*3, y: (frame.height-switchSize)/2, width: switchSize, height: switchSize)
    }

    func configure(image: UIImage, title: String, isOn: Bool = false) {
        imageLabel.image = image
        titleLabel.text = title
        switchButton.isOn = isOn
    }
}
