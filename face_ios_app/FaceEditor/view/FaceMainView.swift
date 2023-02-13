
import UIKit

class FaceMainView: UIViewController {
    
    let docPath = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("face_latent")
    let mainImage:FaceMainImage = FaceMainImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        mainImage.frame = self.view.frame
        mainImage.mainView = self
        mainImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainImage.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.view.addSubview(mainImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !FileManager.default.fileExists(atPath: docPath.path) {
            if let testUrl:URL = Bundle.main.resourceURL?.appendingPathComponent("face_latent") {
                try? FileManager.default.copyItem(at: testUrl, to: docPath)
            }
        }
        
        self.doReloadData()
    }
    
    func doReloadData() {
        var beanSet  = [MainBean]()
        for file in try! FileManager.default.contentsOfDirectory(atPath: docPath.path).sorted(){
            let latentPath = docPath.appendingPathComponent(file)
            if latentPath.pathExtension == "pt" {
                let imagePath = latentPath.deletingPathExtension().appendingPathExtension("jpg")
                if FileManager.default.fileExists(atPath: imagePath.path) {
                    let bean = MainBean()
                    bean.latentPath = latentPath.path
                    bean.imagePath = imagePath.path
                    beanSet.append(bean)
                }
            }
        }
        let bean = MainBean()
        bean.imagePath = Bundle.main.resourceURL?.appendingPathComponent("add_image.jpg").path
        beanSet.append(bean)
        mainImage.beanSet = beanSet
        DispatchQueue.main.async {
            self.mainImage.reloadData()
        }
    }
    
    func doBuildImage(_ decodedData:NSData, latent_id:String) {
        let imagePath = docPath.appendingPathComponent(latent_id).appendingPathExtension("jpg")
        let latentPath = docPath.appendingPathComponent(latent_id).appendingPathExtension("pt")
        try? decodedData.write(toFile: latentPath.path, options: .atomic)
        if FileManager.default.fileExists(atPath: latentPath.path) {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show(withStatus: "开始照片生成")
            
            DispatchQueue.global().async {
                let image = TorchUtil.share().buildImage(latentPath.path, latent: 0, value: 0)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    try? image?.jpegData(compressionQuality: 0.9)?.write(to: imagePath)
                    self.doReloadData()
                }
            }
        }
    }

    func doUploadImage(_ image:UIImage) {
        let upImage = image.resize(1280)
        if let imageStr = upImage?.jpegData(compressionQuality: 0.9)?.base64EncodedString() {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show(withStatus: "开始照片处理")
            
            DispatchQueue.global().async {
                let url = "http://\(AccountUtil.WS_SERVER)/latentupload"
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "POST"
                
                let receipt = imageStr
                
                let body = "receipt=\(receipt)"
                request.httpBody = body.data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()

                        if (error != nil || data == nil) {
                            SVProgressHUD.showError(withStatus: "connect sever faile", maskType: .none)
                            return
                        }

                        if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? Dictionary<String,Any>{
                            let ret : Int = jsonResult["ret"] as! Int
                            if ret == 0 {
                                let latent_id : String = String(arc4random_uniform(20000))
                                let latent_data : String = jsonResult["latent_data"] as! String
                                if let decodedData = NSData(base64Encoded:latent_data, options:NSData.Base64DecodingOptions()){
                                    self.doBuildImage(decodedData, latent_id: latent_id)
                                }
                            }else{
                                let message : String = jsonResult["message"] as! String
                                SVProgressHUD.showError(withStatus: message, maskType: .none)
                            }
                        }
                    }
                })
                task.resume()
            }
        }
    }
}

extension FaceMainView:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey:Any]){
        if let originalImage = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.doUploadImage(originalImage)
            }
        }
    }
}
