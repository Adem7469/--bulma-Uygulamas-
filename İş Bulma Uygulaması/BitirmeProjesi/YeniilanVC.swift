//
//  YeniilanVC.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 23.12.2023.
//

import UIKit
import CoreLocation

import Firebase
import SDWebImage
import FirebaseStorage

class YeniilanVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    let calismaTuruOptions = ["Tam Zamanlı", "Yarı Zamanlı", "Hizmet Sektörü"]
    let maasOptions = ["10.000-15.000", "15.000-20.000", "20.000-25.000", "25.000-30.000", "30.000 ve üzeri"]
        
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var isyeriText: UITextField!
    @IBOutlet weak var pozisyonText: UITextField!
    
    @IBOutlet weak var gorselImageView: UIImageView!
    @IBOutlet weak var yayinlaButon: UIButton!
    
    @IBOutlet weak var adresText: UITextField!
    @IBOutlet weak var pirimSwich: UISwitch!
    @IBOutlet weak var yolSwich: UISwitch!
    @IBOutlet weak var yemekSwich: UISwitch!
    @IBOutlet weak var maasText: UITextField!
    @IBOutlet weak var ayrintiTextView: UITextView!
    @IBOutlet weak var calismaTuruText: UITextField!
    
    let placeholderText = "Çalisan ve iş hakında ayrıntılar veriniz. Örneğin çalışma saatleri , ehliyet durumu"
    var calismaTuruPickerView: UIPickerView!
        var maasPickerView: UIPickerView!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPickerViews()
        setupTextView()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKetboardn))
        view.addGestureRecognizer(gestureRecognizer)
        
        gorselImageView.isUserInteractionEnabled = true
        let imageTepRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        gorselImageView.addGestureRecognizer(imageTepRecognizer)
        
    }
    
    
    func setupPickerViews() {
            calismaTuruPickerView = UIPickerView()
            showPicker(for: calismaTuruOptions, textField: calismaTuruText, pickerView: calismaTuruPickerView)

            maasPickerView = UIPickerView()
            showPicker(for: maasOptions, textField: maasText, pickerView: maasPickerView)
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

    func setupTextView() {
            ayrintiTextView.text = placeholderText
            ayrintiTextView.textColor = UIColor.lightGray
            ayrintiTextView.delegate = self
        
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == placeholderText {
                textView.text = ""
                textView.textColor = UIColor.black
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholderText
                textView.textColor = UIColor.lightGray
            }
        }

        
    func textViewDidChange(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholderText
                textView.textColor = UIColor.lightGray
            }
        }

       
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView == calismaTuruPickerView {
                return calismaTuruOptions.count
            } else if pickerView == maasPickerView {
                return maasOptions.count
            }
            return 0
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerView == calismaTuruPickerView {
                return calismaTuruOptions[row]
            } else if pickerView == maasPickerView {
                return maasOptions[row]
            }
            return nil
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if pickerView == calismaTuruPickerView {
                calismaTuruText.text = calismaTuruOptions[row]
            } else if pickerView == maasPickerView {
                maasText.text = maasOptions[row]
            }
        }
   
    
    @IBAction func yayinlaButton(_ sender: Any) {
        
        
        guard let userUID = Auth.auth().currentUser?.uid else {
            
            makeAlert(titleInput: "Hata!", messageInput: "Oturum açmış bir kullanıcı bulunamadı.")
            return
        }
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("Kaynaklar")
        
        
        if let data = gorselImageView.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                } else {
                    
                    imageReference.downloadURL { (url, error) in
                        
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString
                            
                            let db = Firestore.firestore()
                            var firestoreReference : DocumentReference? = nil
                            
                            let isyeri = self.isyeriText.text ?? ""
                            let calismaTuru = self.calismaTuruText.text ?? ""
                            let pozisyon = self.pozisyonText.text ?? ""
                            let ayrinti = self.ayrintiTextView.text ?? ""
                            let adres = self.adresText.text ?? ""
                            let maas = self.maasText.text ?? ""
                            let pirim = self.pirimSwich.isOn
                            let yol = self.yolSwich.isOn
                            let yemek = self.yemekSwich.isOn
                            
                            let ilanData: [String: Any] = [
                                "calismaTuru": calismaTuru,
                                "pozisyon": pozisyon,
                                "ayrinti": ayrinti,
                                "adres": adres,
                                "maas": maas,
                                "pirim": pirim,
                                "yol": yol,
                                "yemek": yemek,
                                "date" : FieldValue.serverTimestamp(),
                                "isyeriAdi": isyeri,
                                "kulaniciId": userUID,
                                "postedBy" : Auth.auth().currentUser!.email!,
                                "imageUrl": imageUrl!
                            ]
                            
                            
                            firestoreReference = db.collection("kIlanlar").addDocument(data: ilanData, completion: { (error) in
                               
                                
                               
                                if let error = error {
                                    self.makeAlert(titleInput: "Hata!", messageInput: error.localizedDescription)
                                } else {
                                    self.makeAlert(titleInput: "Başarı", messageInput: "İlan başarıyla yayınlandı.")
                                    self.calismaTuruText.text = ""
                                    self.adresText.text = ""
                                    self.ayrintiTextView.text = ""
                                    self.maasText.text = ""
                                    self.pozisyonText.text = ""
                                    self.isyeriText.text = ""
                                  
                                    
                                }
                            })
                            
                            
                        }
                    }
                }
            }
        }
    }
    
   
    
    @IBAction func konumButton(_ sender: Any) {
        
        locationManager.requestLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           if let location = locations.first {
               
               reverseGeocode(location: location)
           }
       }

       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           makeAlert(titleInput: "Hata!", messageInput: "Konum bilgisi alınırken hata olustu: \(error.localizedDescription)")
       }

       func reverseGeocode(location: CLLocation) {
           let geocoder = CLGeocoder()
           geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
               if let error = error {
                   self.makeAlert(titleInput: "Hata!", messageInput: "Bir hata olustu: \(error.localizedDescription)")
                   return
               }

               if let placemark = placemarks?.first {
                   
                   let address = "\(placemark.locality ?? ""), \(placemark.subLocality ?? ""), \(placemark.thoroughfare ?? "")"
                   self.adresText.text = address
               }
           }
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
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
           gorselImageView.image = image
            selectedImage = image
            yayinlaButon.isEnabled = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
