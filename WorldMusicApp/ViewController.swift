//
//  ViewController.swift
//  WorldMusicApp
//
//  Created by Era Iyer on 7/11/16.
//  Copyright © 2016 Era Iyer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!

    var idArray: [String] = []
    var previewArray: [String] = []
    
    override func viewDidLoad() {
        let initialLocation = CLLocation(latitude: 36.7783, longitude: -119.4179)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centerMapOnLocation(initialLocation)

    }
    
    let regionRadius: CLLocationDistance = 7000000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 1.0, regionRadius * 1.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showAddViewController(placemark:CLPlacemark){
        self.performSegueWithIdentifier("add", sender: placemark)
    }
    
    
    
    @IBAction func addPin(sender: UILongPressGestureRecognizer) {
        let location = sender.locationInView(self.mapView)
        
        let locationCoord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoord
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        //convert location coordinates address
        let geoCoder = CLGeocoder()
        let loc = CLLocation(latitude: locationCoord.latitude, longitude: locationCoord.longitude)
        
        geoCoder.reverseGeocodeLocation(loc){
            (placemarks, error) -> Void in
            let placeArray = placemarks as [CLPlacemark]!

            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            if let country = placeMark.addressDictionary?["Country"] as? NSString
            {
                self.titleLabel.text = country as String
            //this prints the list of album titles that correpsond to the location clicked on
                
            var countryWithPlus = "\(country)".stringByReplacingOccurrencesOfString(" ", withString: "+")
          
                
        /*  let apiToContact = "https://api.spotify.com/v1/search?q=music+from+\(countryWithPlus)&type=album"
            Alamofire.request(.GET, apiToContact).validate().responseJSON() { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        var counter = 0
                        for(_, _) in json["albums"]{
                            if let albumTitle = json["albums"]["items"][counter]["name"].string {
                               print(albumTitle)
                                counter += 1
                            }
                        }
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }*/
        //getting the ID number of each album of the country and adding it to an array
        let apiToContact = "https://api.spotify.com/v1/search?q=music+from+\(countryWithPlus)&type=album"
                Alamofire.request(.GET, apiToContact).validate().responseJSON() { response in
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            var counter = 0
                            for(_,_) in json["albums"]{
                                if let albumID = json["albums"]["items"][counter]["id"].string {
                                    var albumLinkWithID = "https://api.spotify.com/v1/albums/\(albumID)/tracks"
                                    self.idArray.append(albumLinkWithID)
                                    counter+=1
                                }
                            }
                        }
                    case .Failure(let error):
                        print(error)
                    }
                }
            }
            
            //goes through the array of album IDs and prints the preview url of each track in each album
            var idCounter =  0
            
            while idCounter < self.idArray.count {
                let apiToContact = self.idArray[idCounter]
                Alamofire.request(.GET, apiToContact).validate().responseJSON() { response in
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            var counter = 0
                            for(_, _) in json["items"]{
                                if let previewUrl = json["items"][counter]["preview_url"].string {
                                    self.previewArray.append(previewUrl)
                                   
                                    counter += 1
                                }
                            }
                            print(self.previewArray)
                        }
                    case .Failure(let error):
                        print(error)
                    }
                }
             idCounter += 1
            }
        }
        
        
//        if let artistName = json["items"][counter]["artists"][0]["name"].string {
//            if let songName = json["items"][counter]["name"].string {
//              self.titleLabel.text = songName as String + " by " + artistName as String
        
        
        
        var urlCounter = 0
        var player = AVPlayer()
        
        while urlCounter < self.previewArray.count {
           let url = previewArray[urlCounter]
           let playerItem = AVPlayerItem( URL: NSURL(string:url)!)
           player = AVPlayer(playerItem:playerItem)
           player.rate = 1.0;
           player.play()
           urlCounter+=1
        }
    }
}
        
        
        
        
        
        
        



  func listAlbumTracks () {
        let apiToContact = "https://api.spotify.com/v1/albums/6akEvsycLGftJxYudPjmqK/tracks"
        Alamofire.request(.GET, apiToContact).validate().responseJSON() { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    var counter = 0
                    for(_, _) in json["items"]{
                        if let artistName = json["items"][counter]["artists"][0]["name"].string {
                            if let songName = json["items"][counter]["name"].string {
                                print(artistName + ", " + songName)
                            }
                        counter += 1
                        }
                    }
                }
            case .Failure(let error):
                print(error)
            }
        }
    }

    
 /*   func listTrackPreview(){
        //you want to change the url to fit all the albums
        let apiToContact = "https://api.spotify.com/v1/albums/6akEvsycLGftJxYudPjmqK/tracks"
        Alamofire.request(.GET, apiToContact).validate().responseJSON() { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    var counter = 0
                    for(_, _) in json["items"]{
                        if let previewUrl = json["items"][counter]["preview_url"].string {
                            print(previewUrl)
                            counter += 1
                        }
                    }
                }
            case .Failure(let error):
                print(error)

            }
        }
}*/

