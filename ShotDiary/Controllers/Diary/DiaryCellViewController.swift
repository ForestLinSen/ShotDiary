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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = K.mainBlack
        addVideoLayer()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
            
            
            
        }catch{
            print("Debug: cannot fetch given file")
        }
    }
    

}
