//
//  ProfilisverenVC.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 23.12.2023.
//

import UIKit
import Firebase
import CoreLocation
import SDWebImage
import FirebaseStorage
class ProfilisverenVC: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate  {

    let locationManager = CLLocationManager()
    var selectedImage: UIImage?
    @IBOutlet weak var kaydetButon: UIButton!
    
    @IBOutlet weak var epostaLabel: UILabel!
    @IBOutlet weak var isyeriLabel: UILabel!
    @IBOutlet weak var tarihDatePicer: UIDatePicker!
    @IBOutlet weak var vergiNoText: UITextField!
    @IBOutlet weak var vergiDayresiText: UITextField!
    @IBOutlet weak var vergiIliText: UITextField!
    @IBOutlet weak var detayTextView: UITextView!
    @IBOutlet weak var adresText: UITextField!
    @IBOutlet weak var isyeriadiText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var telefonUyari: UILabel!
    @IBOutlet weak var telefonText: UITextField!
    @IBOutlet weak var tarihText: UITextField!
    @IBOutlet weak var tcUyari: UILabel!
    @IBOutlet weak var tcText: UITextField!
    @IBOutlet weak var soyadText: UITextField!
    @IBOutlet weak var isimText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    let placeholder = "İş yeriniz hakında detaylıbilgi verin Ör: hangi saat aralığında açiksiniz ve nasıl bir iş yapıyorsunuz"
    
    var currentUser: User?
    var kullaniciRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
       
        if let user = Auth.auth().currentUser {
                  currentUser = user
                  kullaniciRef = Firestore.firestore().collection("Kullanicilar").document(user.uid)
                  getKullaniciBilgileriFromFirestore(userID: user.uid)
              }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKetboardn))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTepRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTepRecognizer)
        
        
        detayTextView.delegate = self
        if detayTextView.text == "" {
            
            detayTextView.text = placeholder
            detayTextView.textColor = UIColor.lightGray
            
        }
    }
    
    func getKullaniciBilgileriFromFirestore(userID: String) {
           let firestoreDatabase = Firestore.firestore()
           let kullaniciRef = firestoreDatabase.collection("Kullanicilar").document(userID)

           kullaniciRef.getDocument { (document, error) in
               if let document = document, document.exists {
                   
                   self.isimText.text = document["kullaniciAdi"] as? String ?? ""
                   self.soyadText.text = document["kulanicisoyadi"] as? String ?? ""
                   self.tcText.text = document["tc"] as? String ?? ""
                   self.telefonText.text = document["telefon"] as? String ?? ""
                   self.emailText.text =  Auth.auth().currentUser!.email!
                   self.adresText.text = document["adres"] as? String ?? ""
                   self.tarihText.text = document["tarih"] as? String ?? ""
                   self.vergiIliText.text = document["vergiIli"] as? String ?? ""
                   self.vergiDayresiText.text = document["vergiDayresi"] as? String ?? ""
                   self.vergiNoText.text = document["vergiNo"] as? String ?? ""
                   self.isyeriadiText.text = document["isyeriadi"] as? String ?? ""
                   self.detayTextView.text = document["isyeriHakinda"] as? String ?? ""
                   self.isyeriLabel.text = document["isyeriadi"] as? String ?? ""
                   self.epostaLabel.text =  Auth.auth().currentUser!.email!
                   if let imageUrl = document["imageUrl"] as? String, let url = URL(string: imageUrl) {
                                   self.imageView.sd_setImage(with: url, completed: nil)
                               }
                   
               } else {
                   print("Kullanıcı belirtilen ID ile bulunamadı: \(userID)")
               }
           }
       }

   
    @IBAction func cikisButon(_ sender: Any) {
        
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toAnaVC", sender: nil)
        }catch{
            print("eror")
        }
    }
    
    
    @IBAction func kaydetButon(_ sender: Any) {
        
        
               let yeniIsim = isimText.text ?? ""
               let yeniSoyad = soyadText.text ?? ""
               let yeniTC = tcText.text ?? ""
               let yeniTelefon = telefonText.text ?? ""
               let yeniAdres = adresText.text ?? ""
               let yeniIsyeriAdi = isyeriadiText.text ?? ""
               let vergiDayresi = vergiDayresiText.text ?? ""
               let vergiDayresiIli = vergiIliText.text ?? ""
               let vergiNo = vergiNoText.text ?? ""
               let tarih = tarihText.text ?? ""
               let detay = detayTextView.text ?? ""

              
               updateKullaniciBilgileriInFirestore(userID: currentUser?.uid, isim: yeniIsim, soyad: yeniSoyad, tc: yeniTC, telefon: yeniTelefon, adres: yeniAdres, isyeriAdi: yeniIsyeriAdi ,detay: detay, vergiNo: vergiNo, vergiDayresi: vergiDayresi, vergiIli: vergiDayresiIli, gorsel: selectedImage,tarih: tarih)
           
       
        
           }
    
    func updateKullaniciBilgileriInFirestore(userID: String?, isim: String, soyad: String, tc: String, telefon: String, adres: String, isyeriAdi: String, detay: String, vergiNo: String, vergiDayresi: String, vergiIli: String, gorsel: UIImage?, tarih: String) {
            guard let userID = userID else {
                print("Hata: Kullanıcı ID boş.")
                return
            }

            let firestoreDatabase = Firestore.firestore()
            let kullaniciRef = firestoreDatabase.collection("Kullanicilar").document(userID)

            
            if let image = gorsel {
                uploadImageToStorage(userID: userID, image: image) { imageUrl in
                    
                    let updatedData: [String: Any] = [
                        "kullaniciAdi": isim,
                        "kulanicisoyadi": soyad,
                        "tc": tc,
                        "telefon": telefon,
                        "adres": adres,
                        "isyeriadi": isyeriAdi,
                        "isyeriHakinda": detay,
                        "vergiNo": vergiNo,
                        "vergiDayresi": vergiDayresi,
                        "vergiIli": vergiIli,
                        "imageUrl": imageUrl,
                        "tarih": tarih
                    ]

                    kullaniciRef.setData(updatedData, merge: true) { error in
                        if let error = error {
                            self.makeAlert(titleInput: "Hata!", messageInput: "Bir Hata Oluştu :\(error.localizedDescription)")
                        } else {
                            self.makeAlert(titleInput: "Başarılı", messageInput: "Profiliniz Güncelendi")
                        }
                    }
                }
            } else {
               
                let updatedData: [String: Any] = [
                    "kullaniciAdi": isim,
                    "kulanicisoyadi": soyad,
                    "tc": tc,
                    "telefon": telefon,
                    "adres": adres,
                    "isyeriadi": isyeriAdi,
                    "isyeriHakinda": detay,
                    "vergiNo": vergiNo,
                    "vergiDayresi": vergiDayresi,
                    "vergiIli": vergiIli,
                    "tarih": tarih
                ]

                kullaniciRef.setData(updatedData, merge: true) { error in
                    if let error = error {
                        self.makeAlert(titleInput: "Hata!", messageInput: "Bir Hata Oluştu :\(error.localizedDescription)")
                    } else {
                        self.makeAlert(titleInput: "Başarılı", messageInput: "Profiliniz Güncelendi")
                    }
                }
            }
        }
    func uploadImageToStorage(userID: String, image: UIImage, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("profil_images/\(userID).jpg")

        if let imageData = image.jpegData(compressionQuality: 0.5) {
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Storage'a resim yüklenirken hata oluştu: \(error.localizedDescription)")
                    return
                }

               
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Download URL alınamadı: \(error.localizedDescription)")
                        return
                    }

                    
                    completion(url?.absoluteString ?? "")
                }
            }
        }
    }
    
    @IBAction func konumButon(_ sender: Any) {
        
        locationManager.requestLocation()
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
    
    @IBAction func telefonChange(_ sender: Any) {
        if let phoneNumber = telefonText.text
                {
                    if let errorMessage = invalidPhoneNumber(phoneNumber)
                    {
                        telefonUyari.text = errorMessage
                        telefonUyari.isHidden = false
                    }
                    else
                    {
                        telefonUyari.isHidden = true
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
    
    
    @IBAction func tcChange(_ sender: Any) {
        
        if let tcNumber = tcText.text
                {
                    if let errorMessage = invalidtcNumber(tcNumber)
                    {
                        tcUyari.text = errorMessage
                        tcUyari.isHidden = false
                    }
                    else
                    {
                        tcUyari.isHidden = true
                    }
                }
        checkForValidTcForm()
        
    }
    
    func invalidtcNumber(_ value: String) -> String?
        {
            let set = CharacterSet(charactersIn: value)
            if !CharacterSet.decimalDigits.isSuperset(of: set)
            {
                return "Geçerli bir TC kimlik  numarası giriniz"
            }
            
            if value.count != 11
            {
                return "TC kimlik numarasi 11 basamaktan fazla olamaz"
            }
            return nil
        }
    
    func checkForValidForm()
        {
            if telefonUyari.isHidden
            {
                kaydetButon.isEnabled = true
            }
            else
            {
                kaydetButon.isEnabled = false
            }
        }
    func checkForValidTcForm()
        {
            if  tcUyari.isHidden
            {
                kaydetButon.isEnabled = true
            }
            else
            {
                kaydetButon.isEnabled = false
            }
        }
    
    @IBAction func tarihDatePicer(_ sender: Any) {
        
        updateTextFieldWithDate(datePicker: sender as! UIDatePicker)
    }
    func updateTextFieldWithDate(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        tarihText.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            selectedImage = image
            kaydetButon.isEnabled = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    @objc func hideKetboardn () {
        
        view.endEditing(true)
        
    }
   
    
    func makeAlert(titleInput:String, messageInput:String) {
           let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
                       let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
                       alert.addAction(okButton)
                       self.present(alert, animated: true, completion: nil)
       }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
           if detayTextView.text == placeholder {
               detayTextView.text = ""
               detayTextView.textColor = UIColor.black
           }
       }

       func textViewDidEndEditing(_ textView: UITextView) {
           if detayTextView.text.isEmpty {
               detayTextView.text = placeholder
               detayTextView.textColor = UIColor.lightGray
           }
       }
    
}
