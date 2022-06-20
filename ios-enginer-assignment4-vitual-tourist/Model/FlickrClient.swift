//
//  FlickrClient.swift
//  ios-enginer-assignment4-vitual-tourist
//
//  Created by Yu Zhao on 20.06.22.
//

import Foundation

class FlickrClient{
    
    struct Auth{
        static var keyAPI = "a111b6e212d82b695000f68aa53b88fc"
        static var keyAPISecret = "41f29ade89c03826"
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
        _ = URLSession.shared.dataTask(with: request){data, response, error in
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
    }
    
    class func searchPhotos(latitude: Double, longitude: Double){
        let jsonBullshit = RequestFlickr(api_key: Auth.keyAPI, lat: latitude, lon: longitude)
        taskForPOSTRequest(url: Endpoints.searchPhotos(latitude: "\(latitude)", longitude: "\(longitude)").url, responseType: ResponseFlickr.self, body: jsonBullshit){ response, error in
            print(response)
        }
    }
    
}
