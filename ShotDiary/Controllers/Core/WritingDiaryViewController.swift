//
//  WritingDiaryViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 2/5/2022.
//

import UIKit

class WritingDiaryViewController: UIViewController {
    
//    private let titleEditor: UITextView = {
//        let textField = UITextView()
//        textField.text = "Title..."
//        textField.textColor = .secondaryLabel
//        textField.backgroundColor = .quaternaryLabel
//        textField.layer.cornerRadius = 5
//        textField.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        textField.font = .systemFont(ofSize: 16, weight: .semibold)
//        textField.automaticallyAdjustsScrollIndicatorInsets = false
//        textField.textContainer.maximumNumberOfLines = 1
//        return textField
//    }()
    
    private let titleEditor: UITextField = {
        let titleEditor = UITextField()
        titleEditor.placeholder = "Untitled"
        titleEditor.font = .systemFont(ofSize: 30, weight: .semibold)
//        titleEditor.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
//        titleEditor.leftViewMode = .always
//        titleEditor.backgroundColor = .quaternaryLabel
        titleEditor.layer.cornerRadius = 5
        return titleEditor
    }()
    
    private let textEditor: UITextView = {
        let textField = UITextView()
        textField.text = "How are you today?"
        textField.textColor = .secondaryLabel
        //textField.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textField.font = .systemFont(ofSize: 16, weight: .regular)
//        textField.layer.borderWidth = 3
//        textField.layer.borderColor = UIColor.quaternaryLabel.cgColor
//        textField.layer.cornerRadius = 5
        return textField
    }()
    
    private let addVideoButton: UIButton = {
        let button = UIButton()
//        button.setTitle("Choose Photo", for: .normal)
//        button.setTitleColor(UIColor.label, for: .normal)
        
        button.setImage(UIImage(systemName: "plus.square"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.tintColor = .tertiaryLabel
        //button.backgroundColor = .systemRed
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(textEditor)
        view.addSubview(titleEditor)
        view.addSubview(addVideoButton)
        
        //titleEditor.delegate = self
        textEditor.delegate = self
        //titleEditor.pasteDelegate = self
        textEditor.pasteDelegate = self
        
        title = "Write a diary"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapPostButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapPostButton))
        
        addVideoButton.addTarget(self, action: #selector(didTapAddVideoButton), for: .touchUpInside)
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
        bottomLine.backgroundColor = UIColor.quaternaryLabel.cgColor
        titleEditor.borderStyle = .none
        titleEditor.layer.addSublayer(bottomLine)
        
        
    }
    
    // MARK: - Button functions
    @objc func didTapPostButton(){
        print("Debug: did tap post button")
    }
    
    @objc func didTapAddVideoButton(){
        let actionsheet = UIAlertController(title: "Choose a Video", message: "Choose a video from your library or take a video", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Video Library", style: .default, handler: { _ in
            
        }))
        actionsheet.addAction(UIAlertAction(title: "Take a Video", style: .default, handler: { _ in
            
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionsheet, animated: true)
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
