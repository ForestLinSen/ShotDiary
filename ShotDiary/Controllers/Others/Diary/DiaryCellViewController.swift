//
//  DiaryCellViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 5/5/2022.
//

import UIKit
import AVFoundation

class DiaryCellViewController: UIViewController {
    
    private let viewModel: DiaryViewModel
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    weak var delegate: WritingDiaryViewControllerDelegate?
    private var observer: NSObjectProtocol?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = . systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .white
        return label
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = K.mainBlack
        addVideoLayer()
        configure()
        tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(didTapActionButton))
    }
    
    @objc func didTapActionButton(){
        let actionSheet = UIAlertController(title: "Edit or Delete Your Diary", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: {[weak self] _ in
            self?.presentEditInterface()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
            let alert = UIAlertController(title: "Confirm", message: "Do you want to delete this diary?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(alert, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    func presentEditInterface(){
        let vc = WritingDiaryViewController()
        vc.delegate = self.delegate
        vc.editDelegate = self
        vc.title = "Edit"
        vc.loadDiaryForEditMode(with: self.viewModel)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding = CGFloat(20)
        let contentWidth = CGFloat(300)
        let titleLabelHeight = CGFloat(50)
        let contentLabelHeight = CGFloat(150)
        
        titleLabel.frame = CGRect(x: padding, y: view.frame.height-titleLabelHeight-contentLabelHeight-padding*2, width: contentWidth, height: titleLabelHeight)
        contentLabel.frame = CGRect(x: padding, y: view.frame.height-contentLabelHeight-padding*2, width: contentWidth, height: contentLabelHeight)
        
        titleLabel.sizeToFit()
        contentLabel.sizeToFit()
        
        contentLabel.frame.size.height = min(contentLabel.frame.height, contentLabelHeight)
    }
    
    init(viewModel: DiaryViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addVideoLayer(){
        let fileManager = FileManager.default
        
        do{
            let fileURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("userVideos/\(viewModel.fileURL)")
            
            player = AVPlayer(url: fileURL)
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer?.player = player
            playerLayer?.frame = view.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            view.layer.addSublayer(playerLayer!)
            player?.play()
            
            observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                              object: player?.currentItem,
                                                              queue: .main,
                                                              using: {[weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            })
        }catch{
            print("Debug: cannot fetch given file")
        }
    }
    
    private func configure(){
        view.addSubview(titleLabel)
        view.addSubview(contentLabel)
        titleLabel.text = viewModel.title
        contentLabel.text = viewModel.content
    }
}


extension DiaryCellViewController: WritingDiaryViewControllerInEditMode{
    func writingDiaryViewControllerDidFinishEditing(_ controller: WritingDiaryViewController, title: String, content: String, fileName: String) {
        titleLabel.text = title
        contentLabel.text = content
        
        let fileURL = DiaryViewModel.getRelativeFilePath(with: fileName)
        player = AVPlayer(url: fileURL)
        playerLayer?.player = player
        player?.play()
    }
    
}
