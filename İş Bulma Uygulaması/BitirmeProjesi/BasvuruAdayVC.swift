//
//  BasvuruAdayVC.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 19.01.2024.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

class BasvuruAdayVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var isimLabel: UILabel!
    
    @IBOutlet weak var tecrubeTabelView: UITableView!
    @IBOutlet weak var tanimLabel: UILabel!
    @IBOutlet weak var askerlikLabel: UILabel!
    @IBOutlet weak var cinsiyetLabel: UILabel!
    @IBOutlet weak var ehliyetLabel: UILabel!
    @IBOutlet weak var tarihLabel: UILabel!
    @IBOutlet weak var egitimLabel: UILabel!
    @IBOutlet weak var telefonLabel: UILabel!
    @IBOutlet weak var ilanPozisyonLabel: UILabel!
    @IBOutlet weak var kulaniciPozisyonLabel: UILabel!
    @IBOutlet weak var epostaLabel: UILabel!
    @IBOutlet weak var fotoImageView: UIImageView!
    
    
    var PozisyonArray = [String]()
    var isyeriAdArray = [String]()
    var baslangicArray = [String]()
    var bitisArray = [String]()
    var userEmailArray = [String]()
    
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
    var ilanpozisyon : String?
    var tanim : String?
    var id : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Ad = ad!
        let Soyad = soyad!
        isimLabel.text = "\(Ad) \(Soyad)"
        telefonLabel.text = telefon
        epostaLabel.text = eposta
        egitimLabel.text = egitim
        askerlikLabel.text = askerlik
        ehliyetLabel.text = ehliyet
        cinsiyetLabel.text = cinsiyet
        tanimLabel.text = tanim
        kulaniciPozisyonLabel.text = pozisyon
        ilanPozisyonLabel.text = ilanpozisyon
        tarihLabel.text = tarih
        
        
        if let imageURL = fotograf, let url = URL(string: imageURL) {
            fotoImageView.sd_setImage(with: url)
        }
        

        tecrubeTabelView.dataSource = self
        tecrubeTabelView.delegate = self
        
        getTecrubeBilgileri()
        
    }
    

    
    func getTecrubeBilgileri() {
        
       
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Tecrubeler").whereField("postedBy", isEqualTo: eposta as Any).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let documents = snapshot?.documents, !documents.isEmpty {
                    
                    self.userEmailArray.removeAll(keepingCapacity: false)
                    self.baslangicArray.removeAll(keepingCapacity: false)
                    self.bitisArray.removeAll(keepingCapacity: false)
                    
                    self.isyeriAdArray.removeAll(keepingCapacity: false)
                    self.PozisyonArray.removeAll(keepingCapacity: false)
                   
                    
                    for document in documents {
                        let documentID = document.documentID
                        
                       
                       
                        if let Pozisyon = document.get("pozisyon") as? String {
                            self.PozisyonArray.append(Pozisyon)
                        }
                        if let postedBy = document.get("postedBy") as? String {
                            self.userEmailArray.append(postedBy)
                        }
                        if let isyeriAdi = document.get("isyeriAdi") as? String {
                            self.isyeriAdArray.append(isyeriAdi)
                        }
                        if let Baslangic = document.get("baslangicTarihi") as? String {
                            self.baslangicArray.append(Baslangic)
                        }
                        if let Bitis = document.get("bitisTarihi") as? String {
                            self.bitisArray.append(Bitis)
                        }
                    
                    }
                    self.tecrubeTabelView.reloadData()
                } else {
                    print("Belge bulunamadı veya boş.")
                }
            }
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PozisyonArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tecrubeTabelView.dequeueReusableCell(withIdentifier: "tecrubelerCell", for: indexPath) as! AdayTecrubeCell
               
        cell.pozisyonLabel.text = PozisyonArray[indexPath.row]
        cell.baslangicTarihLabel.text = baslangicArray[indexPath.row]
        cell.bitisTarihLabel.text = bitisArray[indexPath.row]
        cell.isyeriLabel.text = isyeriAdArray[indexPath.row]
        
               return cell
    }
    
    
    @IBAction func kabulButon(_ sender: Any) {
        
        let firestoreDatabase = Firestore.firestore()
            let basvuruID = id

            let yeniDurum = "Başvurunuz Kabul Edildi"

        firestoreDatabase.collection("Basvurular").document(basvuruID!).updateData([
                "durum": yeniDurum
            ]) { error in
                if let error = error {
                    print("Durum güncellenirken hata oluştu: \(error.localizedDescription)")
                } else {
                    self.makeAlert(titleInput: "Kabuledildi", messageInput: "Başvuru kabuledildi")
                }
            }
        
    }
    
    @IBAction func RedetButon(_ sender: Any) {
        
        let firestoreDatabase = Firestore.firestore()
           let basvuruID = id

           let yeniDurum = "Başvurunuz Reddedildi"

           firestoreDatabase.collection("Basvurular").document(basvuruID!).updateData([
               "durum": yeniDurum
           ]) { error in
               if let error = error {
                   print("Durum güncellenirken hata oluştu: \(error.localizedDescription)")
               } else {
                   self.makeAlert(titleInput: "Rededildi", messageInput: "Başvuru rededildi")
               }
           }
        
        
    }
    
    func makeAlert(titleInput:String, messageInput:String) {
           let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
                       let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
                       alert.addAction(okButton)
                       self.present(alert, animated: true, completion: nil)
       }
        
    }
    
    

