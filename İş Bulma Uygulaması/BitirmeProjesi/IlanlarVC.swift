//
//  IlanlarVC.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 23.12.2023.
//

import UIKit
import Firebase
import SDWebImage

class IlanlarVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var currentUser: User?
    
    @IBOutlet weak var ilanlarTableView: UITableView!
    
    var userEmailArray = [String]()
    var IsyeriAdiArray = [String]()
    var PozisyonArray = [String]()
    var IsyeriFotografiArray = [String]()
    var documentIdArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
      
      
       
    }
   
    override func viewDidAppear(_ animated: Bool) {
        ilanlarTableView.dataSource = self
        ilanlarTableView.delegate = self

        getIlanBilgileri()
      
    }
    
  
    
    func getIlanBilgileri() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            
            return
        }

        let fireStoreDatabase = Firestore.firestore()

        fireStoreDatabase.collection("kIlanlar")
            .whereField("postedBy", isEqualTo: currentUserEmail)
            .order(by: "date", descending: true)
            .addSnapshotListener { (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    if snapshot?.isEmpty != true && snapshot != nil {
                        self.userEmailArray.removeAll(keepingCapacity: false)
                        self.IsyeriFotografiArray.removeAll(keepingCapacity: false)
                        
                        self.IsyeriAdiArray.removeAll(keepingCapacity: false)
                        self.PozisyonArray.removeAll(keepingCapacity: false)
                        self.documentIdArray.removeAll(keepingCapacity: false)
                        
                        
                        for document in snapshot!.documents {
                            let documentID = document.documentID
                            self.documentIdArray.append(documentID)
                            
                            if let Pozisyon = document.get("pozisyon") as? String {
                                self.PozisyonArray.append(Pozisyon)
                            }
                            if let postedBy = document.get("postedBy") as? String {
                                self.userEmailArray.append(postedBy)
                            }
                        
                            if let gorsel = document.get("imageUrl") as? String {
                                self.IsyeriFotografiArray.append(gorsel)
                            }
                            if let isyeri = document.get("isyeriAdi") as? String {
                                self.IsyeriAdiArray.append(isyeri)
                            }
                            
                        }
                        
                        self.ilanlarTableView.reloadData()
                    }
                }
        }
    }
  
  
    
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PozisyonArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ilanlarTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! IlanlarimTableView
               
               
               cell.pozisyonLable.text = PozisyonArray[indexPath.row]
        cell.fotoImageView.sd_setImage(with: URL(string: self.IsyeriFotografiArray[indexPath.row]))
        cell.isyeriLable.text = IsyeriAdiArray[indexPath.row]
        
               return cell
    }
    
    
    func deletePaintingFromFirestore(documentID: String) {
        let db = Firestore.firestore()
        let paintingsCollection = db.collection("kIlanlar")

        paintingsCollection.document(documentID).delete { error in
            if let error = error {
                print("Firestore'dan silme hatası: \(error.localizedDescription)")
            } else {
                print("Firestore'dan başarıyla silindi.")
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let documentID = documentIdArray[indexPath.row]
            deletePaintingFromFirestore(documentID: documentID)

            
            userEmailArray.remove(at: indexPath.row)
            IsyeriAdiArray.remove(at: indexPath.row)
            IsyeriFotografiArray.remove(at: indexPath.row)
            PozisyonArray.remove(at: indexPath.row)
            
            ilanlarTableView.reloadData()
        }
    }
    
}
