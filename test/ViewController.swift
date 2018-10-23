//
//  ViewController.swift
//  test
//
//  Created by user147796 on 10/22/18.
//  Copyright © 2018 user147796. All rights reserved.
//

import UIKit
import MKDataDetector
import CoreLocation
class ViewController: UIViewController {

    let dataDetectorService: MKDataDetectorService = MKDataDetectorService()

    override func viewDidLoad() {
        super.viewDidLoad()
     //
    }
    func Getplaces(){
        
        let sentenses = ["Hello from Damascus",
                         "Fire reported in the main market in Mogadishu",
                         "Funtimes in Ibiza",
                         "Lovely shisa in Cairo, Egypt",
                         "Blimey! Protests in Tahrir , can't go home",
                         "Stuck in traffic in Nairobi",
                         "Kathmandu is beatiful",
                         "Lovely football at the Bernabau, Madrid, Spain",
                         "I hate my government, Athens",
                         "Life is full of surprises in Istanbul"]
        
        for text in sentenses{
            let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
            tagger.string = text
            let range = NSRange(location:0, length: text.utf16.count)
            let options: NSLinguisticTagger.Options = []
            let tags: [NSLinguisticTag] = [.placeName]
            var name = ""
            tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
                if let tag = tag, tags.contains(tag) {
                    
                    if name == ""{
                        name =  (text as NSString).substring(with: tokenRange)
                    }
                    else{
                        name = name + ", " +  (text as NSString).substring(with: tokenRange)
                    }
                    
                    
                }
            }
            print("\(name)")
        }
        
    }
}
