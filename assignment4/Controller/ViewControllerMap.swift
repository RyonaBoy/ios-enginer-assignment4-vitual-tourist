//
//  ViewControllerMap.swift
//  assignment4
//
//  Created by Yu Zhao on 18.06.22.
//

import UIKit
import MapKit
import CoreData

class ViewControllerMap: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var map: MKMapView!
    var dataController: DataController!
    //var fetchedResultsController: NSFetchedResultsController<MKPointAnnotation>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLongPressGestureShit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setupLongPressGestureShit(){
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        lpgr.minimumPressDuration = 1
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.map.addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state != UIGestureRecognizer.State.ended{
            return
        }else if gestureRecognizer.state != UIGestureRecognizer.State.began{
            let touchPoint = gestureRecognizer.location(in: self.map)
            let touchMapCoordinate = self.map.convert(touchPoint, toCoordinateFrom: map)
            let annotation = MKPointAnnotation()
            annotation.subtitle = "You long pressed here"
            annotation.coordinate = touchMapCoordinate
            self.map.addAnnotation(annotation)
        }
    }
}

