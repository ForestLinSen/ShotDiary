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
    weak var delegate: WritingDiaryViewControllerDelegate?
    
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
        
        CoreDataManager.shared.getAllItems { viewModels in
            
        }
        
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
        
        DispatchQueue.main.async {[weak self] in
            //let videoURL = URL(string: "https://www.radiantmediaplayer.com/media/bbb-360p.mp4")
            //guard let url = Bundle.main.url(forResource: "video", withExtension: "mp4") else { return }
            //print("Debug: peaky blidner url -> \(url)")
            print("Debug: video url \(url)")
            self?.player = AVPlayer(url: url)
            self?.playerLayer = AVPlayerLayer(player: self?.player)
            
            let playerSize = CGFloat(300)
            self?.playerLayer!.frame = CGRect(x: ((self?.view.frame.width)!-playerSize)/2, y: (self?.addVideoButton.frame.origin.y)!, width: playerSize, height: playerSize)
            self?.playerLayer!.cornerRadius = 25
            self?.playerLayer!.masksToBounds = true
            
            self?.playerLayer!.videoGravity = .resizeAspectFill
            self?.playerLayer!.backgroundColor = UIColor.systemBlue.cgColor
            self?.view.layer.addSublayer((self?.playerLayer)!)
            self?.player!.play()
        }
        
        
        
    }
    
    //MARK: - Button functions
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
            
            let viewModel = DiaryViewModel(title: titleEditor.text ?? "Untitled", content: textEditor.text ?? "", fileURL: fileName!, date: Date.randomBetween(start: date1, end: date2))
            
            CoreDataManager.shared.createItems(viewModel: viewModel){[weak self] success in
                guard let strongSelf = self else { return }
                print("Debug: create item status -> \(fileURL)")
                
                UIView.animate(withDuration: 0.2) {
                    strongSelf.tabBarController?.selectedIndex = 0
                }

                strongSelf.delegate?.writingDiaryViewControllerDidFinishPosting(strongSelf, newItem: viewModel)
                strongSelf.titleEditor.text = nil
                strongSelf.videoURL = nil
                strongSelf.fileName = nil
                strongSelf.textEditor.text = nil
                strongSelf.player?.pause()
                strongSelf.player = nil
                strongSelf.playerLayer?.removeFromSuperlayer()
            }
            
            
        }catch{
            print("Debug: something wrong \(error)")
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
        config.preferredAssetRepresentationMode = .current
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
}

extension WritingDiaryViewController: UITextViewDelegate, UITextPasteDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
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
