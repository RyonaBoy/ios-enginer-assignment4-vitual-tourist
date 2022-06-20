//
//  ViewControllerMap.swift
//  assignment4
//
//  Created by Yu Zhao on 18.06.22.
//

import UIKit
import MapKit
import CoreData

class ViewControllerMap: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var map: MKMapView!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        setupFetchedResultsControllerShit()
        setupLongPressGestureShit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsControllerShit(){
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do{//fetch all pins from previous sessions and show on map
            try fetchedResultsController.performFetch()
            if let fetchedObjects = fetchedResultsController.fetchedObjects{
                var annotations = [MKPointAnnotation]()
                for pin in fetchedObjects{
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
                    annotations.append(annotation)
                }
                self.map.addAnnotations(annotations)
            }
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    
    fileprivate func setupLongPressGestureShit(){
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
            //put pin on map
            let annotation = MKPointAnnotation()
            annotation.subtitle = "You long pressed here"
            annotation.coordinate = touchMapCoordinate
            self.map.addAnnotation(annotation)
            //put pin on disc
            let pin = Pin(context: dataController.persistentContainer.viewContext)
            pin.latitude = Double(touchMapCoordinate.latitude)
            pin.longitude = Double(touchMapCoordinate.longitude)
            try? dataController.persistentContainer.viewContext.save()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("pin press")
        
    }
}

