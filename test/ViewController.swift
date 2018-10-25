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
    
    
    @IBOutlet weak var collectionView: UICollectionView!

    
    var data : [MessageModel] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        // For completeness the section insets need to be accommodated
       
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
                GetPlaceCordinates(address: name)
                
            }
            
            
        }
        self.data = self.messagelst.filterDuplicates { $0.sentiment == $1.sentiment  }
        
        self.collectionView.reloadData()
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
//extension ViewController : UICollectionViewDelegateFlowLayout
//{
////    Option 3: Reacting to Rotations
////    In iOS 8, the willRotateToInterfaceOrientation(...) and didRotateFromInterfaceOrientation(...) methods on UIViewController were deprecated in favor of viewWillTransitionToSize(...).
////
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
//    {
//        
//        let size = (data[indexPath.row].sentiment! as NSString).size(withAttributes: nil)
//
//        
//        return size
//    }
//}
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
        cell.configrationCell(data[indexPath.row].sentiment!)
        
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
