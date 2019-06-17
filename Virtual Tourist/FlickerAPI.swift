//
//  FlickerAPI.swift
//  Virtual Tourist
//
//  Created by Amal Alqadhibi on 16/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import Foundation
class FlickerAPI {
    
    static let APIKey = "e265c1efc860c7b2f21069d9d6c6261c"
    struct Prameters {
        static let format = "json"
        static let perPage = 9
        
    }
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        static let fetchImages = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg"
        
          case fetchCityImages(Double, Double,Int)

        
        var stringValue: String {
            switch self {
            case .fetchCityImages(let lat, let lon , let page):
                return Endpoints.base + "&api_key=\(APIKey)" + "&lat=\(lat)&lon=\(lon)&page=\(page)&per_page=\(Prameters.perPage)&format=\(Prameters.format)"

            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    class func getStudentLocations(latitude: Double, longitude: Double,page:Int,completion: @escaping (Bool,[URL]?,Error?)->()){
        var request = URLRequest(url:FlickerAPI.Endpoints.fetchCityImages(latitude, longitude , page).url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(false,nil, error)
                return
            }
            //TODO: Check witch type of error it is.
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200  && statusCode < 30 else {
//                completion(false,nil, error)
//                return
//            }
            guard let data = data else {
                completion(false ,nil, nil)
                return
            }
            print(String(data: data, encoding: .utf8)!)
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                completion(false,nil, error)
                return
            }
            guard let stat = result["stat"] as? String, stat == "ok" else {
                completion(false, nil,error)
                return
            }
            
            guard let photosDictionary = result["photos"] as? [String:Any] else {
                completion(false, nil, error)
                return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [[String:Any]] else {
                completion(false, nil, error)
                return
            }
            
            let photosURLs = photosArray.compactMap { photoDictionary -> URL? in
                guard let url = photoDictionary["url_m"] as? String else { return nil}
                return URL(string: url)
            }
             completion(true, photosURLs, nil)
            }.resume()
        
    }

    
}
