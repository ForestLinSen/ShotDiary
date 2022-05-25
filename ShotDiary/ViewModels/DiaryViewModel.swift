//
//  DiaryViewModel.swift
//  ShotDiary
//
//  Created by Sen Lin on 4/5/2022.
//

import UIKit
import AVFoundation

class DiaryViewModel {
    let title: String
    let content: String
    let fileURL: String
    let date: Date
    let diaryID: UUID

    let year: Int
    let month: Int
    let day: Int
    let group: String
    let displayDate: String
    let displayCollectionCellDate: String
    let displayCollectionDate: String

    init(title: String, content: String, fileURL: String, date: Date, diaryID: UUID) {
        self.title = title
        self.content = content
        self.fileURL = fileURL
        self.date = date
        self.diaryID = diaryID

        self.displayDate = Helper.formatDate(date: date)
        self.displayCollectionDate = Helper.formateCollectionDate(date: date)
        self.displayCollectionCellDate = Helper.formateCollectionCellDate(date: date)

        let dateValue = Calendar.current.dateComponents([.year, .month, .day], from: self.date)
        self.year = dateValue.year!
        self.month = dateValue.month!
        self.day = dateValue.day!

        self.group = "\(year)_\(month)"

    }

    func getRelativeFilePath() -> URL {
        let fileManager = FileManager.default
        let documentFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileFolder = documentFolder.appendingPathComponent("userVideos")
        return fileFolder.appendingPathComponent(fileURL)
    }

    static func getRelativeFilePath(with fileName: String) -> URL {
        let fileManager = FileManager.default
        let documentFolder = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileFolder = documentFolder.appendingPathComponent("userVideos")
        return fileFolder.appendingPathComponent(fileName)
    }

    func getPreviewImage() -> UIImage? {
        let url = getRelativeFilePath()
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let duration = asset.duration

        do {
            let preViewImage = try imageGenerator.copyCGImage(at: CMTime(seconds: duration.seconds*0.25, preferredTimescale: duration.timescale), actualTime: nil)
            return UIImage(cgImage: preViewImage)
        } catch {
            print("Debug: cannot generate preview image \(error)")
            return nil
        }
    }
}
