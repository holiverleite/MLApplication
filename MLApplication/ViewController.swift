//
//  ViewController.swift
//  MLApplication
//
//  Created by monitora on 07/08/19.
//  Copyright © 2019 Haroldo Leite. All rights reserved.
//

import UIKit

struct DriverLicenseData {
    var name: String = ""
    var idDocNumber: String = ""
    var emissor: String = ""
    var cpfNumber: String = ""
    var bornDate: String = ""
    
    init() {}
}

class ViewController: UIViewController {
    
    @IBOutlet weak var dataView: UIView! {
        didSet {
            self.dataView.isHidden = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rgLabel: UILabel!
    @IBOutlet weak var emissorLabel: UILabel!
    @IBOutlet weak var cpfLabel: UILabel!
    @IBOutlet weak var bornDateLabel: UILabel!
    
    @IBOutlet weak var loaderView: UIView! {
        didSet {
            self.loaderView.isHidden = true
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            self.activityIndicator.isHidden = true
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            self.imageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var takePictureButton: UIButton! {
        didSet {
            self.takePictureButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func changeLoaderState() {
        if self.loaderView.isHidden {
            self.loaderView.isHidden = false
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.loaderView.isHidden = true
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func openCamera() {
        
        self.dataView.isHidden = true
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        #if targetEnvironment(simulator)
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        #else
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        #endif
        
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
        }
        
        self.changeLoaderState()
        
        let processor = ScaledElementProcessor()
        processor.process(in: self.imageView) { (driverData) in
            self.changeLoaderState()
            
            guard let driverLicense = driverData else {
                return
            }
            
            self.nameLabel.text = driverLicense.name
            self.rgLabel.text = driverLicense.idDocNumber
            self.emissorLabel.text = driverLicense.emissor
            self.cpfLabel.text = driverLicense.cpfNumber
            self.bornDateLabel.text = driverLicense.bornDate

            self.dataView.isHidden = false
            
//            let alert = UIAlertController(title: "Content of Image", message: "\(text)", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: nil))
            
//            self.present(alert, animated: true, completion: nil)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}


