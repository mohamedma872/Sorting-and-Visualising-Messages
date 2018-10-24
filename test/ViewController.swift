//
//  ViewController.swift
//  test
//
//  Created by user147796 on 10/22/18.
//  Copyright © 2018 user147796. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class ViewController: UIViewController {
    //  MARK: Properties
    ///    Displays the rappers in a map.
    @IBOutlet private weak var mapView: MKMapView!
    var Feedobj : Feed?
    var Messagemodel : MessageModel?
    var messagelst : [MessageModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        //get data
        let sampleDataAddress = "https://spreadsheets.google.com/feeds/list/0Ai2EnLApq68edEVRNU0xdW9QX1BqQXhHRl9sWDNfQXc/od6/public/basic?alt=json"
        let url = URL(string: sampleDataAddress)!
        let jsonData = try! Data(contentsOf: url)
        //decode data
        let jsonDecoder = JSONDecoder()
        let obj = try? jsonDecoder.decode(Spreadsheet.self, from: jsonData)
        Feedobj = obj?.feed
        //extract places from messages
        Getplaces(entry: (Feedobj?.entry)!)
        
    }
    func Getplaces(entry : [Entry]){
        
        
        
        for text in entry{
            //init new object from Message Model
            Messagemodel = MessageModel()
            //obtain model class
            var Messageobj : String = text.content.t
            Messagemodel?.message = Messageobj.slice(from: "message:", to: ", sentiment")
            Messagemodel?.messageid = Int (Messageobj.slice(from: "messageid: ", to: ", ")!)
            if let range = Messageobj.range(of: "sentiment: ") {
                Messagemodel?.sentiment = Messageobj[range.upperBound...].trimmingCharacters(in: .whitespaces)
            }
            Messageobj = Messageobj.replacingOccurrences(of: "messageid", with: "\"messageid", options: .literal, range: nil)
            Messageobj = Messageobj.replacingOccurrences(of: "message", with: "\"message\"", options: .literal, range: nil)
            Messageobj = Messageobj.replacingOccurrences(of: "sentiment", with: "\"sentiment\"", options: .literal, range: nil)
            //search for place name
            let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
            tagger.string = Messagemodel?.message
            let range = NSRange(location:0, length: (Messagemodel?.message!.utf16.count)!)
            let options: NSLinguisticTagger.Options = []
            let tags: [NSLinguisticTag] = [.placeName]
            var name = ""
            tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
                if let tag = tag, tags.contains(tag) {
                    
                    if name == ""{
                        name =  ((Messagemodel?.message!)! as NSString).substring(with: tokenRange)
                    }
                    else{
                        name = name + ", " +  ((Messagemodel?.message!)! as NSString).substring(with: tokenRange)
                    }
                    
                    
                }
                
                
            }
            print("\(name)")
            //nmake sure that i get all correct places and not get empty space
            if(name != "")
            {
                //add message model to list
                Messagemodel?.PlaceName = name
                GetPlaceCordinates(address: name)
                
            }
            
            
        }
        
    }
    func GetPlaceCordinates(address : String)
    {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            self.Messagemodel?.Lat = location.coordinate.latitude
            self.Messagemodel?.lon = location.coordinate.longitude
            self.messagelst.append(self.Messagemodel!)
            
            // Use your location
        }
    }
    
}
extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
extension ViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if let annotation = annotation as? ClusterAnnotation {
//            let index = segmentedControl.selectedSegmentIndex
//            let identifier = "Cluster\(index)"
//            let annotationView: MKAnnotationView
//            if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
//                annotationView = existingView
//            } else {
//                let selection = Selection(rawValue: index)!
//                annotationView = selection.annotationView(annotation: annotation, reuseIdentifier: identifier)
//            }
//            annotationView.annotation = annotation
//            return annotationView
//        } else if let annotation = annotation as? MeAnnotation {
//            let identifier = "Me"
//            let annotationView: MKAnnotationView
//            if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
//                annotationView = existingView
//            } else {
//                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView.image = .me
//            }
//            annotationView.annotation = annotation
//            return annotationView
//        } else {
//            let identifier = "Pin"
//            let annotationView: MKPinAnnotationView
//            if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
//                annotationView = existingView
//            } else {
//                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView.pinTintColor = .green
//            }
//            annotationView.annotation = annotation
//            return annotationView
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        manager.reload(mapView: mapView) { finished in
//            print(finished)
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        guard let annotation = view.annotation else { return }
//
//        if let cluster = annotation as? ClusterAnnotation {
//            var zoomRect = MKMapRect.null
//            for annotation in cluster.annotations {
//                let annotationPoint = MKMapPoint(annotation.coordinate)
//                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
//                if zoomRect.isNull {
//                    zoomRect = pointRect
//                } else {
//                    zoomRect = zoomRect.union(pointRect)
//                }
//            }
//            mapView.setVisibleMapRect(zoomRect, animated: true)
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
//        views.forEach { $0.alpha = 0 }
//        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
//            views.forEach { $0.alpha = 1 }
//        }, completion: nil)
//}
}

extension ViewController {
//    enum Selection: Int {
//        case count, imageCount, image
//        
//        func annotationView(annotation: MKAnnotation?, reuseIdentifier: String?) -> MKAnnotationView {
//            switch self {
//            case .count:
//                let annotationView = CountClusterAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//                annotationView.countLabel.backgroundColor = .green
//                return annotationView
//            case .imageCount:
//                let annotationView = ImageCountClusterAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//                annotationView.countLabel.textColor = .green
//                annotationView.image = .pin2
//                return annotationView
//            case .image:
//                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
//                annotationView.image = .pin
//                return annotationView
//            }
//        }
//    }
}
