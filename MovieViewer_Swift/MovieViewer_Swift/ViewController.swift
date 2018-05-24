//
//  ViewController.swift
//  MovieViewer_Swift
//
//  Created by Arnel Perez on 19/05/2018.
//  Copyright © 2018 Arnel Perez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblGenre: UILabel!
    @IBOutlet var lblAdvisory: UILabel!
    @IBOutlet var lblDuration: UILabel!
    @IBOutlet var lblRelease: UILabel!
    @IBOutlet var lblSypnosis: UILabel!
    @IBOutlet var imgPoster: UIImageView!
    @IBOutlet var imgPoster2: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Movie Viewer"
        // Do any additional setup after loading the view, typically from a nib.
        self.callWebserviceURL();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func minutesToHoursMinutes (minutes : Int) -> (String) {
        //return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let intMinutes = minutes % 60
        let intHours = minutes / 60
        let strResult = String(intHours) + "hrs " + String(intMinutes) + "mins"
        return strResult
    }
    
    
    func callWebserviceURL() {
        let urlString = URL(string: "http://ec2-52-76-75-52.ap-southeast-1.compute.amazonaws.com/movie.json")
        if let url = urlString {
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                else {
                    if let usableData = data {
                        do {
                            guard let todo = try JSONSerialization.jsonObject(with: usableData, options: [])
                                as? [String: Any] else {
                                    print("error trying to convert data to JSON")
                                    return
                            }

                            let posterURL = (todo["poster"] as! String)
                            let poster_landscape = (todo["poster_landscape"] as! String)
                            
                            if let url = URL(string: posterURL) {
                                self.downloadImagePoster(url: url)
                            }
                            
                            if let url = URL(string: poster_landscape) {
                                self.downloadImagePosterLandscape(url: url)
                            }
                            
                            self.lblName.text = (todo["canonical_title"] as! String)
                            self.lblGenre.text = (todo["genre"] as! String)
                            self.lblAdvisory.text = (todo["advisory_rating"] as! String)
                            self.lblSypnosis.text = (todo["synopsis"] as! String)
                            
                            let strRuntime = (todo["runtime_mins"] as! String)
                            let intRunTime = (strRuntime as NSString).integerValue
                            self.lblDuration.text = self.minutesToHoursMinutes(minutes: intRunTime)
                            
                            let dateFormatterGet = DateFormatter()
                            dateFormatterGet.dateFormat = "yyyy-MM-dd"
                            let dateFormatterPrint = DateFormatter()
                            dateFormatterPrint.dateFormat = "MMM dd, yyyy"
                            
                            if let date = dateFormatterGet.date(from: (todo["release_date"] as! String)){
                                self.lblRelease.text = (dateFormatterPrint.string(from: date))
                            }
                            else {
                                self.lblRelease.text = (todo["release_date"] as! String)
                            }
                        }
                        catch  {
                            print("error trying to convert data to JSON")
                            return
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func downloadImagePoster(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                self.imgPoster2.image = UIImage(data: data)
            }
        }
    }
    func downloadImagePosterLandscape(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                self.imgPoster.image = UIImage(data: data)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}



