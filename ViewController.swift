//
//  ViewController.swift
//  TextDetect
//
//  Created by Sayalee on 6/13/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Firebase

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detectedText: UITextField!
    
    var model: VNCoreMLModel!
    lazy var vision = Vision.vision()
    var textDetector: VisionTextDetector?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField){
        detectedText.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadModel() {
        model = try? VNCoreMLModel(for: EggDetector().model)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        dismiss(animated: true, completion: nil)
        
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            fatalError("couldn't load image")
        }
        
        imageView.image = image
        
        detectScene(image: image)
    }

    
    func detectScene(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIImage to CIImage")
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.detectedText.text = ""
            }
            if (topResult.identifier == "egg")
            {
                self?.detectText(image: image)
            }
            else
            {
                DispatchQueue.main.async {
                    self?.detectedText.text = "It's not an egg"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    
    @IBAction func photoButtonTapped(_ sender: Any){
            let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {action in
                guard UIImagePickerController.isSourceTypeAvailable(.camera)  else {
                    let alert = UIAlertController(title: "No camera", message: "This device does not support camera.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.delegate = self
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
                self.present(picker, animated: true, completion: nil)
            })
        
            let photoAction = UIAlertAction(title: "Photo", style: .default, handler: {action in
                guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary)  else {
                    let alert = UIAlertController(title: "No photos", message: "This device does not support photos.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            })
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
            optionMenu.addAction(cameraAction)
            optionMenu.addAction(photoAction)
            optionMenu.addAction(cancelAction)
        
            self.present(optionMenu, animated: true, completion: nil)
    }

    func detectText (image: UIImage) {
        textDetector = vision.textDetector()
        let visionImage = VisionImage(image: image)
        
        textDetector?.detect(in: visionImage) { (features, error) in
            guard error == nil, let features = features, !features.isEmpty else {
                return
            }
            
            debugPrint("Feature blocks in th image: \(features.count)")
            
            var detectedText = ""
            for feature in features {
                let value = feature.text
                detectedText.append("\(value) ")
            }
            
            debugPrint(detectedText)
            self.detectedText.text = detectedText
        }
    }
    
    @IBAction func sendText(_ sender: Any) {
        performSegue(withIdentifier: "showSecondView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSecondView"{
            let secondVC = segue.destination as! SecondViewController
            secondVC.data = detectedText.text!
        }
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
