//
//  BasvuruVc.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 14.01.2024.
//

import UIKit
import Firebase
import SDWebImage

class BasvuruVc: UIViewController {

    @IBOutlet weak var maasLabel: UILabel!
    @IBOutlet weak var tanimLabel: UILabel!
    @IBOutlet weak var adresLabel: UILabel!
    @IBOutlet weak var pozisyonLabel: UILabel!
    @IBOutlet weak var isyeriLabel: UILabel!
    @IBOutlet weak var fotoImageView: UIImageView!
    @IBOutlet weak var yanhaklarLabel: UILabel!
    @IBOutlet weak var calismaTuruLabel: UILabel!
    
    var ilanPozisyon: String?
    var ilanAdres: String?
    var ilanIsyeriAdi: String?
    var ilanIsyeriFotografiURL: String?
    var ilaniMaas : String?
    var ilanTanim : String?
    var ilanYol : Bool?
    var ilanYemek : Bool?
    var ilanPrim : Bool?
    var ilanId : String?
    
    var ad : String?
    var soyad : String?
    var telefon : String?
    var egitim : String?
    var cinsiyet : String?
    var askerlik : String?
    var ehliyet : String?
    var eposta : String?
    var tarih : String?
    var fotograf : String?
    var pozisyon : String?
    var id : String?
    var calisma : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let yol = ilanYol! ? "Yol " : ""
        let yemek = ilanYemek! ? "Yemek " : ""
        let pirim = ilanPrim! ? "Pirim " : ""
        yanhaklarLabel.text = "\(yol) \(yemek) \(pirim)"
        maasLabel.text = ilaniMaas
        tanimLabel.text = ilanTanim
        adresLabel.text = ilanAdres
        pozisyonLabel.text = ilanPozisyon
        isyeriLabel.text = ilanIsyeriAdi
        calismaTuruLabel.text = calisma
        if let imageURL = ilanIsyeriFotografiURL, let url = URL(string: imageURL) {
            fotoImageView.sd_setImage(with: url)
        }
        
        if let user = Auth.auth().currentUser {
                  
                  getKullaniciBilgileriFromFirestore(userID: user.uid)
              }
    }
    

    @IBAction func basvurButon(_ sender: Any) {
        
        
        guard let userUID = Auth.auth().currentUser?.uid else {
           
            makeAlert(titleInput: "Hata!", messageInput: "Oturum açmış bir kullanıcı bulunamadı.")
            return
        }
        
        let db = Firestore.firestore()
        var firestoreReference : DocumentReference? = nil
        
        
        
        let ilanData: [String: Any] = [
            "kulaniciEposta":eposta!,
            "kullaniciAdi": ad!,
            "kulaniciSoyadi": soyad!,
            "telefonno": telefon!,
            "dogumtarihi": tarih!,
            "pozisyon": pozisyon!,
            "cinsiyet": cinsiyet!,
            "egitim": egitim!,
            "askerlik": askerlik!,
            "ehliyet": ehliyet!,
            "fotoUrl": fotograf!,
            "ilanPozisyon":ilanPozisyon!,
            "ilanTabim": ilanTanim!,
            "ilanId":ilanId!,
            "KulaniciId":id!,
            "isyeriAdi": ilanIsyeriAdi!,
            "isyeriAdresi": ilanAdres!,
            "calisanId":userUID,
            "durum": ""
        ]
        
        
        firestoreReference = db.collection("Basvurular").addDocument(data: ilanData, completion: { (error) in
           
            if let error = error {
                self.makeAlert(titleInput: "Hata!", messageInput: error.localizedDescription)
            } else {
                self.makeAlert(titleInput: "Basarılı", messageInput: "Başvurunuz Gönderildi")
                
                
            }
        })
        
      
        
        
    }
    
    
    func getKullaniciBilgileriFromFirestore(userID: String) {
           let firestoreDatabase = Firestore.firestore()
           let kullaniciRef = firestoreDatabase.collection("KullaniciCalisan").document(userID)

           kullaniciRef.getDocument { (document, error) in
               if let document = document, document.exists {
                   
                   self.ad = document["kullaniciAdi"] as? String ?? ""
                   self.soyad = document["kulaniciSoyadi"] as? String ?? ""
                  
                   self.telefon = document["telefonno"] as? String ?? ""
                   
                  
                   self.tarih = document["dogumtarihi"] as? String ?? ""
                   self.pozisyon = document["gorev"] as? String ?? ""
                   self.cinsiyet = document["cinsiyet"] as? String ?? ""
                   self.askerlik = document["askerlik"] as? String ?? ""
                   self.egitim = document["egitim"] as? String ?? ""
                   self.ehliyet = document["ehliyet"] as? String ?? ""
                   self.eposta = document["kulaniciEposta"] as? String ?? ""
                  
                   if let imageUrl = document["imageCalisan"] as? String {
                       
                       self.fotograf = imageUrl
                   }
               } else {
                   print("Kullanıcı belirtilen ID ile bulunamadı: \(userID)")
               }
           }
       }
    
    func makeAlert(titleInput: String, messageInput: String) {
            let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }

}
