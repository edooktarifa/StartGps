import GoogleMaps

class GoogleMapsViewController: UIViewController,GMSMapViewDelegate{
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var sliderBar: UISlider!
    
    var vm: MapPathViewModel!
    var iTemp:Int = 0
    var marker = GMSMarker()
    var timer = Timer()
    
    var resumeTapped = false
    
    let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 26.82177, longitude: 79.5755417, zoom: 4.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = MapPathViewModel(mapView: mapView, marker: marker, speed: speedLabel)
        pageSetUp()
    }
    
    func pageSetUp()  {
        mapView.delegate = self
        mapView.camera = camera
        
        vm.jsonDataRead { success, error in
            if success == true {
                vm.drawPathOnMap()
            } else {
                self.isFailReadJson(msg: error ?? "")
            }
        }
    }
    
    func isFailReadJson(msg : String)  {
        let alert = UIAlertController(title: "Map Alert", message: msg, preferredStyle: .alert)
        let actionOK : UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOK)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonHandlerPlay(_ sender: Any) {
        runTimer()
    }
    
    func runTimer(){
        self.resumeTapped = false
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (_) in
            self.playCar()
        })
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        if self.resumeTapped == false {
            timer.invalidate()
            self.resumeTapped = true
        } else {
            runTimer()
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton){
        stopTimer()
        runTimer()
    }
    
    func stopTimer(){
        timer.invalidate()
        iTemp = 0
    }
    
}

extension GoogleMapsViewController{
    
    //marker move on map view
    func playCar()
    {
        if iTemp <= (vm.arrayMapPath.count - 1 )
        {
            let iTempMapPath = vm.arrayMapPath[iTemp]
            
            DispatchQueue.main.async {
                [weak self] in
                guard let self = self else { return }
                self.vm.moveCameraAndCar(iTempMapPath: iTempMapPath)
            }
            
            if iTemp == (vm.arrayMapPath.count - 1)
            {
                stopTimer()
            }
            iTemp += 1
        }
    }
    
    @IBAction func sliderViewChange(_ sender: Any){
        self.resumeTapped = false
        stopTimer()
        let filterData = vm.arrayMapPath.filter { $0.id == "\(Int(sliderBar.value))" }
        
        guard let iTempMapPath = filterData.first else { return }
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            self.vm.moveCameraAndCar(iTempMapPath: iTempMapPath)
        }
        
    }
//
//    func moveCameraAndCar(iTempMapPath: MapPath){
//        let loc : CLLocation = CLLocation(latitude: iTempMapPath.lat!, longitude: iTempMapPath.lon!)
//
//        vm.updateMapFrame(newLocation: loc, zoom: self.mapView.camera.zoom)
//        marker.position = CLLocationCoordinate2DMake(iTempMapPath.lat!, iTempMapPath.lon!)
//
//        marker.rotation = iTempMapPath.angle!
//
//        marker.icon = UIImage(named: "newCars")
//        marker.map = mapView
//        speedLabel.text = "Kecepatan: \(iTempMapPath.speed ?? "")"
//    }
}
