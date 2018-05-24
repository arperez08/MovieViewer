//
//  ReserveSeatsViewController.swift
//  MovieViewer_Swift
//
//  Created by Arnel Perez on 19/05/2018.
//  Copyright © 2018 Arnel Perez. All rights reserved.
//

import UIKit

class ReserveSeatsViewController: UIViewController, ZSeatSelectorDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var seatsMappingView: UIView!
    @IBOutlet var pickerViewDate: UIPickerView!
    @IBOutlet var pickerViewCinema: UIPickerView!
    @IBOutlet var pickerViewTime: UIPickerView!
    @IBOutlet var lblSelectedSeats: UILabel!
    @IBOutlet var lblTotalPrice: UILabel!
    
    @IBOutlet var dateBtn: UIButton!
    @IBOutlet var cinemaBtn: UIButton!
    @IBOutlet var timeBtn: UIButton!
    
    
    @IBAction func btnDate(_ sender: Any) {
        self.pickerViewDate.isHidden = false;
        self.pickerViewCinema.isHidden = true;
        self.pickerViewTime.isHidden = true;
    }
    
    @IBAction func btnCinema(_ sender: Any) {
        self.pickerViewDate.isHidden = true;
        self.pickerViewCinema.isHidden = false;
        self.pickerViewTime.isHidden = true;
    }
    
    @IBAction func btnTime(_ sender: Any) {
        self.pickerViewDate.isHidden = true;
        self.pickerViewCinema.isHidden = true;
        self.pickerViewTime.isHidden = false;
    }
    
    var dates: NSArray?
    var cinemas: NSArray?
    var times: NSArray?
    var dateID: String?
    var timeID: String?
    var cinemasID: String?
    var timesArray: NSArray?
    var cinemasArray: NSArray?
    var price: String?
    var dictSeatData: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.callWebserviceURLSechdule()
        callWebserviceURLSeats()
        
        self.pickerViewDate.reloadAllComponents()
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
                            guard let jsonValue = try JSONSerialization.jsonObject(with: usableData, options: [])
                                as? [String: Any] else {
                                    print("error trying to convert data to JSON")
                                    return
                            }
                            self.dates = (jsonValue["dates"] as? NSArray)
                            self.cinemas = (jsonValue["cinemas"] as? NSArray)
                            self.times = (jsonValue["times"] as? NSArray)
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
                            guard let jsonValue = try JSONSerialization.jsonObject(with: usableData, options: [])
                                as? [String: Any] else {
                                    print("error trying to convert data to JSON")
                                    return
                            }
                            self.dictSeatData = jsonValue as NSDictionary
                            //self.mapSeats(dictData: jsonValue as NSDictionary)
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
    
    func refreshPickerTime() {
        for items in times! {
            var dictTimes: NSDictionary?
            dictTimes = items as? NSDictionary
            let parent = (dictTimes!["parent"] as? String)
            if parent == cinemasID {
                timesArray = (dictTimes!["times"] as? NSArray)
            }
        }
        self.pickerViewTime.reloadAllComponents()
    }
    
    func refreshPickerCinema() {
        for items in cinemas! {
            var dictCinemas: NSDictionary?
            dictCinemas = items as? NSDictionary
            let parent = (dictCinemas!["parent"] as? String)
            if parent == dateID {
                cinemasArray = (dictCinemas!["cinemas"] as? NSArray)
            }
        }
        self.pickerViewCinema.reloadAllComponents()
    }
    
 
    func mapSeats(dictData:NSDictionary) {
        let numberFormatter = NumberFormatter()
        let number = numberFormatter.number(from: price!)
        let numberFloatValue = number?.floatValue
        
        let seats = ZSeatSelector()
        seats.frame = CGRect(x: 0, y: 0, width: self.seatsMappingView.frame.size.width, height: self.seatsMappingView.frame.size.height)
        seats.setSeatSize(CGSize(width: (seatsMappingView.frame.size.width / 40), height:  (seatsMappingView.frame.size.width / 40)))
        seats.setAvailableImage(UIImage(named: "available")!,
                                    andUnavailableImage:    UIImage(named: "unavailable")!,
                                    andDisabledImage:       UIImage(named: "unavailable")!,
                                    andSelectedImage:       UIImage(named: "selected")!)
        seats.layout_type = "Normal"
        seats.setMap (dictData, price: numberFloatValue!)
        seats.selected_seat_limit  = 10
        seats.seatSelectorDelegate = self
        seats.maximumZoomScale         = 5.0
        seats.minimumZoomScale         = 0.05
        self.seatsMappingView.addSubview(seats)
    }
    
    func seatSelected(_ seat: ZSeat) {
        //print("Seat at row: \(seat.row) and column: \(seat.column)\n")
    }
    
    func getSelectedSeats(_ seats: NSMutableArray) {
        lblSelectedSeats.text = ""
        var total:Float = 0.0;

        var strSelectedSeats:String = " "
        for i in 0..<seats.count {
            let seat:ZSeat  = seats.object(at: i) as! ZSeat
            total += seat.seatPrice
            strSelectedSeats =  strSelectedSeats + "  " + seat.seatName
        }
        let myNumber = NSNumber(value: Float(total))
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        
        lblTotalPrice.text = "Php " + formatter.string(from: myNumber)!
        lblSelectedSeats.text = strSelectedSeats
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == pickerViewDate) {
            if ((dates) != nil) {
                return (dates!.count)
            }
        }
        if (pickerView == pickerViewCinema) {
            if ((cinemasArray) != nil) {
                return (self.cinemasArray!.count)
            }
        }
        if (pickerView == pickerViewTime) {
            if ((timesArray) != nil) {
                return (timesArray!.count)
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == pickerViewDate) {
            if ((dates) != nil){
                var dictDates: NSDictionary?
                dictDates = (dates?[row] as! NSDictionary)
                let label = (dictDates!["label"] as? String)
                return label
            }
        }
        if (pickerView == pickerViewCinema) {
            if ((cinemasArray) != nil){
                var dictCinemas: NSDictionary?
                dictCinemas = (cinemasArray?[row] as! NSDictionary)
                let label = (dictCinemas!["label"] as? String)
                return label
            }
        }
        
        if (pickerView == pickerViewTime) {
            if ((timesArray) != nil){
                var dictTime: NSDictionary?
                dictTime = (timesArray?[row] as! NSDictionary)
                let label = (dictTime!["label"] as? String)
                return label
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        if (pickerView == pickerViewDate) {
            if ((dates) != nil){
                var dictDates: NSDictionary?
                dictDates = (dates?[row] as! NSDictionary)
                dateID = (dictDates!["id"] as? String)
                let label = (dictDates!["label"] as? String)
                
                self.dateBtn.setTitle(label, for: .normal)
                self.cinemaBtn.setTitle("--- Cinema ---", for: .normal)
                self.timeBtn.setTitle("--- Time ---", for: .normal)
                
                self.pickerViewDate.isHidden = true;
                self.pickerViewCinema.isHidden = true;
                self.pickerViewTime.isHidden = true;
                
                //reset all items
                cinemasArray = nil
                timesArray = nil
                cinemasID = nil
                self.refreshPickerCinema()
                self.refreshPickerTime()
            }
        }
        if (pickerView == pickerViewCinema) {
            if ((cinemasArray) != nil){
                var dictCinemas: NSDictionary?
                dictCinemas = (cinemasArray?[row] as! NSDictionary)
                cinemasID = (dictCinemas!["id"] as? String)
                let label = (dictCinemas!["label"] as? String)
                
                self.cinemaBtn.setTitle(label, for: .normal)
                self.timeBtn.setTitle("--- Time ---", for: .normal)
                
                self.pickerViewDate.isHidden = true;
                self.pickerViewCinema.isHidden = true;
                self.pickerViewTime.isHidden = true;
                timesArray = nil
                self.refreshPickerTime()
            }
        }
        if (pickerView == pickerViewTime) {
            if ((timesArray) != nil){
                var dictTimes: NSDictionary?
                dictTimes = (timesArray?[row] as! NSDictionary)
                timeID = (dictTimes!["id"] as? String)
                price = (dictTimes!["price"] as? String)
                let label = (dictTimes!["label"] as? String)
                self.timeBtn.setTitle(label, for: .normal)
                
                self.pickerViewDate.isHidden = true;
                self.pickerViewCinema.isHidden = true;
                self.pickerViewTime.isHidden = true;
                
                lblTotalPrice.text = "Php 0.00"
                lblSelectedSeats.text = ""
                
                //self.callWebserviceURLSeats()
                self.mapSeats(dictData: self.dictSeatData!)
            }
        }
    }
}
