//
//  ViewController.swift
//  MyMap
//
//  Created by Jinhee on 2022/07/01.
//

import UIKit
import MapKit
import CoreLocation // 위치 관련된거

class ViewController: UIViewController {

    // 변수에 뷰 추가
    let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .light // 다크모드인지 아닌지
        return map
    }()
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation() // startupdate를 해야 didUpdateLocation메서드가 호출됨
        manager.delegate = self
        return manager
    }()
    
    // 내 위치로 넘어갈 버튼
    lazy var locationButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 위치", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(Mylocation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocationUsagePermission()
        self.mapView.mapType = MKMapType.standard // 기본 지도가 뜸
        self.mapView.showsUserLocation = true // 위치를 보여주겠다
        
        // 뷰 추가
        self.view.addSubview(mapView)
        
        // 제약조건 설정- 순서는 항상 뷰 추가한 후
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        // 버튼 제약조건 설정
        self.view.addSubview(locationButton)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        locationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        locationButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    }
    
    // 권한을 요청함
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            DispatchQueue.main.async {
                self.mapView.setUserTrackingMode(.follow, animated: true) // 내 위치로 넘어감
            }
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            DispatchQueue.main.async { // 비동기로 보냄 그래야 다음 코드로 넘어감
                self.getLocationUsagePermission() // 다시 권한을 요청함
            }
        case .denied:
            print("GPS 권한 요청 거부됨")
            DispatchQueue.main.async {
                self.getLocationUsagePermission()
            }
        default:
            print("GPS: Default")
        }
    }
    
    // 버튼 누르면 내 위치로 돌아가는 함수
    @objc func Mylocation() {
        print("내 위치")
        
        // 내 위치로 돌아가는 코드
        self.mapView.setUserTrackingMode(.follow, animated: true)
    }
}
