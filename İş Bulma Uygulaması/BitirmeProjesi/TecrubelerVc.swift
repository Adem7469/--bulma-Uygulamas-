//
//  TecrubelerVc.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 12.01.2024.
//

import UIKit
import Firebase

class TecrubelerVc: UIViewController {

    
    @IBOutlet weak var ekleButon: UIButton!
    @IBOutlet weak var bitisDatePicer: UIDatePicker!
    @IBOutlet weak var balangicDatePicer: UIDatePicker!
    @IBOutlet weak var bitisTarihText: UITextField!
    @IBOutlet weak var baslangicTarihText: UITextField!
    @IBOutlet weak var isyeriAdiText: UITextField!
    @IBOutlet weak var pozisyonText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    @IBAction func baslangicDatePicer(_ sender: Any) {
        updateBaslangicTextFieldWithDate(datePicker: sender as! UIDatePicker)
    }
    func updateBaslangicTextFieldWithDate(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        baslangicTarihText.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func bitisDatePiceer(_ sender: Any) {
        updateBitisTextFieldWithDate(datePicker: sender as! UIDatePicker)
    }
    func updateBitisTextFieldWithDate(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
       bitisTarihText.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func ekleButon(_ sender: Any) {
        
        
         guard let userUID = Auth.auth().currentUser?.uid else {
                
                makeAlert(titleInput: "Hata!", messageInput: "Oturum açmış bir kullanıcı bulunamadı.")
                return
            }

            let db = Firestore.firestore()

            let pozisyon = self.pozisyonText.text ?? ""
            let isyeriAdi = self.isyeriAdiText.text ?? ""
            let BaslangicTarihi = self.baslangicTarihText.text ?? ""
            let bitisTarihi = self.bitisTarihText.text ?? ""
            

            let ilanData: [String: Any] = [
                "pozisyon":pozisyon,
                "isyeriAdi": isyeriAdi,
                "baslangicTarihi": BaslangicTarihi,
                "bitisTarihi": bitisTarihi,
                
                "postedBy" : Auth.auth().currentUser!.email!
            ]

           
            let ilanlarCollectionRef = db.collection("Tecrubeler")

            
            ilanlarCollectionRef.addDocument(data: ilanData) { (error) in
                if let error = error {
                    self.makeAlert(titleInput: "Hata!", messageInput: error.localizedDescription)
                } else {
                    self.makeAlert(titleInput: "Başarı", messageInput: "Tecrube eklendi.")
                    self.pozisyonText.text = ""
                    self.isyeriAdiText.text = ""
                    self.baslangicTarihText.text = ""
                    self.bitisTarihText.text = ""
                    
                    
                }
            }
                
    }
    
    func makeAlert(titleInput:String, messageInput:String) {
           let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
                       let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
                       alert.addAction(okButton)
                       self.present(alert, animated: true, completion: nil)
       }
    func checkForValidForm()
        {
            if pozisyonText.text != ""  && isyeriAdiText.text != "" && baslangicTarihText.text != "" &&  bitisTarihText.text != ""
            {
                ekleButon.isEnabled = true
            }
            else
            {
                ekleButon.isEnabled = false
            }
        }
    
}
