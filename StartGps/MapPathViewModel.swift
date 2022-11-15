//
//  MapPathViewModel.swift
//  StartGps
//
//  Created by Phincon on 14/11/22.
//

import Foundation
import GoogleMaps

class MapPathViewModel {
    
    var arrayMapPath : [MapPath] = []
    
    var mapView: GMSMapView?
    var marker: GMSMarker?
    var speed: UILabel?
    
    init(mapView: GMSMapView, marker: GMSMarker, speed: UILabel){
        self.mapView = mapView
        self.marker = marker
        self.speed = speed
    }
    
    deinit {
        self.mapView = nil
        self.marker = nil
        self.speed = nil
    }
    
    func moveCameraAndCar(iTempMapPath: MapPath){
        let loc : CLLocation = CLLocation(latitude: iTempMapPath.lat!, longitude: iTempMapPath.lon!)
        
        updateMapFrame(newLocation: loc, zoom: self.mapView?.camera.zoom ?? 0.0)
        marker?.position = CLLocationCoordinate2DMake(iTempMapPath.lat!, iTempMapPath.lon!)
        
        marker?.rotation = iTempMapPath.angle!
        
        marker?.icon = UIImage(named: "newCars")
        marker?.map = mapView
        speed?.text = "Kecepatan: \(iTempMapPath.speed ?? "")"
    }
    
    func drawPathOnMap()  {
        let path = GMSMutablePath()
        let marker = GMSMarker()
        
        let inialLat:Double = arrayMapPath[0].lat!
        let inialLong:Double = arrayMapPath[0].lon!
        
        for mapPath in arrayMapPath
        {
            path.add(CLLocationCoordinate2DMake(mapPath.lat!, mapPath.lon!))
        }
        //set poly line on mapview
        let rectangle = GMSPolyline(path: path)
        rectangle.strokeWidth = 5.0
        marker.map = mapView
        rectangle.map = mapView
        
        //Zoom map with path area
        let loc : CLLocation = CLLocation(latitude: inialLat, longitude: inialLong)
        updateMapFrame(newLocation: loc, zoom: 12.0)
    }
    
    func updateMapFrame(newLocation: CLLocation, zoom: Float) {
        let camera = GMSCameraPosition.camera(withTarget: newLocation.coordinate, zoom: zoom)
        DispatchQueue.main.async {
            self.mapView?.animate(to: camera)
        }
    }
    
    //Json File data get
    func jsonDataRead(completion: (Bool, String?) -> ()) {
        do {
            if let file = Bundle.main.url(forResource: "LocationData", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    parseJson(json: object)
                    completion(true, nil)
                } else {
                    print("JSON is invalid")
                    completion(false, "JSON is invalid")
                }
            } else {
                print("no file")
                completion(false, "No File found")
            }
        } catch {
            print(error.localizedDescription)
            completion(false, error.localizedDescription)
        }
    }
    
    //Pars json from array
    func parseJson(json : [String: Any])  {
        let pathArray = json["Locations"] as! NSArray
        for data in pathArray
        {
            let dic = data as! NSDictionary
            guard let lat = dic.value(forKey: "lat") as? String, let lon:String = dic.value(forKey: "long") as? String, let angle:String = dic.value(forKey: "angle") as? String, let speed: String = dic.value(forKey: "speed") as? String, let id: String = dic.value(forKey: "id") as? String else {
                return
            }
            
            arrayMapPath.append(MapPath(lat: Double(lat), lon: Double(lon), angle: Double(angle), speed: speed, id: id))
        }
    }
    
}
