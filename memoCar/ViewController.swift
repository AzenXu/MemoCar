//
//  ViewController.swift
//  memoCar
//
//  Created by XuAzen on 2016/10/8.
//  Copyright © 2016年 azen. All rights reserved.
//

import UIKit
import Then
import SnapKit

class ViewController: UIViewController {
    lazy var mapView: MAMapView = {return MAMapView()}()
    
}

extension ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _setup()
        _appendPinAnnotation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.mapType = MAMapType.standard
    }
    
    func _setup() {
        mapView = mapView.then {
            view.addSubview($0)
            $0.snp.remakeConstraints({ (make) in
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(0)
                make.bottom.equalTo(0)
            })
            $0.delegate = self
            $0.showsUserLocation = true //  需要配置好Info.plist才有效 - 显示用户定位
            $0.setUserTrackingMode(MAUserTrackingMode.follow, animated: true)   //  用户居中显示，地图跟着用户移动
            $0.isRotateCameraEnabled = false    //  禁用倾斜手势
        }
    }
    //  添加大头针 - 附近的车，可自定义图片
    func _appendPinAnnotation() {
        mapView.addAnnotation(MAPointAnnotation().then {
            $0.coordinate = CLLocationCoordinate2DMake(39.989, 116.480)
            $0.title = "国际竹藤大厦"
            $0.subtitle = "你猜猜这是哪"
        })
    }
}

let pointReuseID: String = "pointReuseID"
extension ViewController: MAMapViewDelegate {
    //  用户移动后的回调
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if updatingLocation {
            print(userLocation.coordinate.latitude)
            print(userLocation.coordinate.longitude)
        }
    }

    /** 自定义定位点(以及大头针)样式 -> 这个需要好好玩玩 http://lbs.amap.com/api/ios-sdk/guide/draw-on-map/draw-marker/
     *  术语：
     *  1. AnnotationView大头针
     *  2. Annotation解释
     *  3. CallOut点击后弹出来的气泡
     */
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
//        let customAnno = MemoLocation(coordinate: nil)
        if annotation is MAPointAnnotation {    //  如果是大头针
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseID) as? MAPinAnnotationView
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseID)
            }
            annotationView?.canShowCallout = true
            annotationView?.animatesDrop = true
            annotationView?.isDraggable = true
            annotationView?.pinColor = MAPinAnnotationColor.green
            return annotationView
        } else {    //  当前定位点
            let annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: "test").then {
                $0.image = UIImage(named: "test")
                $0.canShowCallout = true
                $0.isDraggable = true
            }
            return annotationView
        }
    }
    
    /** 自定义精度圈样式
     */
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        return MAOverlayRenderer(overlay: overlay).then({
            $0.glPointCount = 1
        })
    }
}

class MemoLocation: NSObject, MAAnnotation {
    internal private(set) var coordinate: CLLocationCoordinate2D
    
    private override init() {
        coordinate = CLLocationCoordinate2D(latitude: 40, longitude: 116.48)
    }
    
    convenience init(coordinate: CLLocationCoordinate2D?) {
        self.init()
        guard let coordinate = coordinate else { return }
        self.coordinate = coordinate
    }
    
}

