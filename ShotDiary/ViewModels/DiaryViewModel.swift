//
//  DiaryViewModel.swift
//  ShotDiary
//
//  Created by Sen Lin on 4/5/2022.
//

import UIKit
import AVFoundation

class DiaryViewModel{
    let title: String
    let content: String
    let fileURL: String
    let date: Date
    
    init(title: String, content: String, fileURL: String, date: Date){
        self.title = title
        self.content = content
        self.fileURL = fileURL
        self.date = date
    }
    
    func getRelativeFilePath() -> URL{
        let fileManager = FileManager.default
        let documentFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileFolder = documentFolder.appendingPathComponent("userVideos")
        return fileFolder.appendingPathComponent(fileURL)
    }
    
    func getPreviewImage() -> UIImage?{
        let url = getRelativeFilePath()
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let duration = asset.duration
        
        
        do{
            let preViewImage = try imageGenerator.copyCGImage(at: CMTime(seconds: duration.seconds/2, preferredTimescale: duration.timescale), actualTime: nil)
            return UIImage(cgImage: preViewImage)
        }catch{
            print("Debug: cannot generate preview image \(error)")
            return nil
        }
    }
}