//
//  GirisisverenVc.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 18.12.2023.
//

import UIKit
import CoreData
import Firebase


class GirisisverenVc: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var girisButon: UIButton!
    @IBOutlet weak var sifreText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.delegate = self
        sifreText.delegate = self

               
                girisButon.isEnabled = false
      
      
    }
    
    
    @IBAction func girisButton(_ sender: Any) {
        
        if nameText.text != "" && sifreText.text != "" {
                    
                    Auth.auth().signIn(withEmail: nameText.text!, password: sifreText.text!) { (authdata, error) in
                        if error != nil {
                            self.makeAlert(titleInput: "Hata!", messageInput: "Kulanıcı adı veya şifre hatalı")

                        } else {
                            self.performSegue(withIdentifier: "GirisVc", sender: nil)

                        }
                    }
                    
                    
                } else {
                    makeAlert(titleInput: "Hata!", messageInput: "Kulanıcı adı veya şifre hatalı")

                }
        
        
    }
    

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           
            let kulaniciAd = !(nameText.text?.isEmpty ?? true)
            let kulaniciSifre = !(sifreText.text?.isEmpty ?? true)

           
            girisButon.isEnabled = kulaniciAd && kulaniciSifre

            return true
        }
    
    
    func makeAlert(titleInput:String, messageInput:String) {
           let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
                       let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
                       alert.addAction(okButton)
                       self.present(alert, animated: true, completion: nil)
       }
       
}
