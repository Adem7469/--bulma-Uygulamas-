//
//  IsAraVc.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 13.01.2024.
//

import UIKit
import Firebase
import SDWebImage


class IsAraVc: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    var CalismaTuruArray = [String]()
    var userEmailArray = [String]()
    var IsyeriAdiArray = [String]()
    var PozisyonArray = [String]()
    var IsyeriFotografiArray = [String]()
    var documentIdArray = [String]()
    var adresArray = [String]()
    var maasArray = [String]()
    var ayrintiArray = [String]()
    var yolArray = [Bool]()
    var yemekArray = [Bool]()
    var pirimArray = [Bool]()
    var idArray = [String]()
    var searchByPozisyonArray = [String]()
    var searchByAdresArray = [String]()

    
    @IBOutlet weak var aramaBar: UISearchBar!
   
   
    @IBOutlet weak var IlanlarTableView: UITableView!
   
    var baslangicPozisyonlar = [String]()
    var baslangicIsyeriAdlari = [String]()
    var baslangicAdresler = [String]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        IlanlarTableView.dataSource = self
        IlanlarTableView.delegate = self

        aramaBar.delegate = self
        
        
        getIlanBilgileri()
        
    }
    
    func getIlanBilgileri() {
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("kIlanlar").order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    
                  
                    self.IsyeriFotografiArray.removeAll(keepingCapacity: false)
                    self.adresArray.removeAll(keepingCapacity: false)
                    
                    self.IsyeriAdiArray.removeAll(keepingCapacity: false)
                    self.PozisyonArray.removeAll(keepingCapacity: false)
                    self.documentIdArray.removeAll(keepingCapacity: false)
                    
                    for document in documents {
                        let documentID = document.documentID

                        if let Pozisyon = document.get("pozisyon") as? String,
                           let adres = document.get("adres") as? String,
                           let tur = document.get("calismaTuru") as? String,
                           let maas = document.get("maas") as? String,
                           let tanim = document.get("ayrinti") as? String,
                           let isyeri = document.get("isyeriAdi") as? String,
                            let fotograf = document.get("imageUrl") as? String,
                           let Yol = document.get("yol") as? Bool,
                           let Yemek = document.get("yemek") as? Bool,
                           let id = document.get("kulaniciId") as? String,
                           let Prim = document.get("pirim") as? Bool {
                            
                            self.PozisyonArray.append(Pozisyon)
                            self.adresArray.append(adres)
                            self.maasArray.append(maas)
                            self.ayrintiArray.append(tanim)
                            self.yolArray.append(Yol)
                            self.yemekArray.append(Yemek)
                            self.pirimArray.append(Prim)
                            self.IsyeriAdiArray.append(isyeri)
                            self.IsyeriFotografiArray.append(fotograf)
                            self.documentIdArray.append(documentID)
                            self.idArray.append(id)
                            self.CalismaTuruArray.append(tur)
                           
                            self.userEmailArray.append(documentID)
                        }
                    }
                    
                    self.IlanlarTableView.reloadData()
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
       
        let cell = IlanlarTableView.dequeueReusableCell(withIdentifier: "isaraCell", for: indexPath) as! IsAraCell
               
        cell.adresText.text = adresArray[indexPath.row]
               cell.pozisyonText.text = PozisyonArray[indexPath.row]
        cell.gorselImageview.sd_setImage(with: URL(string: self.IsyeriFotografiArray[indexPath.row]))
        cell.isyeriText.text = IsyeriAdiArray[indexPath.row]
        
               return cell
    }
    
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBasvuruVc" {
            if let destinationVC = segue.destination as? BasvuruVc {
                
                if let selectedIndexPath = IlanlarTableView.indexPathForSelectedRow {
                    destinationVC.ilanPozisyon = PozisyonArray[selectedIndexPath.row]
                    destinationVC.ilanAdres = adresArray[selectedIndexPath.row]
                    destinationVC.ilanIsyeriAdi = IsyeriAdiArray[selectedIndexPath.row]
                    destinationVC.ilanIsyeriFotografiURL = IsyeriFotografiArray[selectedIndexPath.row]
                    destinationVC.ilanTanim = ayrintiArray[selectedIndexPath.row]
                    destinationVC.ilaniMaas = maasArray[selectedIndexPath.row]
                    destinationVC.ilanYol = yolArray[selectedIndexPath.row]
                    destinationVC.ilanYemek = yemekArray[selectedIndexPath.row]
                    destinationVC.ilanPrim = pirimArray[selectedIndexPath.row]
                    destinationVC.ilanId = documentIdArray[selectedIndexPath.row]
                    destinationVC.id = idArray[selectedIndexPath.row]
                    destinationVC.calisma = CalismaTuruArray[selectedIndexPath.row]
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toBasvuruVc", sender: nil)
    }
    

   
    
    
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
           
            
            getIlanBilgileri()
            
            IlanlarTableView.reloadData()
        } else {
            let aramaMetni = searchText.lowercased()

           
            baslangicPozisyonlar = PozisyonArray
            baslangicIsyeriAdlari = IsyeriAdiArray
            baslangicAdresler = adresArray
           

            let filtrelePozisyonlar = baslangicPozisyonlar.filter { $0.lowercased().contains(aramaMetni.lowercased()) == true }
            let filtreleIsyeriAdlari = baslangicIsyeriAdlari.filter { $0.lowercased().contains(aramaMetni.lowercased()) == true }
            let filtreleAdresler = baslangicAdresler.filter { $0.lowercased().contains(aramaMetni.lowercased()) == true }

            
            PozisyonArray = filtrelePozisyonlar.isEmpty ? baslangicPozisyonlar : filtrelePozisyonlar
            IsyeriAdiArray = filtreleIsyeriAdlari.isEmpty ? baslangicIsyeriAdlari : filtreleIsyeriAdlari
            adresArray = filtreleAdresler.isEmpty ? baslangicAdresler : filtreleAdresler

            print("Pozisyonlar: \(filtrelePozisyonlar)")
            print("IsyeriAdlari: \(filtreleIsyeriAdlari)")
            print("Adresler: \(filtreleAdresler)")
        }

        let rowCount = min(PozisyonArray.count, IsyeriAdiArray.count, adresArray.count)

        
        PozisyonArray = Array(PozisyonArray.prefix(rowCount))
        IsyeriAdiArray = Array(IsyeriAdiArray.prefix(rowCount))
        adresArray = Array(adresArray.prefix(rowCount))

        IlanlarTableView.reloadData()
    }
  
    
   
}
