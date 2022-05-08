//
//  APIManager.swift
//  ShotDiary
//
//  Created by Sen Lin on 7/5/2022.
//

import Foundation

final class APIManager{
    private init(){}
    static let shared = APIManager()
    let token = "563492ad6f9170000100000138010ac153c84f60875468bd45698f56"
    let baseURL = "https://api.pexels.com/videos"
    
    func getPopularVideo(completion: @escaping (Result<VideosResponse, Error>) -> Void){

        guard let url = URL(string: baseURL+"/popular") else { return }
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else{
                print("Debug: cannot fetch data from pexels")
                return
            }
            
            do{
                let jsonData = try JSONDecoder().decode(VideosResponse.self, from: data)
                completion(.success(jsonData))
                
            }catch{
                completion(.failure(error))
                print("Debug: cannot decode data from pexels \(error)")
            }
            
        }.resume()
    }
}
