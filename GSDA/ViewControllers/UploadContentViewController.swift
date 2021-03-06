//
//  UploadImageViewController.swift
//  GSDA
//
//  Created by Work on 25/01/2019.
//  Copyright © 2019 Cearley-Programs. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase
import FirebaseStorage

enum ContentType: String {
    case video = "videos"
    case photo = "photos"
}

class UploadContentViewController: UIViewController {
    
    lazy var selectedImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .myBlue
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openGallery))
        imageView.addGestureRecognizer(gesture)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .center
        return imageView
    }()
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "title here.."
        textField.backgroundColor = .myBlue
        textField.textColor = .white
        textField.font = UIFont.boldSystemFont(ofSize: 20)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.returnKeyType = .done
        textField.delegate = self
        
        return textField
    }()
    
    lazy var descriptionTextField: UITextField = {
        let textField = UITextField()
        
        textField.textColor = .white
        textField.font = UIFont.boldSystemFont(ofSize: 16)
        textField.backgroundColor = .myBlue
        textField.placeholder  = "Description here.."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.layer.cornerRadius = 15
        textField.clipsToBounds = true
        textField.returnKeyType = .done
        textField.delegate = self
        
        return textField
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type:  .system)
        button.backgroundColor = .myBlue
        button.setTitle("DONE", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    
    let pickerController = UIImagePickerController()
    
    @objc func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    var contentType: ContentType = .video
    
    //Variables
    var selectedImage: UIImage?
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        setupSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupSubViews() {
        view.addSubview(titleTextField)
        view.addSubview(selectedImageView)
        view.addSubview(descriptionTextField)
        view.addSubview(doneButton)
        
        titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        titleTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 15).isActive = true
        descriptionTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor).isActive = true
        descriptionTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor).isActive = true
        descriptionTextField.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        selectedImageView.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 15).isActive = true
        selectedImageView.leadingAnchor.constraint(equalTo: descriptionTextField.leadingAnchor).isActive = true
        selectedImageView.trailingAnchor.constraint(equalTo: descriptionTextField.trailingAnchor).isActive = true
        selectedImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        selectedImageView.image = UIImage(named: contentType.rawValue)
    }
    
    @objc func doneButtonPressed() {
        if contentType == .video {
            uploadVideo()
        } else if contentType == .photo {
            uploadImage()
        }
    }
    
    
    func uploadVideo() {
        guard let videoURL = videoUrl, let thumbnailImage = selectedImageView.image else {
            return
        }
        HelperService.uploadVideoToFirebaseStorage(videoUrl: videoURL, thumbnail: thumbnailImage, title: titleTextField.text!, description: descriptionTextField.text!) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func uploadImage() {
        guard let uploadImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(uploadImage, 0.1) else {
            return
        }
        HelperService.uploadImageToFirebaseStorage(data: imageData, title: titleTextField.text!, description: descriptionTextField.text!) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc func openGallery() {
        handleSelectPhoto()
    }
    
    func handleSelectPhoto() {
        pickerController.delegate = self
        if contentType == .video {
            pickerController.mediaTypes = ["public.movie"]
        } else if contentType == .photo {
            pickerController.mediaTypes = ["public.image"]
        }
        present(pickerController, animated: true)
    }
}


extension UploadContentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        print(info)
        
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            // Selected Video
            if let thumbnailImage = thumbnailImageForFileUrl(videoUrl) {
                selectedImage = thumbnailImage
                selectedImageView.image = thumbnailImage
                self.videoUrl = videoUrl
            }
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            // Selected Image
            selectedImage = image
            selectedImageView.image = image
        }
        pickerController.dismiss(animated: true)
    }
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(7, 1), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
}

extension UploadContentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
