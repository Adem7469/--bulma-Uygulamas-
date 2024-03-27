//
//  GiriscalisanVC.swift
//  BitirmeProjesi
//
//  Created by Adem Basaran on 22.12.2023.
//

import UIKit
import CoreData
import Firebase
class GiriscalisanVC: UIViewController, UITextFieldDelegate{

    
    @IBOutlet weak var kulaniciText: UITextField!
    
    @IBOutlet weak var GirisButon: UIButton!
    @IBOutlet weak var sifreText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        kulaniciText.delegate = self
        sifreText.delegate = self

                
                GirisButon.isEnabled = false
        
    }
    

    @IBAction func GirisButon(_ sender: Any) {
        
        if kulaniciText.text != "" && sifreText.text != "" {
                    
                    Auth.auth().signIn(withEmail: kulaniciText.text!, password: sifreText.text!) { (authdata, error) in
                        if error != nil {
                            self.makeAlert(titleInput: "Hata!", messageInput: "Kulanıcı adı veya şifre hatalı")

                        } else {
                            self.performSegue(withIdentifier: "GiriscalisanVc", sender: nil)

                        }
                    }
                    
                    
                } else {
                    makeAlert(titleInput: "Hata!", messageInput: "Kulanıcı adı veya şifre hatalı")

                }
        
        
    }
    
   
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           

           
            let KulaniciAd = !(kulaniciText.text?.isEmpty ?? true)
            let KulaniciSifre = !(sifreText.text?.isEmpty ?? true)

           
            GirisButon.isEnabled = KulaniciAd && KulaniciSifre

            return true
        }
    
    func makeAlert(titleInput:String, messageInput:String) {
           let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
                       let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
                       alert.addAction(okButton)
                       self.present(alert, animated: true, completion: nil)
       }
    
}
