//
//  SonuclarVC.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 19.01.2024.
//

import UIKit
import MapKit
import CoreLocation

class SonuclarVC: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var adressLabel: UILabel!
   
    @IBOutlet weak var pozisyonLabel: UILabel!
    @IBOutlet weak var sonucLabel: UILabel!
    
    @IBOutlet weak var tanimLabel: UILabel!
    
    @IBOutlet weak var isyeriLabel: UILabel!
    
    var isyeriad : String?
    var pozisyon : String?
    var adres : String?
    var durum : String?
    var tanim : String?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if durum == "" {
            sonucLabel.text = "Başvurunuz Henüz Sonuçlandırılmadı"
        }else{
            sonucLabel.text = durum
        }
        isyeriLabel.text = isyeriad
        pozisyonLabel.text = pozisyon
        adressLabel.text = adres
        tanimLabel.text = tanim
        
       
               
              
        
    }
    
   
    

    
}
