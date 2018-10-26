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
import JGProgressHUD

class ViewController: UIViewController {
    //  MARK: Properties
    ///    Displays the rappers in a map.
    @IBOutlet private weak var mapView: MKMapView!
    var Feedobj : Feed?
    var Messagemodel : MessageModel?
    var messagelst : [MessageModel] = []
    
    
    @IBOutlet weak var collectionView: UICollectionView!

     let hud = JGProgressHUD(style: .dark)
    var data : [MessageModel] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        // For completeness the section insets need to be accommodated
       
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
       
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
            if(self.Messagemodel!.sentiment == "Neutral")
            {
                self.Messagemodel!.customimage = "map_normal"
            }else if (self.Messagemodel!.sentiment == "Negative")
            {
                self.Messagemodel!.customimage = "map_sad"
            }else if (self.Messagemodel!.sentiment == "Positive")
                
            {
                self.Messagemodel!.customimage = "map_smile"
            }
            self.messagelst.append(self.Messagemodel!)
            
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
                GetPlaceCordinates(Messagemodell: Messagemodel!)
                
            }else
            {
                
                //not found place
                 Messagemodel?.PlaceName = "not found place"
            }
            
            
            
            
        }
        //filter dublicates in grouping
        self.data = self.messagelst.filterDuplicates { $0.sentiment == $1.sentiment  }
        self.collectionView.reloadData()
        //dismiss the loader
         hud.dismiss(afterDelay: 2.0)
    }
    func GetPlaceCordinates(Messagemodell : MessageModel)
    {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(Messagemodell.PlaceName!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                     print("error in gecoding")
                    return
            }
             Messagemodell.coordinate.latitude = location.coordinate.latitude
            Messagemodell.coordinate.longitude = location.coordinate.longitude
             print("\(location.coordinate.latitude)")
           
            Messagemodell.title = Messagemodell.PlaceName
            Messagemodell.subtitle = Messagemodell.message
            
            //update list
            self.messagelst.first(where: {$0.messageid == Messagemodell.messageid})?.coordinate.latitude = location.coordinate.latitude
            self.messagelst.first(where: {$0.messageid == Messagemodell.messageid})?.coordinate.longitude = location.coordinate.longitude
            self.messagelst.first(where: {$0.messageid == Messagemodell.messageid})?.PlaceName = Messagemodell.PlaceName
            self.messagelst.first(where: {$0.messageid == Messagemodell.messageid})?.title = Messagemodell.PlaceName
             self.messagelst.first(where: {$0.messageid == Messagemodell.messageid})?.subtitle = Messagemodell.message
            self.mapView.addAnnotation(Messagemodell)
            self.fitMapViewToAnnotaionList(annotations: self.messagelst)
            // Use your location
        }
    }
    func fitMapViewToAnnotaionList(annotations: [MKPointAnnotation]) -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect:MKMapRect = MKMapRect.null
        
        for index in 0..<annotations.count {
            let annotation = annotations[index]
            let aPoint:MKMapPoint = MKMapPoint(annotation.coordinate)
            let rect:MKMapRect = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
            
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
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
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? MessageModel else { return nil }
        // 3
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! MessageModel
        annotationView?.image = UIImage(named: customPointAnnotation.customimage!)
        
        return annotationView
       
    }
}

extension ViewController : UICollectionViewDataSource {
    //1
   
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
     func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
       
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewcustomecellCollectionViewCell", for: indexPath) as! collectionviewcustomecellCollectionViewCell
        cell.configrationCell(data[indexPath.row].sentiment!,customimg: data[indexPath.row].customimage!)

        return cell;
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! collectionviewcustomecellCollectionViewCell
        cell.sentimentBtn.backgroundColor = UIColor(named: "SelectedItem")
        cell.sentimentBtn.layer.borderColor = UIColor(named: "SelectedItem")?.cgColor
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell =  collectionView.cellForItem(at: indexPath)
        {
            let customeCell =  cell as! collectionviewcustomecellCollectionViewCell
            customeCell.sentimentBtn.backgroundColor = UIColor(named: "ProjectColor")
            customeCell.sentimentBtn.layer.borderColor = UIColor(named: "ProjectColor")?.cgColor
            
            
        }
        
    }
    
}
extension Array {
    
    func filterDuplicates( includeElement: (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element]{
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
}
