//
//  DiaryCellViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 5/5/2022.
//

import UIKit
import AVFoundation

protocol DiaryCellViewControllerDelegate: UIViewController {
    func diaryCellViewControllerDidDeleteDiary(_ controller: DiaryCellViewController)
}

class DiaryCellViewController: UIViewController {

    private let viewModel: DiaryViewModel
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    weak var delegate: WritingDiaryViewControllerDelegate?
    weak var deleteDelegate: DiaryCellViewControllerDelegate?
    private var observer: NSObjectProtocol?
    private var fullTextMode = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = . systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = K.grayTextColor
        label.clipsToBounds = true
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .white
        label.clipsToBounds = true
        return label
    }()

    private let fullTextView: UITextView = {
        let textView = UITextView()
        textView.allowsEditingTextAttributes = false
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        return textView
    }()

    private let showFullTextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.mainNavy
        button.setTitle("Full Text", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 10
        return button
    }()

    private let videoModeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.mainNavy
        button.setTitle("Video Mode", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 10
        return button
    }()

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = K.mainNavyBackground
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = K.mainBlack
        addVideoLayer()
        configure()
        tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(didTapActionButton))
        showFullTextButton.addTarget(self, action: #selector(didTapFullTextButton), for: .touchUpInside)
    }

    @objc func didTapActionButton() {
        let actionSheet = UIAlertController(title: "Edit or Delete Your Diary", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: {[weak self] _ in
            self?.presentEditInterface()
        }))

        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in

            guard let self = self else { return }

            let alert = UIAlertController(title: "Confirm", message: "Do you want to delete this diary?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                CoreDataManager.shared.deleteItem(for: self.viewModel.diaryID) { success in
                    if success {
                        self.deleteDelegate?.diaryCellViewControllerDidDeleteDiary(self)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            self.present(alert, animated: true)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }

    func presentEditInterface() {
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

        if !fullTextMode {
            let padding = CGFloat(20)
            let contentWidth = CGFloat(300)
            let titleLabelHeight = CGFloat(50)
            let contentLabelHeight = CGFloat(125)

            titleLabel.frame = CGRect(x: padding, y: view.frame.height-titleLabelHeight*2-contentLabelHeight-padding*4, width: contentWidth, height: titleLabelHeight)
            dateLabel.frame = CGRect(x: padding, y: view.frame.height-titleLabelHeight*2-contentLabelHeight-padding*3, width: contentWidth, height: titleLabelHeight)
            contentLabel.frame = CGRect(x: padding, y: view.frame.height-titleLabelHeight-contentLabelHeight-padding*3, width: contentWidth, height: contentLabelHeight)

            titleLabel.sizeToFit()
            contentLabel.sizeToFit()

            contentLabel.frame.size.height = min(contentLabel.frame.height, contentLabelHeight)
            showFullTextButton.frame = CGRect(x: contentLabel.frame.origin.x,
                                              y: contentLabel.frame.origin.y + contentLabel.frame.height + padding,
                                              width: 125,
                                              height: 45)
        }

    }

    @objc func didTapFullTextButton() {
        view.addSubview(backgroundView)
        view.addSubview(videoModeButton)
        view.addSubview(fullTextView)
        backgroundView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
        fullTextView.frame = CGRect(x: 20, y: view.frame.height-65-150-40, width: 300, height: 150)
        videoModeButton.frame = showFullTextButton.frame
        view.bringSubviewToFront(dateLabel)

        UIView.animate(withDuration: 0.25) {
            self.showFullTextButton.removeFromSuperview()
            self.backgroundView.frame = self.view.bounds

            self.view.bringSubviewToFront(self.titleLabel)

            let padding = CGFloat(20)
            let contentWidth = self.view.frame.width*0.9
            let titleLabelHeight = CGFloat(50)
            let contentLabelHeight = self.view.frame.height-padding*2-titleLabelHeight-185
            let bottom = self.navigationController?.navigationBar.frame.size.height ?? 0

            self.titleLabel.frame = CGRect(x: padding, y: bottom+padding*4, width: contentWidth, height: titleLabelHeight)
            self.dateLabel.frame = CGRect(x: padding, y: bottom+padding*5, width: contentWidth, height: titleLabelHeight)
            self.fullTextView.frame = CGRect(x: padding, y: bottom+titleLabelHeight+padding*5, width: contentWidth, height: contentLabelHeight)

            self.fullTextView.text = self.contentLabel.text

            self.titleLabel.sizeToFit()
            self.fullTextView.sizeToFit()
            self.fullTextView.frame.size.height = min(self.fullTextView.frame.height, contentLabelHeight)
            self.fullTextView.frame.size.width = max(self.fullTextView.frame.width, contentWidth)

            self.contentLabel.removeFromSuperview()

            self.videoModeButton.frame = CGRect(x: self.fullTextView.frame.origin.x,
                                                y: self.fullTextView.frame.origin.y + self.fullTextView.frame.height + padding,
                                                width: 125,
                                                height: 45)

            self.fullTextMode = true
            self.viewDidLayoutSubviews()

        }

        videoModeButton.addTarget(self, action: #selector(didTapVideoModeButton), for: .touchUpInside)

    }

    @objc func didTapVideoModeButton() {
        showFullTextButton.frame = videoModeButton.frame
        videoModeButton.removeFromSuperview()
        fullTextView.removeFromSuperview()
        view.addSubview(contentLabel)
        view.addSubview(showFullTextButton)
        contentLabel.frame = fullTextView.frame

        self.fullTextMode = false
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.removeFromSuperview()
            self.viewDidLayoutSubviews()
        }

    }

    init(viewModel: DiaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addVideoLayer() {
        let fileManager = FileManager.default

        do {
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
        } catch {
            print("Debug: cannot fetch given file")
        }
    }

    private func configure() {
        view.addSubview(titleLabel)
        view.addSubview(contentLabel)
        view.addSubview(showFullTextButton)
        view.addSubview(dateLabel)
        titleLabel.text = viewModel.title
        contentLabel.text = viewModel.content
        dateLabel.text = viewModel.displayDate
    }
}

extension DiaryCellViewController: WritingDiaryViewControllerInEditMode {
    func writingDiaryViewControllerDidFinishEditing(_ controller: WritingDiaryViewController, title: String, date: Date, content: String, fileName: String) {
        titleLabel.text = title
        contentLabel.text = content
        dateLabel.text = Helper.formatDate(date: date)

        let fileURL = DiaryViewModel.getRelativeFilePath(with: fileName)
        player = AVPlayer(url: fileURL)
        playerLayer?.player = player
        player?.play()

        observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                          object: player?.currentItem,
                                                          queue: .main,
                                                          using: {[weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        })
    }

}
