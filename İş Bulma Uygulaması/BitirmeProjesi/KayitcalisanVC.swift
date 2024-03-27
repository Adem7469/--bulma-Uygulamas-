//
//  KayitcalisanVC.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 22.12.2023.
//

import UIKit
import CoreLocation
import CoreData
import Firebase

class KayitcalisanVC: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var adText: UITextField!
    
    @IBOutlet weak var sifreUyari: UILabel!
    @IBOutlet weak var sifretekrarUyari: UILabel!
    @IBOutlet weak var numaraUyari: UILabel!
    @IBOutlet weak var epostaUyari: UILabel!
    @IBOutlet weak var kayitButon: UIButton!
    @IBOutlet weak var tarihText: UITextField!
    @IBOutlet weak var adresText: UITextField!
    @IBOutlet weak var epostaText: UITextField!
    @IBOutlet weak var numaraText: UITextField!
    @IBOutlet weak var sifretekrarText: UITextField!
    @IBOutlet weak var sifreText: UITextField!
    @IBOutlet weak var soyadText: UITextField!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var tarihDate: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    @IBAction func kayitButon(_ sender: Any) {
        
        if isFormValid() {
                Auth.auth().createUser(withEmail: epostaText.text!, password: sifreText.text!) { (authData, error) in
                    if error != nil {
                        self.makeAlert(titleInput: "Hata!", messageInput: error?.localizedDescription ?? "Error")
                    } else {
                        self.addUserToFirestore()
                    }
                }
            } else {
                makeAlert(titleInput: "Hata!", messageInput: "Kullanıcı adı ve şifre boş olamaz?")
            }
        }

        func isFormValid() -> Bool {
           
            if sifreText.text != sifretekrarText.text {
                sifretekrarUyari.text = "Şifreler uyuşmuyor"
                sifretekrarUyari.isHidden = false
                return false
            }

            

            return true
        
    }
    
    func addUserToFirestore() {
           let firestoreDatabase = Firestore.firestore()
           let userId = Auth.auth().currentUser?.uid

           guard let userId = userId else {
               return
           }

           let userDocument = firestoreDatabase.collection("KullaniciCalisan").document(userId)

           let userData = [
            
              "kulaniciEposta":epostaText.text!,
               "kullaniciAdi": adText.text!,
               "kulaniciSoyadi": soyadText.text!,
               "telefonno": numaraText.text!,
               "dogumtarihi": tarihText.text!,
               "adresi": adresText.text!,
              
           ]

           userDocument.setData(userData) { error in
               if let error = error {
                   self.makeAlert(titleInput: "Error!", messageInput: error.localizedDescription)
               } else {
                   self.performSegue(withIdentifier: "KayitcalisanVc", sender: nil)
               }
           }
       }
    
    
    
    @IBAction func numaraChange(_ sender: Any) {
        
        
        if let phoneNumber = numaraText.text
                {
                    if let errorMessage = invalidPhoneNumber(phoneNumber)
                    {
                        numaraUyari.text = errorMessage
                        numaraUyari.isHidden = false
                    }
                    else
                    {
                        numaraUyari.isHidden = true
                    }
                }
        checkForValidForm()
    }
    
    func invalidPhoneNumber(_ value: String) -> String?
        {
            let set = CharacterSet(charactersIn: value)
            if !CharacterSet.decimalDigits.isSuperset(of: set)
            {
                return "Geçerli bir telefon numarası giriniz"
            }
            
            if value.count != 10
            {
                return "Telefon Numarası 10 basamaktan fazla olamaz"
            }
            return nil
        }
    
    @IBAction func sifreChange(_ sender: Any) {
        
        if let password = sifreText.text
                {
                    if let errorMessage = invalidPassword(password)
                    {
                        sifreUyari.text = errorMessage
                        sifreUyari.isHidden = false
                    }
                    else
                    {
                        sifreUyari.isHidden = true
                    }
                }
                
                checkForValidForm()
        
    }
    
    func invalidPassword(_ value: String) -> String?
        {
            if value.count < 8
            {
                return "Şifre en az 8 karakter olmalıdır"
            }
            if containsDigit(value)
            {
                return "Şifrede en az 1 rakam olmalıdır"
            }
            if containsLowerCase(value)
            {
                return "Şifre en az 1 küçük harf içermelidir"
            }
            if containsUpperCase(value)
            {
                return "Şifre en az 1 büyük harf içermelidir"
            }
            return nil
        }
        
        func containsDigit(_ value: String) -> Bool
        {
            let reqularExpression = ".*[0-9]+.*"
            let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
            return !predicate.evaluate(with: value)
        }
        
        func containsLowerCase(_ value: String) -> Bool
        {
            let reqularExpression = ".*[a-z]+.*"
            let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
            return !predicate.evaluate(with: value)
        }
        
        func containsUpperCase(_ value: String) -> Bool
        {
            let reqularExpression = ".*[A-Z]+.*"
            let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
            return !predicate.evaluate(with: value)
        }
        
    
    @IBAction func sifretekrarChange(_ sender: Any) {
        
        if let password = sifretekrarText.text
                {
                    if let errorMessage = invalidPassword(password)
                    {
                        sifretekrarUyari.text = errorMessage
                        sifretekrarUyari.isHidden = false
                    }
                    else
                    {
                        sifretekrarUyari.isHidden = true
                    }
                }
                
                checkForValidForm()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           if let location = locations.first {
              
               reverseGeocode(location: location)
           }
       }

       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Konum bilgisi alınamadı, hata: \(error.localizedDescription)")
       }

       func reverseGeocode(location: CLLocation) {
           let geocoder = CLGeocoder()
           geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
               if let error = error {
                   print("Reverse geocoding hatası: \(error.localizedDescription)")
                   return
               }

               if let placemark = placemarks?.first {
                   
                   let address = "\(placemark.locality ?? ""), \(placemark.subLocality ?? ""), \(placemark.thoroughfare ?? "")"
                   self.adresText.text = address
               }
           }
       }
    
    @IBAction func epostaChange(_ sender: Any) {
        
        if let eposta = epostaText.text
                {
                    if let errorMessage = invalidEmail(eposta)
                    {
                        epostaUyari.text = errorMessage
                        epostaUyari.isHidden = false
                    }
                    else
                    {
                        epostaUyari.isHidden = true
                    }
                }
        checkForValidForm()
        
    }
    
    func invalidEmail(_ value: String) -> String?
        {
            let reqularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
            if !predicate.evaluate(with: value)
            {
                return "Geçerli bir eposta adresi giriniz"
            }
            
            return nil
        }
        
    
    @IBAction func adresButon(_ sender: Any) {
        
        locationManager.requestLocation()
        
    }
    
    func checkForValidForm()
        {
            if epostaUyari.isHidden && sifreUyari.isHidden && sifretekrarUyari.isHidden &&  numaraUyari.isHidden 
            {
                kayitButon.isEnabled = true
            }
            else
            {
                kayitButon.isEnabled = false
            }
        }
 
    @IBAction func tarihDatepicer(_ sender: UIDatePicker) {
        
        updateTextFieldWithDate(datePicker: sender)
        
    }
    
    func updateTextFieldWithDate(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        tarihText.text = dateFormatter.string(from: datePicker.date)
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
            let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
}
