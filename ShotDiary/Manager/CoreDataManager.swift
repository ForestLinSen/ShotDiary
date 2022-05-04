//
//  CoreDataManager.swift
//  ShotDiary
//
//  Created by Sen Lin on 4/5/2022.
//

import Foundation
import UIKit

class CoreDataManager{
    private init(){}
    
    static let shared = CoreDataManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getAllItems(completion: @escaping ([DiaryViewModel]?) -> Void){
        do{
            let items = try context.fetch(Diary.fetchRequest())
            
            let viewModels = items.compactMap { diary in
                return DiaryViewModel(title: diary.title!, content: diary.content!, fileURL: diary.fileURL!, date: diary.date!)
            }
            
            print("Debug: fetch item -> \(viewModels)")
            completion(viewModels)
        }catch{
            print("Debug: an error occured when fetching Diary data")
            completion(nil)
        }
    }
    
    func createItems(viewModel: DiaryViewModel, completion: @escaping (Bool) -> Void){
        let newItem = Diary(context: context)
        newItem.title = viewModel.title
        newItem.content = viewModel.content
        newItem.fileURL = viewModel.fileURL
        newItem.date = viewModel.date
        
        do{
            try context.save()
            completion(true)
        }catch{
            print("Debug: failed to save the new item")
            completion(false)
        }
    }
    
    func deleteItem(){}
    
    func updateItem(){}
}
