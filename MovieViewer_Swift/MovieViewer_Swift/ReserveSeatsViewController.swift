//
//  ReserveSeatsViewController.swift
//  MovieViewer_Swift
//
//  Created by Arnel Perez on 19/05/2018.
//  Copyright © 2018 Arnel Perez. All rights reserved.
//

import UIKit

class ReserveSeatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.callWebserviceURLSechdule()
        self.callWebserviceURLSeats()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callWebserviceURLSechdule() {
        let urlString = URL(string: "http://ec2-52-76-75-52.ap-southeast-1.compute.amazonaws.com/schedule.json")
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
    
    func callWebserviceURLSeats() {
        let urlString = URL(string: "http://ec2-52-76-75-52.ap-southeast-1.compute.amazonaws.com/seatmap.json")
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
