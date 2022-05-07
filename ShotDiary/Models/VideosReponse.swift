//
//  VideosReponse.swift
//  ShotDiary
//
//  Created by Sen Lin on 7/5/2022.
//

import Foundation

struct VideosResponse: Codable{
    let url: String
    let videos: [PexelsVideo]
}

struct PexelsVideo: Codable{
    let id: Int
    let url: String
    let image: String
    let video_files: [VideoFiles]
}

struct VideoFiles: Codable{
    let id: Int
    let quality: String
    let link: String
    let file_type: String // video/mp4
}
