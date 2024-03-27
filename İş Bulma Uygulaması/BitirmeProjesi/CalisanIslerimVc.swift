//
//  CalisanIslerimVc.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 19.01.2024.
//

import UIKit
import Firebase


class CalisanIslerimVc: UIViewController,UITableViewDataSource, UITableViewDelegate {
   

    
    @IBOutlet weak var IslerimTabelView: UITableView!
    
    var PozisyonArray = [String]()
    var isyeriAdArray = [String]()
    var adresArray = [String]()
    var tanimArray = [String]()
    var durumArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        IslerimTabelView.dataSource = self
        IslerimTabelView.delegate = self
        
        getIsBilgileri()
        
    }
    

    
    func getIsBilgileri() {
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
           
            return
        }
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Basvurular").whereField("kulaniciEposta", isEqualTo: currentUserEmail).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let documents = snapshot?.documents, !documents.isEmpty {
                    
                   
                    self.adresArray.removeAll(keepingCapacity: false)
                    self.durumArray.removeAll(keepingCapacity: false)
                    
                    self.isyeriAdArray.removeAll(keepingCapacity: false)
                    self.PozisyonArray.removeAll(keepingCapacity: false)
                    self.tanimArray.removeAll(keepingCapacity: false)
                    
                    for document in documents {
                        let documentID = document.documentID
                        
                       
                       
                        if let Pozisyon = document.get("ilanPozisyon") as? String {
                            self.PozisyonArray.append(Pozisyon)
                        }
                        
                        if let isyeriAdi = document.get("isyeriAdi") as? String {
                            self.isyeriAdArray.append(isyeriAdi)
                        }
                        if let adres = document.get("isyeriAdresi") as? String {
                            self.adresArray.append(adres)
                        }
                        if let durum = document.get("durum") as? String {
                            self.durumArray.append(durum)
                        }
                        if let tanim = document.get("ilanTabim") as? String {
                            self.tanimArray.append(tanim)
                        }
                        
                    }
                    self.IslerimTabelView.reloadData()
                } else {
                    print("Belge bulunamadı veya boş.")
                }
            }
        }
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSonuclarVc" {
            if let destinationVC = segue.destination as? SonuclarVC {
               
                if let selectedIndexPath = IslerimTabelView.indexPathForSelectedRow {
                    destinationVC.pozisyon = PozisyonArray[selectedIndexPath.row]
                    destinationVC.isyeriad = isyeriAdArray[selectedIndexPath.row]
                    destinationVC.tanim = tanimArray[selectedIndexPath.row]
                    destinationVC.durum = durumArray[selectedIndexPath.row]
                    destinationVC.adres = adresArray[selectedIndexPath.row]
                   
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toSonuclarVc", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isyeriAdArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = IslerimTabelView.dequeueReusableCell(withIdentifier: "islerCell", for: indexPath) as! IslerimCell
               
        cell.isyeriLabel.text = isyeriAdArray[indexPath.row]
        cell.pozisyonLabel.text = PozisyonArray[indexPath.row]
        
               return cell
    }
    

}
