//
//  ProfilCalisanVc.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 10.01.2024.
//

import UIKit
import Firebase
import SDWebImage
import CoreLocation
import FirebaseStorage

class ProfilCalisanVc: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    var PozisyonArray = [String]()
    var isyeriAdArray = [String]()
    var baslangicArray = [String]()
    var bitisArray = [String]()
    var userEmailArray = [String]()
    var documentIDArray = [String]()

    let locationManager = CLLocationManager()
    var selectedImage: UIImage?
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var emailLabel: UILabel!

    @IBOutlet weak var adsoyadLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var kaydetButon: UIButton!
    @IBOutlet weak var deneyimTableView: UITableView!
    @IBOutlet weak var askerlikText: UITextField!
    @IBOutlet weak var ehliyetText: UITextField!
    @IBOutlet weak var egitimText: UITextField!
    @IBOutlet weak var pozisyonText: UITextField!
    @IBOutlet weak var cisiyetText: UITextField!
    @IBOutlet weak var adresText: UITextField!
    @IBOutlet weak var tarihText: UITextField!
    @IBOutlet weak var numaraUyari: UILabel!
    @IBOutlet weak var numaraText: UITextField!
    @IBOutlet weak var tcUyari: UILabel!
    @IBOutlet weak var tcText: UITextField!
    @IBOutlet weak var soyadText: UITextField!
    @IBOutlet weak var adText: UITextField!
    
    var currentUser: User?
    var kullaniciRef: DocumentReference!
    var egitimPicerView = UIPickerView()
    var askerlikPicerView = UIPickerView()
    var cinsiyetPicerView = UIPickerView()
   var ehliyetPicerView = UIPickerView()
    
    let egitimDurumu = ["İlköğretim","Lise","Ünüersite"]
    let askerlikDurumu = ["Muaf","Yapıldı","Yapılmadı","Tecili"]
    let cinsiyetDurumu = ["Erkek","Kadın","Diğer"]
    let ehliyetBilgisi = ["M","A1","A2","A","B1","B","BE","C1","C1E","CE"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()

        
        getIlanBilgileri()
        
        setupPickerViews()
        
        
        deneyimTableView.dataSource = self
        deneyimTableView.delegate = self
               
               configureDatePicker()
               
               tarihText.inputView = datePicker

               datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)

               tarihText.addTarget(self, action: #selector(textFieldEditing), for: .editingDidBegin)
       
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if let user = Auth.auth().currentUser {
                  currentUser = user
                  kullaniciRef = Firestore.firestore().collection("KullaniciCalisan").document(user.uid)
                  getKullaniciBilgileriFromFirestore(userID: user.uid)
              }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKetboardn))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTepRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTepRecognizer)
        
        
    }
    
    
    
    func getKullaniciBilgileriFromFirestore(userID: String) {
           let firestoreDatabase = Firestore.firestore()
           let kullaniciRef = firestoreDatabase.collection("KullaniciCalisan").document(userID)

           kullaniciRef.getDocument { (document, error) in
               if let document = document, document.exists {
                   
                   self.adText.text = document["kullaniciAdi"] as? String ?? ""
                   self.soyadText.text = document["kulaniciSoyadi"] as? String ?? ""
                   self.tcText.text = document["tc"] as? String ?? ""
                   self.numaraText.text = document["telefonno"] as? String ?? ""
                   
                   self.adresText.text = document["adresi"] as? String ?? ""
                   self.tarihText.text = document["dogumtarihi"] as? String ?? ""
                   self.pozisyonText.text = document["gorev"] as? String ?? ""
                   self.cisiyetText.text = document["cinsiyet"] as? String ?? ""
                   self.askerlikText.text = document["askerlik"] as? String ?? ""
                   self.egitimText.text = document["egitim"] as? String ?? ""
                   self.ehliyetText.text = document["ehliyet"] as? String ?? ""
                   self.emailLabel.text = document["kulaniciEposta"] as? String ?? ""
                   let ad = document["kullaniciAdi"] as? String ?? ""
                   let soyad = document["kulaniciSoyadi"] as? String ?? ""
                   self.adsoyadLabel.text = "\(ad) \(soyad)"
                   if let imageUrl = document["imageCalisan"] as? String, let url = URL(string: imageUrl) {
                                   self.imageView.sd_setImage(with: url, completed: nil)
                               }
                   
               } else {
                   print("Kullanıcı belirtilen ID ile bulunamadı: \(userID)")
               }
           }
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
    
    
    @IBAction func kaydetButon(_ sender: Any) {
        
        let yeniIsim = adText.text ?? ""
        let yeniSoyad = soyadText.text ?? ""
        let yeniTC = tcText.text ?? ""
        let yeniTelefon = numaraText.text ?? ""
        let yeniAdres = adresText.text ?? ""
        let yeniPozisyon = pozisyonText.text ?? ""
        let yeniCinsiyet = cisiyetText.text ?? ""
        let YeniAskerlik = askerlikText.text ?? ""
        let yeniEgitim = egitimText.text ?? ""
        let tarih = tarihText.text ?? ""
        let yeniEhliet = ehliyetText.text ?? ""

    
        updateKullaniciBilgileriInFirestore(userID: currentUser?.uid, isim: yeniIsim, soyad: yeniSoyad, tc: yeniTC, telefon: yeniTelefon, adres: yeniAdres, ehliyet: yeniEhliet, egitim: yeniEgitim, askerlik: YeniAskerlik, cinsiyet: yeniCinsiyet, pozisyon:yeniPozisyon, gorsel: selectedImage,tarih: tarih)
        
        
        
    }
    
    func updateKullaniciBilgileriInFirestore(userID: String?, isim: String, soyad: String, tc: String, telefon: String, adres: String, ehliyet: String, egitim: String, askerlik: String, cinsiyet: String, pozisyon: String, gorsel: UIImage?, tarih: String) {
            guard let userID = userID else {
                print("Hata: Kullanıcı ID boş.")
                return
            }

            let firestoreDatabase = Firestore.firestore()
            let kullaniciRef = firestoreDatabase.collection("KullaniciCalisan").document(userID)

            
            if let image = gorsel {
                uploadImageToStorage(userID: userID, image: image) { imageUrl in
                    
                    let updatedData: [String: Any] = [
                        "kullaniciAdi": isim,
                        "kulaniciSoyadi": soyad,
                        "tc": tc,
                        "telefonno": telefon,
                        "adres": adres,
                        "ehliyet": ehliyet,
                        "egitim": egitim,
                        "askerlik": askerlik,
                        "cinsiyet": cinsiyet,
                        "gorev": pozisyon,
                        "imageCalisan": imageUrl,
                        "dogumtarihi": tarih
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
                    "kulaniciSoyadi": soyad,
                    "tc": tc,
                    "telefonno": telefon,
                    "adres": adres,
                    "ehliyet": ehliyet,
                    "egitim": egitim,
                    "askerlik": askerlik,
                    "cinsiyet": cinsiyet,
                    "gorev": pozisyon,
                    "dogumtarihi": tarih
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
    
    
    
    @IBAction func cikisButon(_ sender: Any) {
        
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toCikisVC", sender: nil)
        }catch{
            print("eror")
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
    
    
    func checkForValidForm()
        {
            if numaraUyari.isHidden
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
    
    func configureDatePicker() {
            datePicker.datePickerMode = .date
            
        }

        @objc func datePickerValueChanged() {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            tarihText.text = dateFormatter.string(from: datePicker.date)
        }

        @objc func textFieldEditing() {
            
            datePickerValueChanged()
            
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == egitimPicerView {
            return egitimDurumu.count
        } else if pickerView == cinsiyetPicerView {
            return cinsiyetDurumu.count
        }  else if pickerView == ehliyetPicerView {
            return ehliyetBilgisi.count
        }  else if pickerView == askerlikPicerView {
            return askerlikDurumu.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == egitimPicerView {
            return egitimDurumu[row]
        } else if pickerView == askerlikPicerView {
            return askerlikDurumu[row]
        } else if pickerView == cinsiyetPicerView {
            return cinsiyetDurumu[row]
        } else if pickerView == ehliyetPicerView {
            return ehliyetBilgisi[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == egitimPicerView {
            egitimText.text = egitimDurumu[row]
        } else if pickerView == askerlikPicerView {
            askerlikText.text = askerlikDurumu[row]
        }else if pickerView == cinsiyetPicerView {
            cisiyetText.text = cinsiyetDurumu[row]
        }else if pickerView == ehliyetPicerView {
            ehliyetText.text = ehliyetBilgisi[row]
        }
    }
    
    func setupPickerViews() {
            egitimPicerView = UIPickerView()
            showPicker(for: egitimDurumu, textField: egitimText, pickerView: egitimPicerView)

            askerlikPicerView = UIPickerView()
            showPicker(for: askerlikDurumu, textField: askerlikText, pickerView: askerlikPicerView)
        
       cinsiyetPicerView = UIPickerView()
        showPicker(for: cinsiyetDurumu, textField: cisiyetText, pickerView: cinsiyetPicerView)
        
        ehliyetPicerView = UIPickerView()
        showPicker(for: ehliyetBilgisi, textField: ehliyetText, pickerView: ehliyetPicerView)
        }

        func showPicker(for options: [String], textField: UITextField, pickerView: UIPickerView) {
            pickerView.delegate = self
            pickerView.dataSource = self
            textField.inputView = pickerView

            
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.sizeToFit()

            let doneButton = UIBarButtonItem(title: "Onayla", style: .done, target: self, action: #selector(pickerDoneButtonTapped))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            toolBar.setItems([spaceButton, doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true

            textField.inputAccessoryView = toolBar
        }

    @objc func pickerDoneButtonTapped() {
        view.endEditing(true)
    }
    
    func getIlanBilgileri() {
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            
            return
        }
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Tecrubeler").whereField("postedBy", isEqualTo: currentUserEmail).addSnapshotListener { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let documents = snapshot?.documents, !documents.isEmpty {
                    
                    self.userEmailArray.removeAll(keepingCapacity: false)
                    self.baslangicArray.removeAll(keepingCapacity: false)
                    self.bitisArray.removeAll(keepingCapacity: false)
                    
                    self.isyeriAdArray.removeAll(keepingCapacity: false)
                    self.PozisyonArray.removeAll(keepingCapacity: false)
                    self.documentIDArray.removeAll(keepingCapacity: false)
                    
                    for document in documents {
                        let documentID = document.documentID
                        
                            self.documentIDArray.append(documentID)
                        
                       
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
                    self.deneyimTableView.reloadData()
                } else {
                    
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isyeriAdArray[indexPath.row]
        return cell
    }
    
    func makeAlert(titleInput:String, messageInput:String) {
           let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
                       let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
                       alert.addAction(okButton)
                       self.present(alert, animated: true, completion: nil)
       }
    
    
    func deletePaintingFromFirestore(documentID: String) {
        let db = Firestore.firestore()
        let paintingsCollection = db.collection("Tecrubeler")

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
            let documentID = documentIDArray[indexPath.row]
            deletePaintingFromFirestore(documentID: documentID)

            
            userEmailArray.remove(at: indexPath.row)
            isyeriAdArray.remove(at: indexPath.row)
            PozisyonArray.remove(at: indexPath.row)
            baslangicArray.remove(at: indexPath.row)
            bitisArray.remove(at: indexPath.row)
            
            deneyimTableView.reloadData()
        }
    }

}
    

