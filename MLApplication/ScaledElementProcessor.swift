//
//  ScaledElementProcessor.swift
//  MLApplication
//
//  Created by monitora on 07/08/19.
//  Copyright © 2019 Haroldo Leite. All rights reserved.
//

import Firebase

class ScaledElementProcessor {
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
    
    init() {
        self.textRecognizer = vision.cloudTextRecognizer()
    }
    
    func process(in imageView: UIImageView, callback: @escaping (_ text: DriverLicenseData?) -> Void) {
        guard let image = imageView.image else {
            return
        }
        
        let visionImage = VisionImage(image: image)
        
        self.textRecognizer.process(visionImage) { (result, error) in
            guard error == nil, let result = result, !result.text.isEmpty else {
                callback(nil)
                return
            }
            
            var driverLicense: DriverLicenseData = DriverLicenseData()
            
            var nameIsNext = false
            var cpfIsNext = false
            var filiacaoIsNext = false
            
            for block in result.blocks {
                
                // NAME
                if nameIsNext {
                    driverLicense.name = block.text
                    print(block.frame)
                    nameIsNext = false
                }
                
                if block.text.contains("NOME") {
                    nameIsNext = true
                }
                
                // RG + ORGAO EMISSOR
                if block.text.contains("EMISSOR") {
                    for line in block.lines {
                        if !line.text.contains("EMISSOR") {
                            if let rg = line.elements[0].text as? String, let orgaoEmss = line.elements[1].text as? String {
                                driverLicense.idDocNumber = rg.components(separatedBy:CharacterSet.decimalDigits.inverted).joined(separator: "")
                                driverLicense.emissor = orgaoEmss
                                print(line.elements[0].frame)
                                print(line.elements[1].frame)
                            }
                        }
                    }
                }
                
                //CPF + DATA NASCIMENTO
                if cpfIsNext {
                    driverLicense.cpfNumber =  String(block.text.prefix(14))
                    driverLicense.bornDate = String(block.text.suffix(10))
                    cpfIsNext = false
                }
                
                if block.text.contains("CPF") {
                    cpfIsNext = true
                }
                
                
                // FILIACAO
//                if filiacaoIsNext {
//                    pai =  block.text
//
//                    for line in block.lines {
//                        pai.append(line.text)
//                    }
//
//                    filiacaoIsNext = false
//                }
//
//                if block.text.contains("FILIA") {
//                    filiacaoIsNext = true
//                }
            }
            
            callback(driverLicense)
        }
    }
}
