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


protocol WritingDiaryViewControllerDelegate: UIViewController{
    func writingDiaryViewControllerDidFinishPosting(_ controller: WritingDiaryViewController, newItem: DiaryViewModel)
}

class WritingDiaryViewController: UIViewController {
    
    var videoURL: URL?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var fileName: String?
    let playerViewController = AVPlayerViewController()
    weak var delegate: WritingDiaryViewControllerDelegate?
    
    private let titleEditor: UITextField = {
        let titleEditor = UITextField()
        titleEditor.attributedPlaceholder = NSAttributedString(string: "Untitled", attributes: [NSAttributedString.Key.foregroundColor: K.mainNavy])
        titleEditor.font = .systemFont(ofSize: 30, weight: .bold)
        titleEditor.layer.cornerRadius = 5
        titleEditor.textColor = K.mainNavy
        return titleEditor
    }()
    
    private let textEditor: UITextView = {
        let textField = UITextView()
        textField.text = "How are you today?"
        textField.textColor = K.mainNavy
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
        button.tintColor = .white
        return button
    }()
    
    private let videoFrame: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = K.mainNavy
        return view
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.bin.circle.fill"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .lightGray
        return button
    }()
    
    private let rightBarButton: UIButton = {
        let rightBarButton = UIButton()
        rightBarButton.frame = CGRect(x: 0, y: 0, width: 64, height: 34)

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = K.mainOrange
        config.title = "Post"
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incomming in
            var outgoing = incomming
            outgoing.font = .systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        })
        rightBarButton.configuration = config
        
        return rightBarButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Write"
        
        view.backgroundColor = .systemBackground
        view.addSubview(textEditor)
        view.addSubview(titleEditor)
        view.addSubview(videoFrame)
        view.addSubview(addVideoButton)

        textEditor.delegate = self
        textEditor.pasteDelegate = self
        titleEditor.delegate = self
 
        rightBarButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        
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
        
        let playerSize = view.frame.width*0.38
        videoFrame.frame = CGRect(x: (view.frame.width-playerSize)/2, y: view.safeAreaInsets.bottom + padding, width: playerSize, height: playerSize/0.618)

        addVideoButton.frame = CGRect(x: (view.frame.width-buttonSize)/2,
                                      y: view.safeAreaInsets.bottom + padding + (videoFrame.frame.height-buttonSize)/2,
                                      width: buttonSize, height: buttonSize)
        

        
        titleEditor.frame = CGRect(x: leftPadding, y: videoFrame.frame.origin.y+videoFrame.frame.height+padding*3.5,
                                   width: editorWidth, height: titleHeight)
        textEditor.frame = CGRect(x: leftPadding, y: titleEditor.frame.origin.y+titleEditor.frame.height+padding,
                                  width: editorWidth, height: 100)
        
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: titleEditor.frame.height-1, width: titleEditor.frame.width, height: 1.0)
        bottomLine.backgroundColor = K.mainTextColor.cgColor
        titleEditor.borderStyle = .none
        titleEditor.layer.addSublayer(bottomLine)
        
        //textEditor.backgroundColor = .systemBlue
        
    }
    
    
    // MARK: - Display chosen video
    func displayChosenVideo(){
        guard let url = videoURL else { return }
        
        DispatchQueue.main.async {[weak self] in
            //let videoURL = URL(string: "https://www.radiantmediaplayer.com/media/bbb-360p.mp4")

            guard let strongSelf = self else { return }
            
            strongSelf.player = AVPlayer(url: url)
            strongSelf.playerLayer = AVPlayerLayer(player: self?.player)
            strongSelf.playerViewController.player = AVPlayer(url: url)
            strongSelf.playerViewController.videoGravity = .resizeAspectFill

            strongSelf.view.addSubview((self?.playerViewController.view)!)
            strongSelf.playerViewController.view.frame = (self?.videoFrame.frame)!
            strongSelf.playerViewController.view.layer.cornerRadius = 15
            strongSelf.playerViewController.view.clipsToBounds = true

            let buttonSize = CGFloat(40)
            strongSelf.view.addSubview(strongSelf.cancelButton)
            strongSelf.cancelButton.frame = CGRect(x: (strongSelf.view.frame.width-buttonSize)/2,
                                                   y: strongSelf.videoFrame.frame.origin.y + strongSelf.videoFrame.frame.height + 10,
                                        width: buttonSize,
                                        height: buttonSize)
            strongSelf.cancelButton.addTarget(self, action: #selector(strongSelf.discardCurrentVideo), for: .touchUpInside)
        }
 
    }
    
    //MARK: - Button functions
    @objc func discardCurrentVideo(){
        let alert = UIAlertController(title: "Confirm", message: "Do you want to remove the current video?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {[weak self] _ in
            self?.removeCurrentVideo()
        }))
        
        present(alert, animated: true)
    }
    
    func removeCurrentVideo(){
        cancelButton.removeFromSuperview()
        playerViewController.view.removeFromSuperview()
        playerViewController.player?.pause()
        playerViewController.player = nil
        
        let fileManager = FileManager.default
        if let url = videoURL, fileManager.fileExists(atPath: url.path){
            do{
                try fileManager.removeItem(at: url)
                videoURL = nil
                print("Debug: video URL removed")
            }catch{
                print("Debug: cannot remove given ")
            }
        }
    }
    
    
    @objc func didTapPostButton(){
        let currentPath = FileManager.default.currentDirectoryPath
        print("Debug: current path -> \(currentPath)")
        
        guard videoURL != nil else{
            let alert = UIAlertController(title: "Whoops", message: "Please Upload a Video", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        //https://stackoverflow.com/questions/54290842/how-to-store-files-in-folder-which-is-created-by-using-documentdirectory-swift
        let folderURL = getFolderURL()
        let folderExists = (try? folderURL.checkResourceIsReachable()) ?? false
        
        if !folderExists{
            try! FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
        }
       
        if fileName == nil {
            // Video from Pexels
            print("Debug: begin to download file")
            let onlineFileName = Helper.generateVideoFileName()
            let fileURL = folderURL.appendingPathComponent(onlineFileName)
            
            APIManager.shared.downloadOnlineVideo(from: videoURL!, fileURL: fileURL) {[weak self] success in
                guard let strongSelf = self else { return }
                if success{
                    print("Debug: create item status -> \(fileURL)")
                    
                    // FOR TEST
                    let date1 = Date.parse("2022-01-01")
                    let date2 = Date.parse("2022-05-01")
                    
                    let viewModel = DiaryViewModel(title: (strongSelf.titleEditor.text?.count == 0 ? "Untitled" : strongSelf.titleEditor.text) ?? "Untitled", content: strongSelf.textEditor.text ?? "", fileURL: onlineFileName, date: Date.randomBetween(start: date1, end: date2))
                    
                    CoreDataManager.shared.createItems(viewModel: viewModel){ success in
                        
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.2) {
                                strongSelf.tabBarController?.selectedIndex = 0
                            }
                        }

                        strongSelf.delegate?.writingDiaryViewControllerDidFinishPosting(strongSelf, newItem: viewModel)
                        strongSelf.titleEditor.text = nil
                        strongSelf.titleEditor.placeholder = "Untitled"
                        strongSelf.videoURL = nil
                        strongSelf.fileName = nil
                        strongSelf.textEditor.text = "How are you today?"
                        strongSelf.textEditor.textColor = K.mainNavy
                        strongSelf.player?.pause()
                        strongSelf.player = nil
                        strongSelf.playerLayer?.removeFromSuperlayer()
                        
                        strongSelf.cancelButton.removeFromSuperview()
                        strongSelf.playerViewController.view.removeFromSuperview()
                        strongSelf.playerViewController.player?.pause()
                        strongSelf.playerViewController.player = nil
                    }
                    
                }
            }
            
        }else{
            // Video from User Library
            
            do{
                if !folderExists{
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
                }
                
                guard fileName != nil else { return }
                let fileURL = folderURL.appendingPathComponent(fileName!)
                let data = try Data(contentsOf: videoURL!)
                try data.write(to: fileURL)
                
                
                // FOR TEST
                let date1 = Date.parse("2022-01-01")
                let date2 = Date.parse("2022-05-01")
                
                let viewModel = DiaryViewModel(title: (titleEditor.text?.count == 0 ? "Untitled" : titleEditor.text) ?? "Untitled", content: textEditor.text ?? "", fileURL: fileName!, date: Date.randomBetween(start: date1, end: date2))
                
                CoreDataManager.shared.createItems(viewModel: viewModel){[weak self] success in
                    guard let strongSelf = self else { return }
                    print("Debug: create item status -> \(fileURL)")
                    
                    UIView.animate(withDuration: 0.2) {
                        strongSelf.tabBarController?.selectedIndex = 0
                    }

                    strongSelf.delegate?.writingDiaryViewControllerDidFinishPosting(strongSelf, newItem: viewModel)
                    strongSelf.titleEditor.text = nil
                    strongSelf.titleEditor.placeholder = "Untitled"
                    strongSelf.videoURL = nil
                    strongSelf.fileName = nil
                    strongSelf.textEditor.text = "How are you today?"
                    strongSelf.textEditor.textColor = K.mainNavy
                    strongSelf.player?.pause()
                    strongSelf.player = nil
                    strongSelf.playerLayer?.removeFromSuperlayer()
                    
                    strongSelf.cancelButton.removeFromSuperview()
                    strongSelf.playerViewController.view.removeFromSuperview()
                    strongSelf.playerViewController.player?.pause()
                    strongSelf.playerViewController.player = nil
                }
                
                
            }catch{
                print("Debug: something wrong \(error)")
            }
        }

    }
    
    private func getFolderURL() -> URL{
        let fileManager = FileManager.default
        let folderName = "userVideos"
        let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = documentsFolder.appendingPathComponent(folderName)
        return folderURL
    }

    @objc func didTapAddVideoButton(){
        let actionsheet = UIAlertController(title: "Choose a Video", message: "Choose a video from your library or search videos online", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Your Video Library", style: .default, handler: {[weak self] _ in
            self?.presentVideoPicker()
        }))
        actionsheet.addAction(UIAlertAction(title: "Search Pexels Videos", style: .default, handler: {[weak self] _ in
            let vc = SearchVideosViewController()
            vc.delegate = self
            let nav = UINavigationController(rootViewController: vc)
            self?.present(nav, animated: true)
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionsheet, animated: true)
    }
    
    @objc func presentVideoPicker(){
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .videos
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
}

extension WritingDiaryViewController: UITextViewDelegate, UITextPasteDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == K.mainNavy{
            textView.text = ""
            textView.textColor = K.mainBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0{
            textView.text = "How are you today?"
            textView.textColor = K.mainNavy
        }
    }
    
    func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, performPasteOf attributedString: NSAttributedString, to textRange: UITextRange) -> UITextRange {
        
        textEditor.replace(textRange, withText: attributedString.string)
        return textRange
    }
}

extension WritingDiaryViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == ""{
            textField.placeholder = "Untitled"
        }
    }
}


extension WritingDiaryViewController: PHPickerViewControllerDelegate{
    // https://developer.apple.com/forums/thread/652695
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.first?.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier, completionHandler: {[weak self] url, error in
            guard let url = url else {
                return
            }
            
            print("Debug: file exists -> \(FileManager.default.fileExists(atPath: url.path))")
            
            self?.fileName = Helper.generateVideoFileName()
            let folder = self?.getFolderURL()
            let filePath = folder!.appendingPathComponent((self?.fileName!)!)
            let folderExists = (try? folder!.checkResourceIsReachable()) ?? false
            
            do{
                if !folderExists{
                    try FileManager.default.createDirectory(at: folder!, withIntermediateDirectories: false)
                }
                
                try FileManager.default.copyItem(at: url, to: filePath)
                self?.videoURL = filePath
                self?.displayChosenVideo()
                
            }catch{
                print("Debug: something wrong -> \(error)")
            }
        })
        
    }
}


// MARK: - Search video delegate
extension WritingDiaryViewController: SearchVideoViewControllerDelegate{
    func searchVideoViewController(_ controller: SearchVideosViewController, video: SearchVideoViewModel) {
        videoURL = video.videoURL
        displayChosenVideo()
    }
}
