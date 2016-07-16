//
//  ViewController.swift
//  Hue App
//
//  Created by Swayam Barik on 7/7/16.
//  Copyright © 2016 Swayam Barik. All rights reserved.
//


import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator
import ToneAnalyzerV3

var defaultCategories: [String] = ["Rap", "Country", "Classic"]

var categories: [String] = []
var lyrics = ""
var angerScore = ""
var disgustScore = 0.0
var fearScore = 0.0
var joyScore = 0.0
var sadnessScore = 0.0

class ViewController: UIViewController{
    
    @IBOutlet weak var songName: UITextField!
    @IBOutlet weak var artistName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
            }
    @IBAction func searchSong(sender: AnyObject) {
        var name = ""
        var artist = ""
        
        if self.songName.text == "" || self.artistName.text == ""
        {
            artist = "drake"
            name = "views"
        }
        else{
            let arrayOne = songName.text!.componentsSeparatedByString(" ")
            name = arrayOne.joinWithSeparator("+")
            
            let arrayTwo = artistName.text!.componentsSeparatedByString(" ")
            artist = arrayTwo.joinWithSeparator("+")
        }
        
        let apiToContact = "http://api.lyricsnmusic.com/songs?api_key=[7f20218fb1ab86aff7aa7f9d25df56]&q=\(artist)%20\(name)"
        
        // This code will call the iTunes top 25 movies endpoint listed above
        Alamofire.request(.GET, apiToContact).validate().responseJSON() { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let songData = JSON(value)
                    //let allMoviesData = moviesData["feed"]["entry"].arrayValue
                    print("---------------------------------")
                    print(songData)
                    lyrics = songData[0]["snippet"].stringValue
                    print("LYRICS: \(lyrics)")
                    
                    var username = "42211623-0b7b-44f2-a65f-7b085f7148e6"
                    var password = "CLiQuxU3MuIj"
                    var endpoint = "https://gateway.watsonplatform.net/tone-analyzer/api/v3/tone?version=2016-05-19&text="
                    
                    var sampleText = lyrics
                    
                    // -------------------------------------------------------------------
                    
                    var authString = username + ":" + password
                    var authData = authString.dataUsingEncoding(NSASCIIStringEncoding)
                    var authValue = "Basic " + authData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                    
                    var toneUrl = endpoint + sampleText.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
                    let url = NSURL(string: toneUrl)
                    
                    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
                    config.HTTPAdditionalHeaders = ["Authorization" : authValue]
                    let session = NSURLSession(configuration: config)
                    
                    var taskIsRunning = true;
                    let task = session.dataTaskWithURL(url!) {
                        (let data, let response, let error) in
                        if let httpResponse = response as? NSHTTPURLResponse {
                            do {
                                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                                
                                // Work with JSON object.
                                print(json)
                                angerScore = json["document_tone"]!!["tone_categories"]!![0]["tones"]!![0]["score"]!!.stringValue
                                print(angerScore)
                            }
                            catch {
                                print("Problem serialising JSON object")
                            }
                        }
                        taskIsRunning = false
                    }
                    
                    task.resume()
                    while (taskIsRunning) {
                        sleep(1)
                    }
                    
    //                let username = "42211623-0b7b-44f2-a65f-7b085f7148e6"
    //                let password = "CLiQuxU3MuIj"
     //               let version = "2016-07-16" // use today's date for the most recent version
    //                let toneAnalyzer = ToneAnalyzer(username: username, password: password, version: version)
                    
     //               let text = lyrics
     //               let failure = { (error: NSError) in print(error) }
     //               toneAnalyzer.getTone(text, failure: failure) { tones in
     //                   print(tones)
                  //  }

                    
                }
            case .Failure(let error):
                
                print(error)
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


//Generes Tab

extension ViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.darkGrayColor()
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        print("Test: ")
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        let maxHue = 65000
        for light in cache!.lights!.values {
            // don't update state of non-reachable lights
            if light.lightState!.reachable == 0 {
                continue
            }
            
            let lightState = PHLightState()
            
            
            //        if light.type.value == DIM_LIGHT.rawValue {
            //        // Lux bulbs just get a random brightness
            //        lightState.brightness = Int(arc4random()) % 254
            //      } else {
            lightState.hue = Int(arc4random()) % maxHue
            lightState.brightness = 254
            lightState.saturation = 254
            //}
            
            // Send lightstate to light
            bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: lightState, completionHandler: { (errors: [AnyObject]!) -> () in
                
                if errors != nil {
                    let message = String(format: NSLocalizedString("Errors %@", comment: ""), errors)
                    NSLog("Response: \(message)")
                }
                //self.randomLightsButton?.enabled = true
            })
            
        }
        
        
        print(defaultCategories[indexPath.row])
        
        
        //        print(currentCell.textLabel!.text)
        
        
        
        categories.append(defaultCategories[indexPath.row])
        
    }
    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cellToDeSelect:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cellToDeSelect.contentView.backgroundColor = UIColor.clearColor()
    }
    
    
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!;
    //
    //        print(currentCell.textLabel!.text)
    //    }
}
extension ViewController: UITableViewDataSource
{
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("Rap")!
            return cell
        }
        else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("Country")!
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("Classic")!
            return cell
        }
//        else if indexPath.row == 3{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Burgers")!
//            return cell
//        }
//        else if indexPath.row == 4{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Cajun")!
//            return cell
//        }
//        else if indexPath.row == 5{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Chinese")!
//            return cell
//        }
//        else if indexPath.row == 6{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Ethiopian")!
//            return cell
//        }
//        else if indexPath.row == 7{
//            let cell = tableView.dequeueReusableCellWithIdentifier("French")!
//            return cell
//        }
//        else if indexPath.row == 8{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Greek")!
//            return cell
//        }
//        else if indexPath.row == 9{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Indian")!
//            return cell
//        }
//        else if indexPath.row == 10{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Italian")!
//            return cell
//        }
//        else if indexPath.row == 11{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Japanese")!
//            return cell
//        }
//        else if indexPath.row == 12{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Korean")!
//            return cell
//        }
//        else if indexPath.row == 13{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Latin American")!
//            return cell
//        }
//        else if indexPath.row == 14{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Mediterranean")!
//            return cell
//        }
//        else if indexPath.row == 15{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Mexican")!
//            return cell
//        }
//        else if indexPath.row == 16{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Middle Eastern")!
//            return cell
//        }
//        else if indexPath.row == 17{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Noodles")!
//            return cell
//        }
//        else if indexPath.row == 18{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Pizza")!
//            return cell
//        }
//        else if indexPath.row == 19{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Sandwiches")!
//            return cell
//        }
//        else if indexPath.row == 20{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Sushi")!
//            return cell
//        }
//        else if indexPath.row == 21{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Greek")!
//            return cell
//        }
//        else if indexPath.row == 22{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Thai")!
//            return cell
//        }
//            
//        else{
//            let cell = tableView.dequeueReusableCellWithIdentifier("Vietnamese")!
//            return cell
//        }
    }
}

