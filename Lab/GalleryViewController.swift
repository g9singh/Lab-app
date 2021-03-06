//
//  ViewController.swift
//  Lab
//
//  Created by Singh, Gagandeep on 11/8/18.
//  Copyright © 2018 Singh, Gagandeep. All rights reserved.
//

import UIKit

class IndexPathCellButton: UIButton {
    var indexPath:IndexPath?
}



class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var imagesTaken = [UIImage]()
    //selected cells are set to false
    var selectedCells : [Int: Bool] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func reloadData(){
        var i = 0
        for _ in imagesTaken{
            selectedCells[i] = true
            i = i + 1
        }
        self.imagesCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (imagesTaken.count > 0){
            return imagesTaken.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as? collectionViewCell
        let imageView = imagesTaken[indexPath.row]
        cell?.displayContent(image: imageView, isHidden: selectedCells[indexPath.row] ?? true)
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? collectionViewCell
        cell?.selected()
        selectedCells[indexPath.row] = !selectedCells[indexPath.row]!
    }
    

    //check to see if any images have been selected
    //then upload and show user feed back while uploading
    //after upload is complete show user the results
    @IBAction func uploadBtn(_ sender: Any) {
        self.selectedCells.forEach { (arg0) in
            let (key, value) = arg0
            if value {
                print("ready to upload image: " + String(key))
            }
        }
    }
    //check if any images are selected and delete them
    //redraw the scroll view with remaining images
    @IBAction func deleteBtn(_ sender: Any) {
        //TODO: Delete all selectedCells ints outside foreach loop to prevent illegal access while manipulating the array
        //was looking at NSDictionaries becuase they might have  a easier api
        var i = 0
        for (index, value) in self.selectedCells {
            print(index, value)
            if(!value){
                print("deleted")
                imagesTaken.remove(at: index - i)
                //TODO: 
                i = i + 1 // <- the plus i doesn't work after first delete
            }
        }
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "galleryToCamera") {
            if let vc = segue.destination as? CameraViewController{
                vc.previousViewController = self
                vc.imagesTaken = self.imagesTaken
            }
        }
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true)
//
//        guard let image = info[.editedImage] as? UIImage else {
//            debugPrint("No image found")
//            return
//        }
//
//        // print out the image size as a test
//        uploadData(data: (image.jpegData(compressionQuality: 1.0))!)
//        debugPrint(image.size)
//    }
    
    struct responseFS: Decodable {
        let data: String
    }
    
    func uploadData(data: Data) {
        let url = "http://cn.medfirstview.com:10080/iOS_fundus"
        sendFile(urlPath: url, fileName:"one.jpg", data:data, completionHandler:
            { (response: URLResponse?, data: Data?, error: Error?) in
                // this is where the completion handler code goes
                if let response = response {
                    print(response)
                    print(data as Any)
                    guard let temp = try? JSONDecoder().decode(responseFS.self, from: data!) else {
                        print("Error: Couldn't decode data into object")
                        print(String(data: data!, encoding: .utf8) as Any)
                        return
                    }
                     print(temp.data)
                   
                }
                if let error = error {
                    print(error)
                }
        })
    }
    
    //generate a random boundry
    func generateBoundary() -> String{
        var str = ""
        let length = arc4random_uniform(11) + 30
        let charSet = [Character]("-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        
        for _ in 0..<length {
            str.append(charSet[Int(arc4random_uniform(UInt32(charSet.count)))])
        }
        return str
    }
    
    
    func sendFile(
        urlPath:String,
        fileName:String,
        data:Data,
        completionHandler: @escaping (URLResponse?, Data?, Error?) -> ()){
        
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        
        request1.httpMethod = "POST"
        
        let boundary = generateBoundary()
        let fullData = photoDataToFormData(data: data, boundary:boundary, fileName:fileName)
        
        request1.setValue("multipart/form-data; boundary=" + boundary,
                          forHTTPHeaderField: "Content-Type")
        
        // REQUIRED!
        request1.setValue(String(fullData.length), forHTTPHeaderField: "Content-Length")
        
        request1.httpBody = fullData as Data
        request1.httpShouldHandleCookies = false
        
        let queue:OperationQueue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(
            request1 as URLRequest,
            queue: queue,
            completionHandler:completionHandler)
    }
    
    // this is a very verbose version of that function
    // you can shorten it, but i left it as-is for clarity
    // and as an example
    func photoDataToFormData(data:Data,boundary:String,fileName:String) -> NSData {
        let fullData = NSMutableData()
        
        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 3
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
        fullData.append(lineThree.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 4
        fullData.append(data as Data)
        
        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        return fullData
    }
}

