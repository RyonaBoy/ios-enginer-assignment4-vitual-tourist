//
//  FlickrClient.swift
//  ios-enginer-assignment4-vitual-tourist
//
//  Created by Yu Zhao on 20.06.22.
//

import Foundation

class FlickrClient{
    
    struct Auth{
        static var keyAPI = "e18b1c5f268a1357f6a083cccf572d95"
        static var keyAPISecret = "21334bb536ce7fc3"//wtf is this needed for?
    }
    
    enum Endpoints{
        static let base = "https://www.flickr.com/services/rest/"
        
        case searchPhotos(latitude: String, longitude: String, page: String)
        
        var stringValue: String{
            switch self{
            case let .searchPhotos(latitude, longitude, page):
                return Endpoints.base + "?method=flickr.photos.search&api_key=" + Auth.keyAPI + "&lat=" + latitude + "&lon=" + longitude + "&per_page=20&page=" + page + "&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    class func taskForPOSTRequest<ResponseType: Decodable, RequestType: Encodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")//no idea what this line is, nothing explained by Udacity as usual, copy pasted from previous project
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")//no idea what this line is, nothing explained by Udacity as usual, copy pasted from previous project
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request){data, response, error in
            print(String(data: data!, encoding: .utf8))
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do{
                let responseObjectJSON = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObjectJSON, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func downloadPictures(latitude: Double, longitude: Double, pages: Int, completion: @escaping (ResponseFlickr?, Error?) -> Void){
        let requestBodyJson = RequestFlickr(api_key: Auth.keyAPI, lat: latitude, lon: longitude)
        let randomPage = Int.random(in: 1...pages)
        print("random page \(randomPage)")
        taskForPOSTRequest(url: Endpoints.searchPhotos(latitude: "\(latitude)", longitude: "\(longitude)", page: "\(randomPage)").url, responseType: ResponseFlickr.self, body: requestBodyJson){ responseObjectJSON, error in
            if let responseObjectJSON = responseObjectJSON {
                completion(responseObjectJSON, nil)
            }else{
                completion(nil, error)
            }
        }
    }
}
