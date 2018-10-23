//
//  ViewController.swift
//  test
//
//  Created by user147796 on 10/22/18.
//  Copyright © 2018 user147796. All rights reserved.
//

import UIKit
import CoreLocation
class ViewController: UIViewController {
    
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
