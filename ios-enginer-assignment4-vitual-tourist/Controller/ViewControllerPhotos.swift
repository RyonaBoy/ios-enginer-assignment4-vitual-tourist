//
//  ViewControllerPhotos.swift
//  ios-enginer-assignment4-vitual-tourist
//
//  Created by Yu Zhao on 20.06.22.
//

import UIKit

class ViewControllerPhotos: UICollectionViewController {

    var longitude: Double?
    var latitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FlickrClient.searchPhotos(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
