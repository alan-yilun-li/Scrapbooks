//
//  MomentViewController.swift
//  Scrapbook
//
//  Created by Alan Li on 2016-11-19.
//  Copyright © 2016 Alan Li. All rights reserved.
//

import UIKit

class MomentViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var moment: Moment?

    override func viewDidLoad() {
        // We do any additional setup after loading the view
        super.viewDidLoad()
        
        // Will be notified when keyboard shows up (for scrolling)
        registerForKeyboardNotifications()
        self.scrollView.isScrollEnabled = true
    
        // Checking for valid title and photo to enable save button
        checkValidMomentName()
        checkValidPhoto()
        
        // Navigationbar UI Specifications
        let navBarAppearance = self.navigationController?.navigationBar
        navBarAppearance?.isTranslucent = true
        navBarAppearance?.barTintColor = UIColor.lightText
        
        
        // Caption Border
        captionTextView.layer.cornerRadius = 10
        captionTextView.layer.borderColor = UIColor.lightGray.cgColor
        captionTextView.layer.borderWidth = 0.5
        
        // Handles the text field’s user input through delegate callbacks!
        nameTextField.delegate = self
        captionTextView.delegate = self
        scrollView.delegate = self
    
        // Sets up an existing moment if it's being edited
        if let moment = moment {
            // Setting the photoImageView to scale based on the photo
            photoImageView.contentMode = .scaleAspectFit
            
            // Setting the views with the data from the given moment
            navigationItem.title = moment.name
            nameTextField.text   = moment.name
            photoImageView.image = moment.photo
            captionTextView.text = moment.caption
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        deregisterFromKeyboardNotifications()
    }
    
    
    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disables saving when currently editing
        saveButton.isEnabled = false
    }
    
    func checkValidMomentName() {
        // Disables saving if textfield is empty
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func checkValidPhoto() {
        if photoImageView.image!.isEqual(#imageLiteral(resourceName: "DefaultPhoto")) {
            saveButton.isEnabled = false
        }
    }
    
    // This function is called when DONE is pressed on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // This hides the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidMomentName()
        checkValidPhoto()
        navigationItem.title = textField.text
    }
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterCountLimit = 19
        
        // Figuring out how many characters the unaltered string would have
        let startingLength = textFieldToChange.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        return newLength <= characterCountLimit
    }
    
    
    // MARK: UITextViewDelegate
    
    func registerForKeyboardNotifications() {
        // Adding notifies on keyboard appearing
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications(){
        // Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWasShown(_ notification: NSNotification) {
        
        if self.captionTextView.isFirstResponder {
        
            // Need to calculate keyboard exact size due to Apple suggestions
            self.scrollView.isScrollEnabled = true
            let info : NSDictionary = notification.userInfo! as NSDictionary
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            let height = keyboardSize!.height + 25
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0)
        
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        
            var aRect : CGRect = self.view.frame
            aRect.size.height -= height
            
            if let captionTextView = self.captionTextView {
                if (!aRect.contains(captionTextView.frame.origin)) {
                    self.scrollView.scrollRectToVisible(captionTextView.frame, animated: true)
                }
            }
        }
    }
    
    func scrollToTop() {
        let originalpos: CGPoint = CGPoint(x: 0.0, y: 0.0)
        scrollView.setContentOffset(originalpos, animated: true)
    }

    
    func keyboardWillBeHidden(_ notification: NSNotification) {
        scrollToTop()
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        captionTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        captionTextView.text = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") { // This is when DONE is pressed
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func forceHideKeyboard() {
        if self.captionTextView.isFirstResponder {
            self.captionTextView.resignFirstResponder()
        } else if self.nameTextField.isFirstResponder {
            self.nameTextField.resignFirstResponder()
        }
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    
    // This is called when the user clicks the cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Scrolls the scrollview back to the original position
        scrollToTop()
        
        nameTextField.resignFirstResponder()
        captionTextView.resignFirstResponder()
        
        // Dismisses the picker
        dismiss(animated: true, completion: nil)
    }
    
    // This is called when the user has picked a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Sometimes there is also an edited version of the photo: this uses the original!
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Setting the image and scaling the photoImageView accordingly
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.image = selectedImage
        
        // Enables the save button if the photo title is non-empty
        checkValidMomentName()
        
        // Scrolls the scrollview back to the original position
        scrollToTop()
        print("should scroll")
        
        nameTextField.resignFirstResponder()
        captionTextView.resignFirstResponder()
        
        // Dismisses the picker
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        forceHideKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
    // Helps configure a view controller before it's presented
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue starts to be prepared")
        if segue.identifier == "unwindToTableOfContentsID" {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let caption = captionTextView.text ?? ""
            
            // Set the moment to be passed to the table view controller after the segue
            moment = Moment(name: name, photo: photo, caption: caption)
            
            print("segue was prepared properly!")
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        forceHideKeyboard()
        print("programmatic working")
        performSegue(withIdentifier: "unwindToTableOfContentsID", sender: self)
    }
  
    
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Recall, resigning FR status means hiding the keyboard
        
        // UIImagePickerController is a view controller that lets people choose a photo
        let imagePickerController = UIImagePickerController()
        
        // Sets source of the photo
        imagePickerController.sourceType = .photoLibrary
        
        // Assigns ViewController as the delegate (notifies it!)
        imagePickerController.delegate = self
        
        // This gets executed on the "implicit self-object", ViewController & tells it to present the photo
        present(imagePickerController, animated: true, completion: nil)

    }
}

