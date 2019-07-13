//
//  MapViewController.swift
//  RAMAX_2
//
//  Created by Филипп on 10.07.2019.
//  Copyright © 2019 Филипп. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var openMap: OpenWeatherMap = OpenWeatherMap()
    var arrWeatherFarther: [OpenWeatherMapParser] = []
    var arrWeatherCloser: [OpenWeatherMapParser] = []
    var arrCoordFarther: [CoordStruct] = []
    var arrCoordCloser: [CoordStruct] = []
    let spanLavelZoom: Double = 35.0
    let timeUpdate: Double = (30.0 * 60.0)
    let timeIntervalUpdate: Double = 5.0 * 60
    var timerFarther: Timer?
    var timerCloser: Timer?
    let spanLoadZood: Double = 2.0 * 1.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let coord = Coordinates()
        self.arrCoordFarther = coord.getArrCoordinates(lat: 31.3, lon: 31.3)
        self.arrCoordCloser = coord.getArrCoordinates(lat: 7.3, lon: 7.3)
        startLocation()
        createTimers()
    }
    
    
    func startLocation(){
        let location = CLLocationCoordinate2DMake(55.720910, 37.650819)
        let span = MKCoordinateSpan(latitudeDelta: 130, longitudeDelta: 130)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        
        if annotation is MKUserLocation{
            return nil
        }else{
            var image: UIImage?
            var text: String?
            var arrWeather: [OpenWeatherMapParser] = []
            
            if mapView.region.span.longitudeDelta > self.spanLavelZoom{
                arrWeather = self.arrWeatherFarther
            }
            else{
                arrWeather = self.arrWeatherCloser
            }
            for el in arrWeather{
                if el.lon == lon && el.lat == lat{
                    image = el.icon
                    text = String(format: "%.1f", arguments: [el.temp]) + "°C"
                    break
                }
            }
            
            let annotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
            annotation.addSubview(createCustomAnnView(text: text, image: image))
            annotation.frame.size = CGSize(width: 50, height: 70)
            annotation.backgroundColor = UIColor.white
            annotation.layer.masksToBounds = true
            annotation.layer.borderWidth = 0.2
            annotation.layer.cornerRadius = 4.0
            annotation.alpha = 1
            return annotation
        }
    }
    
    func createCustomAnnView(text: String?, image: UIImage?) -> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 70))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.image = image
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: 50, height: 20))
        label.text = text
        label.textAlignment = .center
        label.font = label.font.withSize(10)
        view.addSubview(imageView)
        view.addSubview(label)
        return view
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isFarther(span: mapView.region.span.longitudeDelta){
            self.showPins(arrCoord: self.arrCoordFarther)
            self.removeArr(arrCoord: self.arrCoordCloser)
        }
        else{
            self.showPins(arrCoord: self.arrCoordCloser)
            self.removeArr(arrCoord: self.arrCoordFarther)
        }
    }

    func isFarther(span: Double) -> Bool{
        if self.map.region.span.longitudeDelta > spanLavelZoom{
            return true
        }
        else{
            return false
        }
    }
    
    func addAnnotation(latitude: Double, longitude: Double){
        var arrWeather: [OpenWeatherMapParser]?
        let isFather: Bool = isFarther(span: self.map.region.span.longitudeDelta)
        if isFather{
            arrWeather = self.arrWeatherFarther
        }
        else{
            arrWeather = self.arrWeatherCloser
        }
        for el in arrWeather!{
            if el.lat == latitude && el.lon == longitude{
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                DispatchQueue.main.async {
                    self.map.addAnnotation(annotation)
                }
                return
            }
        }
        openMap.getOpenWeatherMapParser(lat: latitude, lon: longitude) { (data) in
            if data == nil{
                return
            }
            if isFather{
                self.arrWeatherFarther.append(data!)
            }else{
                self.arrWeatherCloser.append(data!)
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            DispatchQueue.main.async {
                self.map.addAnnotation(annotation)
            }
        }
        

    }
    
    func showPins(arrCoord: [CoordStruct]){
        let mapView = self.map!
        let spanLat = mapView.region.span.latitudeDelta
        let lat = mapView.centerCoordinate.latitude
        for el in arrCoord{
            let left = lat - spanLat / self.spanLoadZood
            let right = lat + spanLat / self.spanLoadZood
            addPinsToMap(lat: el.lat, lon: el.lon, left: left, right: right)
        }
    }
    
    func addPinsToMap(lat: Double, lon: Double, left: Double, right: Double){
        if isInRegion(lat: lat, lon: lon, left: left, right: right){
            if !isShowedPin(lat: lat, lon: lon){
                self.addAnnotation(latitude: lat, longitude: lon)
            }
        }
    }
    
    func showRemovedPin(coord: CoordStruct){
        let mapView = self.map!
        let spanLat = mapView.region.span.latitudeDelta
        let lat = mapView.centerCoordinate.latitude
        let left = lat - spanLat / self.spanLoadZood
        let right = lat + spanLat / self.spanLoadZood
        if isInRegion(lat: coord.lat, lon: coord.lon, left: left, right: right){
            self.addAnnotation(latitude: coord.lat, longitude: coord.lon)
        }
        
    }
    
    func isInRegion(lat: Double, lon: Double, left: Double, right: Double) -> Bool{
        let spanLon = self.map.region.span.longitudeDelta
        let latIs: Bool = lat > (left) && lat < (right)
        let lonIs: Bool = lon > (self.map.centerCoordinate.longitude - spanLon / self.spanLoadZood) && lon < (self.map.centerCoordinate.longitude + spanLon / self.spanLoadZood)
        if latIs && lonIs{
            return true
        }
        else{
            return false
        }
    }
    
    func removeArr(arrCoord: [CoordStruct]){
        for el in arrCoord{
            if isShowedPin(lat: el.lat, lon: el.lon){
                removeAnn(lat: el.lat, lon: el.lon)
            }
        }
    }
    
    func isShowedPin(lat: Double, lon: Double) -> Bool{
        for an in self.map.annotations{
            if an.coordinate.latitude == lat && an.coordinate.longitude == lon{
                return true
            }
        }
        return false
    }
    
    func removeAnn(lat: Double, lon: Double){
        for an in self.map.annotations{
            if an.coordinate.latitude == lat && an.coordinate.longitude == lon{
                DispatchQueue.main.async {
                    self.map.removeAnnotation(an)
                }
                break
            }
        }
    }

    @objc func updateFartherData(){
        let timeNow = Date().timeIntervalSince1970
        if self.arrWeatherFarther.count == 0{
            return
        }
        let queue = DispatchQueue.init(label: "upload farther")
        for i in 0...self.arrWeatherFarther.count - 1{
            queue.asyncAfter(deadline: .now() + Double(i)) {
                if timeNow - self.arrWeatherFarther[i].time > Double(self.timeUpdate){
                    let lat = self.arrWeatherFarther[i].lat
                    let lon = self.arrWeatherFarther[i].lon
                    self.openMap.getOpenWeatherMapParser(lat: lat, lon: lon) { (data) in
                        if data != nil{
                            self.arrWeatherFarther[i] = data!
                            if self.isFarther(span: self.map.region.span.longitudeDelta){
                                if self.isShowedPin(lat: lat, lon: lon){
                                    DispatchQueue.main.async {
                                        self.removeAnn(lat: lat, lon: lon)
                                        self.showRemovedPin(coord: CoordStruct(x: lat, y: lon))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func updateCloserData(){
        let timeNow = Date().timeIntervalSince1970
        if self.arrWeatherCloser.count == 0{
            return
        }
        let queue = DispatchQueue.init(label: "upload Closer")
        for i in 0...self.arrWeatherCloser.count - 1{
            queue.asyncAfter(deadline: .now() + Double(i)) {
                if timeNow - self.arrWeatherCloser[i].time > self.timeUpdate{
                    let n = i
                    let lat = self.arrWeatherCloser[n].lat
                    let lon = self.arrWeatherCloser[n].lon
                    self.openMap.getOpenWeatherMapParser(lat: lat, lon: lon) { (data) in
                        if data != nil{
                            self.arrWeatherCloser[n] = data!
                            if !self.isFarther(span: self.map.region.span.longitudeDelta){
                                if self.isShowedPin(lat: lat, lon: lon){
                                    DispatchQueue.main.async {
                                        self.removeAnn(lat: lat, lon: lon)
                                        self.showRemovedPin(coord: CoordStruct(x: lat, y: lon))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createTimers(){
        
        if self.timerFarther == nil{
            self.timerFarther = Timer.scheduledTimer(timeInterval: self.timeIntervalUpdate, target: self, selector: #selector(updateFartherData), userInfo: nil, repeats: true)
            self.timerFarther?.tolerance = 0.1
        }
        let _ = Timer.scheduledTimer(timeInterval: Double(self.arrCoordFarther.count) + 5.0, target: self, selector: #selector(startCloserTimer), userInfo: nil, repeats: false)
        
    }
    @objc func startCloserTimer(){
        if self.timerCloser == nil{
            self.timerCloser = Timer.scheduledTimer(timeInterval: self.timeIntervalUpdate, target: self, selector: #selector(updateCloserData), userInfo: nil, repeats: true)
            self.timerCloser?.tolerance = 0.1
        }
    }
}
