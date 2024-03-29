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
import ProgressHUD

protocol WritingDiaryViewControllerDelegate: UIViewController {
    func writingDiaryViewControllerDidFinishPosting(_ controller: WritingDiaryViewController, newItem: DiaryViewModel)
    func writingDiaryViewControllerDidFinishEditing(_ controller: WritingDiaryViewController)
}

protocol WritingDiaryViewControllerInEditMode: UIViewController {
    func writingDiaryViewControllerDidFinishEditing(_ controller: WritingDiaryViewController, title: String, date: Date, content: String, fileName: String)
}

class WritingDiaryViewController: UIViewController {

    var videoURL: URL?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var fileName: String?
    let playerViewController = AVPlayerViewController()
    weak var delegate: WritingDiaryViewControllerDelegate?
    weak var editDelegate: WritingDiaryViewControllerInEditMode?
    var viewModelForEdit: DiaryViewModel?
    var onlineVideo = false

    var isDarkMode: Bool {
        return traitCollection.userInterfaceStyle == .dark
    }

    private let titleEditor: UITextField = {
        let titleEditor = UITextField()
        titleEditor.attributedPlaceholder = NSAttributedString(string: "Untitled", attributes: [NSAttributedString.Key.foregroundColor: K.mainNavy])
        titleEditor.font = .systemFont(ofSize: 30, weight: .bold)
        titleEditor.layer.cornerRadius = 5
        titleEditor.textColor = K.mainNavy
        // titleEditor.backgroundColor = .systemBackground
        return titleEditor
    }()

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 30
        return view
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
        button.tintColor = .tertiaryLabel
        return button
    }()

    private let videoFrame: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .secondarySystemFill
        return view
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .automatic
        datePicker.layer.cornerRadius = 10
        datePicker.setValue(UIColor.secondaryLabel, forKey: "textColor")
        return datePicker
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash.circle"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .tertiaryLabel
        return button
    }()

    private let rightBarButton: UIButton = {
        let rightBarButton = UIButton()
        rightBarButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)

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

    private let rightBarEditButton: UIButton = {
        let rightBarButton = UIButton()
        rightBarButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = K.mainOrange
        config.title = "Confirm"
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer({ incomming in
            var outgoing = incomming
            outgoing.font = .systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        })
        rightBarButton.configuration = config

        return rightBarButton
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = viewModelForEdit {
            title = "Edit"
        } else {
            title = "Write"
        }

        tabBarController?.tabBar.selectedItem?.title = ""

        view.backgroundColor = .secondarySystemBackground
        view.addSubview(backgroundView)
        view.addSubview(textEditor)
        view.addSubview(titleEditor)
        view.addSubview(videoFrame)
        view.addSubview(datePicker)
        view.addSubview(addVideoButton)

        textEditor.delegate = self
        textEditor.pasteDelegate = self
        titleEditor.delegate = self

        rightBarButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

        addVideoButton.addTarget(self, action: #selector(didTapAddVideoButton), for: .touchUpInside)
        displayChosenVideo()

        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = K.mainNavy
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.standardAppearance = navBarAppearance

        if isDarkMode {
            titleEditor.textColor = .label
            titleEditor.attributedPlaceholder = NSAttributedString(string: "Untitled", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
            textEditor.textColor = .secondaryLabel

        }

    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        print("Debug: date -> \(sender.date)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let editorWidth = view.frame.width*0.75
        let titleHeight = min(view.frame.height/15, 350)
        let leftPadding = (view.frame.width-editorWidth)/2
        let padding = CGFloat(20)
        let buttonSize = CGFloat(45)

        let playerSizeWidth = view.frame.width*0.28
        let playerSizeHeight = playerSizeWidth*1.52

        // (view.frame.width-playerSizeWidth)/2

        titleEditor.frame = CGRect(x: leftPadding, y: view.safeAreaInsets.bottom+padding*2,
                                   width: editorWidth, height: titleHeight)

        datePicker.frame = CGRect(x: leftPadding, y: titleEditor.frame.origin.y+titleEditor.frame.height,
                                  width: 40, height: 40)
        datePicker.sizeToFit()

        textEditor.frame = CGRect(x: leftPadding, y: titleEditor.frame.origin.y+titleEditor.frame.height+padding+40,
                                  width: editorWidth, height: 152)

        videoFrame.frame = CGRect(x: leftPadding, y: textEditor.frame.origin.y + textEditor.frame.height + padding*2,
                                  width: playerSizeWidth, height: playerSizeHeight)

        addVideoButton.frame = CGRect(x: leftPadding+playerSizeWidth/2-buttonSize/2,
                                      y: textEditor.frame.origin.y + textEditor.frame.height + (videoFrame.frame.height-buttonSize)/2 + padding*2,
                                      width: buttonSize, height: buttonSize)

        backgroundView.frame = CGRect(x: leftPadding/2, y: view.safeAreaInsets.bottom+padding*1.5,
                                      width: view.frame.width-leftPadding,
                                      height: titleHeight + 270 + playerSizeHeight + buttonSize)

//        let bottomLine = CALayer()
//        bottomLine.frame = CGRect(x: 0, y: titleEditor.frame.height-1, width: titleEditor.frame.width, height: 1.0)
//        bottomLine.backgroundColor = K.mainTextColor.cgColor
//        titleEditor.borderStyle = .none
//        titleEditor.layer.addSublayer(bottomLine)

        // textEditor.backgroundColor = .systemBlue

    }

    // MARK: - Display chosen video
    func displayChosenVideo() {
        guard let url = videoURL else { return }

        DispatchQueue.main.async {[weak self] in
            // let videoURL = URL(string: "https://www.radiantmediaplayer.com/media/bbb-360p.mp4")

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
            strongSelf.cancelButton.frame = CGRect(x: strongSelf.videoFrame.frame.origin.x + (strongSelf.videoFrame.frame.width-buttonSize)/2,
                                                   y: strongSelf.videoFrame.frame.origin.y + strongSelf.videoFrame.frame.height + 10,
                                                   width: buttonSize,
                                                   height: buttonSize)
            strongSelf.cancelButton.addTarget(self, action: #selector(strongSelf.discardCurrentVideo), for: .touchUpInside)
        }

    }

    // MARK: - Button functions
    @objc func discardCurrentVideo() {
        let alert = UIAlertController(title: "Confirm", message: "Do you want to remove the current video?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {[weak self] _ in
            self?.removeCurrentVideo()
        }))

        present(alert, animated: true)
    }

    func removeCurrentVideo() {
        cancelButton.removeFromSuperview()
        playerViewController.view.removeFromSuperview()
        playerViewController.player?.pause()
        playerViewController.player = nil

        let fileManager = FileManager.default
        if let url = videoURL, fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
                videoURL = nil
                print("Debug: video URL removed")
            } catch {
                print("Debug: cannot remove given ")
            }
        }
    }

    @objc func didTapPostButton() {
        let currentPath = FileManager.default.currentDirectoryPath
        print("Debug: current path -> \(currentPath)")

        guard videoURL != nil else {
            let alert = UIAlertController(title: "Whoops", message: "Please Upload a Video", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }

        //https://stackoverflow.com/questions/54290842/how-to-store-files-in-folder-which-is-created-by-using-documentdirectory-swift
        let folderURL = getFolderURL()
        let folderExists = (try? folderURL.checkResourceIsReachable()) ?? false

        if !folderExists {
            try! FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false)
        }

        if onlineVideo {
            // Video from Pexels
            print("Debug: begin to download file")
            let fileURL = folderURL.appendingPathComponent(fileName!)
            ProgressHUD.show("Uploading...")
            APIManager.shared.downloadOnlineVideo(from: videoURL!, fileURL: fileURL) {[weak self] success in
                guard let strongSelf = self else { return }
                if success {
                    print("Debug: create item status -> \(fileURL)")

                    DispatchQueue.main.async {
                        // FOR TEST
//                        let date1 = Date.parse("2022-01-01")
//                        let date2 = Date.parse("2022-05-01")
//                        Date.randomBetween(start: date1, end: date2)

                        let viewModel = DiaryViewModel(title: (strongSelf.titleEditor.text?.count == 0 ? "Untitled" : strongSelf.titleEditor.text) ?? "Untitled",
                                                       content: strongSelf.textEditor.text ?? "",
                                                       fileURL: strongSelf.fileName ?? "",
                                                       date: strongSelf.datePicker.date,
                                                       diaryID: UUID())

                        CoreDataManager.shared.createItems(viewModel: viewModel) { _ in
                            UIView.animate(withDuration: 0.2) {
                                strongSelf.tabBarController?.selectedIndex = 0
                            }

                            strongSelf.delegate?.writingDiaryViewControllerDidFinishPosting(strongSelf, newItem: viewModel)
                            strongSelf.clearPlayerInfo()
                            ProgressHUD.dismiss()
                        }
                    }
                }
            }

        } else {
            // Video from User Library
            ProgressHUD.show("Uploading...")
            do {

                guard fileName != nil else { return }
                let fileURL = folderURL.appendingPathComponent(fileName!)
                let data = try Data(contentsOf: videoURL!)
                try data.write(to: fileURL)

                let viewModel = DiaryViewModel(title: (titleEditor.text?.count == 0 ? "Untitled" : titleEditor.text) ?? "Untitled",
                                               content: textEditor.text ?? "", fileURL: fileName!,
                                               date: datePicker.date,
                                               diaryID: UUID())

                CoreDataManager.shared.createItems(viewModel: viewModel) {[weak self] _ in
                    guard let strongSelf = self else { return }
                    print("Debug: create item status -> \(fileURL)")

                    UIView.animate(withDuration: 0.2) {
                        strongSelf.tabBarController?.selectedIndex = 0
                    }

                    strongSelf.delegate?.writingDiaryViewControllerDidFinishPosting(strongSelf, newItem: viewModel)
                    strongSelf.clearPlayerInfo()
                    ProgressHUD.dismiss()
                }
            } catch {
                print("Debug: something wrong \(error)")
            }
        }

    }

    private func clearPlayerInfo() {
        titleEditor.text = nil
        titleEditor.placeholder = "Untitled"
        videoURL = nil
        fileName = nil
        onlineVideo = false
        textEditor.text = "How are you today?"
        textEditor.textColor = K.mainNavy
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        cancelButton.removeFromSuperview()
        playerViewController.view.removeFromSuperview()
        playerViewController.player?.pause()
        playerViewController.player = nil
    }

    private func getFolderURL() -> URL {
        let fileManager = FileManager.default
        let folderName = "userVideos"
        let documentsFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = documentsFolder.appendingPathComponent(folderName)
        return folderURL
    }

    @objc func didTapAddVideoButton() {
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

    @objc func presentVideoPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .videos
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)

    }

}

extension WritingDiaryViewController: UITextViewDelegate, UITextPasteDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == K.mainNavy {
            textView.text = ""
            textView.textColor = K.mainBlack
        } else if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = K.grayTextColorWithBackground
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count == 0 {
            textView.text = "How are you today?"

            if isDarkMode {
                textView.textColor = .secondaryLabel
            } else {
                textView.textColor = K.mainNavy
            }

        }
    }

    func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, performPasteOf attributedString: NSAttributedString, to textRange: UITextRange) -> UITextRange {

        textEditor.replace(textRange, withText: attributedString.string)
        return textRange
    }
}

extension WritingDiaryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == ""{
            textField.placeholder = "Untitled"
        }
    }
}

extension WritingDiaryViewController: PHPickerViewControllerDelegate {
    // https://developer.apple.com/forums/thread/652695
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        results.first?.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier, completionHandler: {[weak self] url, error in
            ProgressHUD.show("Uploading...")
            guard let url = url else {
                return
            }

            print("Debug: file exists -> \(FileManager.default.fileExists(atPath: url.path))")

            self?.fileName = Helper.generateVideoFileName()
            let folder = self?.getFolderURL()
            let filePath = folder!.appendingPathComponent((self?.fileName!)!)
            let folderExists = (try? folder!.checkResourceIsReachable()) ?? false

            do {
                if !folderExists {
                    try FileManager.default.createDirectory(at: folder!, withIntermediateDirectories: false)
                }

                try FileManager.default.copyItem(at: url, to: filePath)
                self?.videoURL = filePath
                self?.displayChosenVideo()
                ProgressHUD.dismiss()
            } catch {
                print("Debug: something wrong -> \(error)")
            }
        })

    }
}

// MARK: - Search video delegate
extension WritingDiaryViewController: SearchVideoViewControllerDelegate {
    func searchVideoViewController(_ controller: SearchVideosViewController, video: SearchVideoViewModel) {
        print("Debug: did choose video from searchViewController")
        videoURL = video.videoURL
        fileName = Helper.generateVideoFileName()
        onlineVideo = true
        displayChosenVideo()
    }
}

// MARK: - For Edit Mode

extension WritingDiaryViewController {

    func loadDiaryForEditMode(with viewModel: DiaryViewModel) {
        viewModelForEdit = viewModel

        rightBarButton.removeFromSuperview()
        view.addSubview(rightBarEditButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarEditButton)
        rightBarEditButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)

        fileName = viewModel.fileURL
        titleEditor.text = viewModel.title
        textEditor.text = viewModel.content
        textEditor.textColor = K.mainBlack
        videoURL = viewModel.getRelativeFilePath()
        displayChosenVideo()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))

    }

    @objc func didTapEditButton() {
        guard let viewModel = viewModelForEdit else { return }

        guard videoURL != nil else {
            let alert = UIAlertController(title: "Whoops", message: "Please Upload a Video", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }

        // Update video if necessary
        let folderURL = getFolderURL()
        let title = titleEditor.text?.count == 0 ? "Untitled" : titleEditor.text!
        let content = textEditor.text ?? ""
        if fileName != viewModel.fileURL {
            // video from user library
            if !onlineVideo {
                print("Debug: not online video")
                let fileURL = folderURL.appendingPathComponent(fileName!)
                do {
                    let data = try Data(contentsOf: videoURL!)
                    try data.write(to: fileURL)
                    CoreDataManager.shared.updateItem(for: viewModel.diaryID,
                                                      title: title,
                                                      date: datePicker.date,
                                                      content: content,
                                                      fileName: fileName!)
                    self.dismiss(animated: true)
                    self.delegate?.writingDiaryViewControllerDidFinishEditing(self)
                    self.editDelegate?.writingDiaryViewControllerDidFinishEditing(self, title: title, date: datePicker.date, content: content, fileName: fileName!)
                } catch {

                }
            } else {
                // video from Pexels
                print("Debug: begin to download file")
                let onlineFileName = Helper.generateVideoFileName()
                fileName = onlineFileName
                let fileURL = folderURL.appendingPathComponent(onlineFileName)
                ProgressHUD.show("Uploading...")
                APIManager.shared.downloadOnlineVideo(from: videoURL!, fileURL: fileURL) {[weak self] success in
                    guard let self = self else { return }
                    if success {

                        DispatchQueue.main.async {
                            CoreDataManager.shared.updateItem(for: viewModel.diaryID,
                                                              title: title,
                                                              date: self.datePicker.date,
                                                              content: content,
                                                              fileName: self.fileName!)
                            ProgressHUD.dismiss()
                            self.dismiss(animated: true)
                            self.delegate?.writingDiaryViewControllerDidFinishEditing(self)
                            self.editDelegate?.writingDiaryViewControllerDidFinishEditing(self, title: title, date: self.datePicker.date, content: content, fileName: self.fileName!)
                        }
                    }
                }
            }
        } else {
            // Update the Core Data
            print("Debug: didn't change the video")
            CoreDataManager.shared.updateItem(for: viewModel.diaryID,
                                              title: titleEditor.text?.count == 0 ? "Untitled" : titleEditor.text!,
                                              date: datePicker.date,
                                              content: textEditor.text ?? "",
                                              fileName: fileName!)
            self.dismiss(animated: true)
            self.delegate?.writingDiaryViewControllerDidFinishEditing(self)
            self.editDelegate?.writingDiaryViewControllerDidFinishEditing(self, title: title, date: datePicker.date, content: content, fileName: fileName!)
        }

    }

    @objc func didTapCancelButton() {
        self.dismiss(animated: true)
    }

}
