//
//  WritingDiaryViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 2/5/2022.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation
import AVKit

class WritingDiaryViewController: UIViewController {
    
    var videoURL: URL?
    var player: AVPlayer?
    
    
    private let titleEditor: UITextField = {
        let titleEditor = UITextField()
        titleEditor.placeholder = "Untitled"
        titleEditor.font = .systemFont(ofSize: 30, weight: .semibold)
        titleEditor.layer.cornerRadius = 5
        titleEditor.textColor = .label
        return titleEditor
    }()
    
    private let textEditor: UITextView = {
        let textField = UITextView()
        textField.text = "How are you today?"
        textField.textColor = .secondaryLabel
        textField.backgroundColor = nil
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        return textField
    }()
    
    private let addVideoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.square"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.tintColor = .secondaryLabel
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Write a diary"
        
        view.backgroundColor = .systemBackground
        view.addSubview(textEditor)
        view.addSubview(titleEditor)
        view.addSubview(addVideoButton)
        
        
        textEditor.delegate = self
        textEditor.pasteDelegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapPostButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapPostButton))
        
        addVideoButton.addTarget(self, action: #selector(didTapAddVideoButton), for: .touchUpInside)
        
        displayChosenVideo()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let editorWidth = view.frame.width*0.75
        let titleHeight = min(view.frame.height/20, 200)
        let leftPadding = (view.frame.width-editorWidth)/2
        let padding = CGFloat(20)
        let buttonSize = CGFloat(60)
        
        titleEditor.frame = CGRect(x: leftPadding, y: view.safeAreaInsets.bottom+padding*2,
                                   width: editorWidth, height: titleHeight)
        textEditor.frame = CGRect(x: leftPadding, y: view.safeAreaInsets.bottom+titleHeight+padding*3,
                                  width: editorWidth, height: 250)
        addVideoButton.frame = CGRect(x: (view.frame.width-buttonSize)/2, y: textEditor.frame.maxY+padding,
                                      width: buttonSize, height: buttonSize)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: titleEditor.frame.height-2, width: titleEditor.frame.width, height: 2.0)
        bottomLine.backgroundColor = UIColor.secondaryLabel.cgColor
        titleEditor.borderStyle = .none
        titleEditor.layer.addSublayer(bottomLine)
        
    }
    
    func displayChosenVideo(){
        guard let url = videoURL else { return }
        
        print("Debug: begin to display file url")
        DispatchQueue.main.async {[weak self] in
            //let videoURL = URL(string: "https://www.radiantmediaplayer.com/media/bbb-360p.mp4")
            //guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mov") else { return }
            print("Debug: video url \(url)")
            let player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            
            let playerSize = CGFloat(300)
            playerLayer.frame = CGRect(x: ((self?.view.frame.width)!-playerSize)/2, y: (self?.addVideoButton.frame.origin.y)!, width: playerSize, height: playerSize)
            playerLayer.cornerRadius = 25
            playerLayer.masksToBounds = true
            
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.backgroundColor = UIColor.systemBlue.cgColor
            self?.view.layer.addSublayer(playerLayer)
            player.play()
        }
        
        
        
    }
    
    // MARK: - Button functions
    @objc func didTapPostButton(){
        print("Debug: did tap post button")
        
        guard videoURL != nil else{
            let alert = UIAlertController(title: "Whoops", message: "Please Upload a Video", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        // https://iosdevcenters.blogspot.com/2016/04/save-and-get-image-from-document.html
        // https://stackoverflow.com/questions/39108385/how-do-i-get-nsdata-from-a-video-url
        
    //https://stackoverflow.com/questions/54290842/how-to-store-files-in-folder-which-is-created-by-using-documentdirectory-swift
        let fileManager = FileManager.default
        
        let folderName = "userVideos"
        let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = documentsFolder.appendingPathComponent(folderName)
        let folderExists = (try? folderURL.checkResourceIsReachable()) ?? false
        
        do{
            if !folderExists{
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)
            }
            
            let fileURL = folderURL.appendingPathComponent(Helper.generateVideoFileName())
            let data = try Data(contentsOf: videoURL!)
            try data.write(to: fileURL)
            
            loadTestVideo(filePath: fileURL)
            
        }catch{
            print("Debug: something wrong \(error)")
        }
    }
    
//
//    do{
//        let fileData = try Data(contentsOf: videoURL!)
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//
//        if !fileManager.fileExists(atPath: videoFolder){
//
//            try fileManager.createDirectory(at: videoFolder.path, withIntermediateDirectories: <#T##Bool#>)
//
//            print("Debug: video name \(videoFileName)")
//            if fileManager.createFile(atPath: videoFileName, contents: fileData as Data, attributes: nil){
//                print("Debug: successfully create file data")
//            }else{
//                print("Debug: error write data ")
//            }
//        }
//
//    }catch{
//        print("Debug: error create data")
//    }




private func loadTestVideo(filePath: URL){

    print("Debug: file :\(filePath)")
    let playerItem = AVPlayerItem(url: filePath)
    let player = AVPlayer(playerItem: playerItem)
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = self.view.frame
    self.view.layer.addSublayer(playerLayer)
    player.play()
}

@objc func didTapAddVideoButton(){
    let actionsheet = UIAlertController(title: "Choose a Video", message: "Choose a video from your library or take a video", preferredStyle: .actionSheet)
    actionsheet.addAction(UIAlertAction(title: "Video Library", style: .default, handler: {[weak self] _ in
        self?.presentVideoPicker()
    }))
    actionsheet.addAction(UIAlertAction(title: "Take a Video", style: .default, handler: { _ in
        
    }))
    actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(actionsheet, animated: true)
}

@objc func presentVideoPicker(){
    var config = PHPickerConfiguration(photoLibrary: .shared())
    config.filter = .videos
    config.selectionLimit = 1
    let vc = PHPickerViewController(configuration: config)
    vc.delegate = self
    present(vc, animated: true)
    
}

}

extension WritingDiaryViewController: UITextViewDelegate, UITextPasteDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Debug: did begin editing")
        if textView.textColor == .secondaryLabel{
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0{
            textView.text = "How are you today?"
            textView.textColor = .secondaryLabel
        }
    }
    
    func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, performPasteOf attributedString: NSAttributedString, to textRange: UITextRange) -> UITextRange {
        
        textEditor.replace(textRange, withText: attributedString.string)
        return textRange
    }
}


extension WritingDiaryViewController: PHPickerViewControllerDelegate{
    // https://stackoverflow.com/questions/63397033/how-to-fetch-live-photo-or-video-from-phpickerviewcontroller-delegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil, completionHandler: {[weak self] videoURL, error in
            
            guard let url = videoURL as? URL else {
                return
            }
            
            print("Debug: unwrapped: \(url)")
            
            self?.videoURL = url
            self?.displayChosenVideo()
        })
        
    }
}
