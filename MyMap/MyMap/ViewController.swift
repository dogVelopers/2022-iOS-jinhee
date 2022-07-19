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
    
    // GPS 
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation() // startupdate를 해야 didUpdateLocation메서드가 호출됨
        manager.delegate = self
        return manager
    }()
    
    // 핀 생성하는 버튼
    lazy var createMarkerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: "mappin.and.ellipse"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createMarkerAction), for: .touchUpInside)
        return button
    }()
    
    // 팝업창
    let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    // title 입력 textfield
    lazy var titleText: UITextField = {
        let text = UITextField()
        text.frame = CGRect(x: 65, y: 70, width: 200, height: 30)
        text.placeholder = "제목"
        //text.delegate = self
        text.borderStyle = .roundedRect
        text.clearButtonMode = .whileEditing // 텍스트 편집하는 동안에만
        return text
    }()
    
    // subtitle 입력 textfield
    lazy var subtitleText: UITextField = {
        let text2 = UITextField()
        text2.frame = CGRect(x: 65, y: 120, width: 200, height: 30)
        text2.placeholder = "부제목"
        //text2.delegate = self
        text2.borderStyle = .roundedRect
        text2.clearButtonMode = .whileEditing // 텍스트 편집하는 동안에만
        return text2
    }()
    
    // 팝업창 확인 버튼
    lazy var textButton: UIButton = {
        let button3 = UIButton()
        button3.setTitle("확인", for: .normal)
        button3.backgroundColor = .systemBlue
        button3.tintColor = .white
        button3.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return button3
    }()
    
    // 생성하고자하는 위치
    var willCreateLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    // 내 위치로 넘어갈 버튼
    lazy var locationButton: UIButton = {
        let button = UIButton()
//        button.setTitle("내 위치", for: .normal)
//        button.backgroundColor = .systemGray
//        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal) // 버튼 이미지로 바꿈
        button.addTarget(self, action: #selector(Mylocation), for: .touchUpInside)
        return button
    }()
    
    // 위성지도 또는 기본 지도로 바뀌는 버튼
    lazy var mapButton: UIButton = {
        let button2 = UIButton()
        button2.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button2.addTarget(self, action: #selector(mapType), for: .touchUpInside)
        button2.changesSelectionAsPrimaryAction = true // 버튼 토글 상태는 isSelected
        return button2
    }()

    //MARK: - 뷰 디드 로드
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocationUsagePermission()
        self.mapView.mapType = MKMapType.standard // 기본 지도가 뜸
        self.mapView.showsUserLocation = true // 위치를 보여주겠다
        
        // 뷰 추가
        self.view.addSubview(mapView)
        self.view.addSubview(createMarkerButton)
        self.view.addSubview(popupView)
        self.view.addSubview(locationButton)
        self.view.addSubview(mapButton)
        
        // popupview에 넣기
        self.popupView.addSubview(titleText)
        self.popupView.addSubview(subtitleText)
        self.popupView.addSubview(textButton)
        
        // 제약조건 설정- 순서는 항상 뷰 추가한 후
        // mapview 초기화
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        // 마커 생성 버튼 초기화
        createMarkerButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200).isActive = true
        createMarkerButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        // 팝업 뷰 초기화
        popupView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120).isActive = true
        popupView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -120).isActive = true
        popupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        popupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        
        // 팝업창 확인 버튼 제약조건
        textButton.translatesAutoresizingMaskIntoConstraints = false
        textButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        textButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        textButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -150).isActive = true
        textButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 400).isActive = true
        
        
        // 내 위치 버튼 제약조건 설정
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        locationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        locationButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        // 위성지도/기본 지도 버튼 제약조건
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        mapButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        mapButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        mapButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -320).isActive = true
        mapButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 670).isActive = true
        
        addGesture()
        
        // 원하는 위치 표시
        createMarker(title: "학교", subtitle: "성공회대학교", coordinate: CLLocationCoordinate2D(latitude: 37.487744, longitude: 126.825028))
    }
    
    // 권한을 요청함
    func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // 위치 나타내는 함수
    func createMarker(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        let marker = Mark(title: title, subtitle: subtitle, coordinate: coordinate)
        mapView.addAnnotation(marker)
    }
    
    // 제스처 함수
    func addGesture() {
        let touch = UITapGestureRecognizer(target: self, action: #selector(self.didClickMapView(sender:)))
        self.mapView.addGestureRecognizer(touch)
    }
    
}

//MARK: - 오브젝트 함수 모음

extension ViewController {
    // 앱을 클릭하면 실행되는 함수
    @objc func didClickMapView(sender: UITapGestureRecognizer) {
        //popupView 띄우기
        popupView.isHidden.toggle()
        
        let location: CGPoint = sender.location(in: self.mapView)
        willCreateLocation = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
//        let mapLocation: CLLocationCoordinate2D = self.mapView.convert(location, toCoordinateFrom: self.mapView)

        //print("위도: \(mapLocation.latitude), 경도: \(mapLocation.longitude)")
        
        //클릭된 상태에서는 생성되면 안됨
        //createMarker(title: "Test", subtitle: "Test1", coordinate: mapLocation)
    }
    
    @objc func createMarkerAction() {
        // 흰색 뷰 보이게
        print("흰색 뷰 보이게")
        popupView.isHidden.toggle()
    }
    
    // 팝업창 확인 버튼 액션
    @objc func confirmAction() {
        createMarker(title: "\(titleText.text!)", subtitle: "\(subtitleText.text!)", coordinate: willCreateLocation)
        print("위도: \(willCreateLocation.latitude), 경도: \(willCreateLocation.longitude)")
    }
}

//MARK: - GPS 권한 설정
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
    
    // 버튼 누르면 위성지도로, 한 번 더 누르면 기본 지도로 바뀌는 함수
    @objc func mapType() {
        if(mapButton.isSelected) {
            print("위성지도")
            mapView.mapType = MKMapType.satellite
        }
        else {
            print("기본 지도")
            mapView.mapType = MKMapType.standard
        }
    }
}
