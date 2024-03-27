//
//  GorusmelerVC.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 23.12.2023.
//

import UIKit
import Firebase
import SDWebImage


class GorusmelerVC: UIViewController,UITableViewDataSource, UITableViewDelegate  {
   

    var AdArray = [String]()
    var soyadArray = [String]()
    var PozisyonArray = [String]()
    var ilanPozisyonArray = [String]()
    var fotografArray = [String]()
    var egitimArray = [String]()
    var ehliyetArray = [String]()
    var cinsiyetArray = [String]()
    var askerlikArray = [String]()
    var telefonArray = [String]()
    var epostaArray = [String]()
    var tarihArray = [String]()
    var tanimArray = [String]()
    var idArray = [String]()
    var documentIdArray = [String]()
    
    
    @IBOutlet weak var basvuruTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       basvuruTableView.dataSource = self
       basvuruTableView.delegate = self

        
        getBasvuruBilgileri()
        
    }
    
    

   
    
  
    func getBasvuruBilgileri() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            
            return
        }
        let fireStoreDatabase = Firestore.firestore()

        fireStoreDatabase.collection("Basvurular")
            .whereField("KulaniciId", isEqualTo: currentUserID).addSnapshotListener { [self] snapshot, error in
                
            
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    if snapshot?.isEmpty != true && snapshot != nil {
                       
                        self.AdArray.removeAll(keepingCapacity: false)
                        self.soyadArray.removeAll(keepingCapacity: false)
                       
                        self.documentIdArray.removeAll(keepingCapacity: false)
                        
                        for document in snapshot!.documents {
                            let documentID = document.documentID
                            self.documentIdArray.append(documentID)
                           
                           
                            
                           
                            if let Ad = document.get("kullaniciAdi") as? String {
                                self.AdArray.append(Ad)
                                
                            }
                            if let Soyad = document.get("kulaniciSoyadi") as? String {
                                self.soyadArray.append(Soyad)
                                
                            }
                            if let eposta = document.get("kulaniciEposta") as? String {
                                self.epostaArray.append(eposta)
                                
                            }
                            if let telefon = document.get("telefonno") as? String {
                                self.telefonArray.append(telefon)
                               
                            }
                            if let tarih = document.get("dogumtarihi") as? String {
                                self.tarihArray.append(tarih)
                                
                            }
                            if let pozisyon = document.get("pozisyon") as? String {
                                self.PozisyonArray.append(pozisyon)
                                
                            }
                            if let cinsiyet = document.get("cinsiyet") as? String {
                                self.cinsiyetArray.append(cinsiyet)
                                
                            }
                            if let egitim = document.get("egitim") as? String {
                                self.egitimArray.append(egitim)
                                
                            }
                            if let askerlik = document.get("askerlik") as? String {
                                self.askerlikArray.append(askerlik)
                                
                            }
                            if let ehliyet = document.get("ehliyet") as? String {
                                self.ehliyetArray.append(ehliyet)
                               
                            }
                            if let foto = document.get("fotoUrl") as? String {
                                self.fotografArray.append(foto)
                                
                            }
                            if let ilanpozisyon = document.get("ilanPozisyon") as? String {
                                self.ilanPozisyonArray.append(ilanpozisyon)
                               
                            }
                            if let tanim = document.get("ilanTabim") as? String {
                                self.tanimArray.append(tanim)
                                
                            }
                            if let id = documentID as? String {
                                self.idArray.append(id)
                                
                            }
                          
                            print("Ad: \(AdArray.last ?? "N/A"), DocumentID: \(documentID)")
                        }
                        
                        self.basvuruTableView.reloadData()
                    }
                }
        }
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetayVc" {
            if let destinationVC = segue.destination as? BasvuruAdayVC {
                
                if let selectedIndexPath = basvuruTableView.indexPathForSelectedRow {
                    destinationVC.pozisyon = PozisyonArray[selectedIndexPath.row]
                    destinationVC.ad = AdArray[selectedIndexPath.row]
                    destinationVC.soyad = soyadArray[selectedIndexPath.row]
                    destinationVC.fotograf = fotografArray[selectedIndexPath.row]
                    destinationVC.tanim = tanimArray[selectedIndexPath.row]
                    destinationVC.telefon = telefonArray[selectedIndexPath.row]
                    destinationVC.eposta = epostaArray[selectedIndexPath.row]
                    destinationVC.egitim = egitimArray[selectedIndexPath.row]
                    destinationVC.tarih = tarihArray[selectedIndexPath.row]
                    destinationVC.askerlik = askerlikArray[selectedIndexPath.row]
                    destinationVC.cinsiyet = cinsiyetArray[selectedIndexPath.row]
                    destinationVC.ehliyet = ehliyetArray[selectedIndexPath.row]
                    destinationVC.ilanpozisyon = ilanPozisyonArray[selectedIndexPath.row]
                    destinationVC.id = idArray[selectedIndexPath.row]
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toDetayVc", sender: nil)
        
        
    }
  

       
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = basvuruTableView.dequeueReusableCell(withIdentifier: "BavuruCell", for: indexPath) as! GorusmelerCell
               
               
        cell.soyadLabel.text = soyadArray[indexPath.row]
        cell.adLabel.text = AdArray[indexPath.row]
        
               return cell
    }
    
  
    
}
