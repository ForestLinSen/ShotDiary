//
//  DiarySearchResultViewController.swift
//  ShotDiary
//
//  Created by Sen Lin on 16/5/2022.
//

import UIKit

class DiarySearchResultViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        //tableView.isHidden = true
        return tableView
    }()
    
    var diaryList = [DiaryViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.register(ClassicDiaryTableViewCell.self, forCellReuseIdentifier: ClassicDiaryTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func search(content: String){
        let results = CoreDataManager.shared.searchItem(with: content)
        let viewModels = results.compactMap { diary in
            return DiaryViewModel(title: diary.title ?? "", content: diary.content ?? "", fileURL: diary.fileURL ?? "", date: diary.date ?? Date(), diaryID: diary.diaryID ?? UUID())
        }
        
        DispatchQueue.main.async {[weak self] in
            self?.diaryList = viewModels
            self?.tableView.isHidden = false
            self?.tableView.reloadData()
        }
    }
    
    func clearResult(){
        DispatchQueue.main.async {[weak self] in
            self?.diaryList = []
            self?.tableView.reloadData()
        }
    }
}

extension DiarySearchResultViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ClassicDiaryTableViewCell.identifier, for: indexPath) as? ClassicDiaryTableViewCell else{
            return UITableViewCell()
        }
        
        let viewModel = diaryList[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
