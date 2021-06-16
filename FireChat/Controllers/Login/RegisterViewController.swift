//
//  RegisterViewController.swift
//  FireChat
//
//  Created by Дмитро Вакулінський on 10.06.2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .orange
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        navigationItem.rightBarButtonItem?.tintColor = .orange
        self.navigationController?.navigationBar.tintColor = .orange
        
        registerButton.addTarget(self, action: #selector(registerButtonTap), for: .touchUpInside)
        
        emailField.delegate = self
        passField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstField)
        scrollView.addSubview(lastField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePic))
        
        imageView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func changeProfilePic() {
        photoChangeOpen()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 20, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        firstField.frame = CGRect(x: 30, y: imageView.bottom+10, width: scrollView.width-60, height: 52)
        lastField.frame = CGRect(x: 30, y: firstField.bottom+10, width: scrollView.width-60, height: 52)
        emailField.frame = CGRect(x: 30, y: lastField.bottom+10, width: scrollView.width-60, height: 52)
        passField.frame = CGRect(x: 30, y: emailField.bottom+10, width: scrollView.width-60, height: 52)
        registerButton.frame = CGRect(x: 30, y: passField.bottom+10, width: scrollView.width-60, height: 52)
    }
    
    @objc private func registerButtonTap() {
        
        emailField.resignFirstResponder()
        passField.resignFirstResponder()
        firstField.resignFirstResponder()
        lastField.resignFirstResponder()
        
        guard let firstName = firstField.text,
            let lastName = lastField.text,
            let email = emailField.text,
            let password = passField.text,
            !email.isEmpty,
            !password.isEmpty,
            !firstName.isEmpty,
            !lastName.isEmpty,
            password.count >= 6 else {
            loginError()
            return
    }
        
        spinner.show(in: view)
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                strongSelf.loginError(message: "Email address already exists")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {  authResult, error in
                
                guard authResult != nil, error == nil else {
                    print ("Error")
                    return
                }
                let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, email: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: {success in
                    if success {
                        //upload
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: {result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage error \(error)")
                            }
                        })
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
}
    
    func loginError(message: String = "Enter all info to log in") {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }


}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passField.becomeFirstResponder()
        }
        else if textField == passField {
            registerButtonTap()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func photoChangeOpen(){
        let actionSheet = UIAlertController(title: "Profile Photo", message: "How would you like to select picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take photo", style: .default, handler: {[weak self] _ in self?.openCamera()
        
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose photo", style: .default, handler: {[weak self] _ in self?.openPhoto()
        }))
        
        present(actionSheet, animated: true)
        
    }
    
    func openCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func openPhoto() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
