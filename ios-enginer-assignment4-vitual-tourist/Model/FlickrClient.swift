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
        static var keyAPISecret = "21334bb536ce7fc3"
    }
    
    enum Endpoints{
        static let base = "https://www.flickr.com/services/rest/"
        
        case searchPhotos(latitude: String, longitude: String)
        
        var stringValue: String{
            switch self{
            case let .searchPhotos(latitude, longitude):
                return Endpoints.base + "?method=flickr.photos.search&api_key=" + Auth.keyAPI + "&lat=" + latitude + "&lon=" + longitude + "&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    class func taskForPOSTRequest<ResponseType: Decodable, RequestType: Encodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")//no idea what these bullshit does, copy pasted from previous project
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")//no idea what these bullshit does, copy pasted from previous project
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request){data, response, error in
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            print(data)
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
    
    class func searchPhotos(latitude: Double, longitude: Double){
        let jsonBullshit = RequestFlickr(api_key: Auth.keyAPI, lat: latitude, lon: longitude)
        taskForPOSTRequest(url: Endpoints.searchPhotos(latitude: "\(latitude)", longitude: "\(longitude)").url, responseType: ResponseFlickr.self, body: jsonBullshit){ response, error in
            print(response)
            print(error)
        }
    }
    
}
