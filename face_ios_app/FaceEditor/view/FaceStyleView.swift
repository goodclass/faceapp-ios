import Foundation
import UIKit

class FaceStyleView: UIViewController {
    let window = UIApplication.shared.windows.first{$0.isKeyWindow}
    let styleLabel: FaceStyleLabel = FaceStyleLabel()
    let styleImage: FaceStyleImage = FaceStyleImage()
    let imageView : UIImageView = UIImageView()
    
    var sourceLatent: String?
    var sourceImagePath: String?
    var currentLatent: String?
    var currentImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.toolbar.tintColor = .black
        navigationController?.isToolbarHidden=false
        self.view.backgroundColor = .white

        let myWidth = self.view.frame.width; let myHeight = self.view.frame.height
        let subHeight:CGFloat = 120
        let subY = myHeight-subHeight-window!.safeAreaInsets.bottom-(self.navigationController?.toolbar.frame.height)!
        imageView.frame = CGRect(x: 0, y: 0, width: myWidth, height: myWidth)
        imageView.center = CGPoint(x: self.view.center.x, y: self.view.center.y-subHeight/2.0)
        self.view.addSubview(imageView)
        
        // 控制视图
        let subView = UIView(frame: CGRect(x: 0, y: subY, width: myWidth, height: subHeight))
        self.view.addSubview(subView)
        
        styleLabel.styleView = self
        styleLabel.frame = CGRect(x: 0, y: 40, width: myWidth, height: 80)
        styleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subView.addSubview(styleLabel)
        
        styleImage.styleView = self
        styleImage.frame = CGRect(x: 0, y: 0, width: myWidth, height: 100)
        styleImage.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subView.addSubview(styleImage)
        styleImage.isHidden = true
        imageView.image = currentImage
        
        addNavBar()
        addToolBar()
    }
    
    func addNavBar() {
        self.title = "编辑器"
        let backBtn = UIBarButtonItem(image: UIImage(named: "bar_back"), style: .plain, target: self, action: #selector(doBack))
        self.navigationItem.leftBarButtonItem = backBtn
        let saveBtn = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(doSave))
        self.navigationItem.rightBarButtonItem = saveBtn
    }
    
    func addToolBar() {
        let cancel = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        let deletes = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(deletes))
        let conform = UIBarButtonItem(title: "应用", style: .done, target: self, action: #selector(conform))
        let fx = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.toolbarItems = [cancel,fx, deletes,fx, conform]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func doBack(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func doSave(){
        if let image = self.imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageBack(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    @objc func imageBack(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if (error as NSError?) != nil {
            doShowError("保存相册失败")
        } else {
            doShowInfo("保存相册成功")
        }
    }
    
    func doShowError(_ info : String) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showError(withStatus: info)
    }
    func doShowInfo(_ info : String) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showInfo(withStatus: info)
    }

    @objc func cancel(){
        if styleLabel.isHidden {
            styleLabel.isHidden = false
            styleImage.isHidden = true
            imageView.image = currentImage
        }
    }
    @objc func conform(){

        if styleLabel.isHidden {
            styleLabel.isHidden = false
            styleImage.isHidden = true
            let TempPath = NSTemporaryDirectory() as String
            let latentPath = TempPath + "/newlatent.pt"
            if TorchUtil.share().saveLatent(latentPath) {
                currentLatent = latentPath
                currentImage = imageView.image
            }
        }
    }
    @objc func deletes(){
        let alertController = UIAlertController(title: "提示", message: "您确定要删除？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: { action in
            try? FileManager.default.removeItem(atPath: self.sourceLatent!)
            try? FileManager.default.removeItem(atPath: self.sourceImagePath!)
            self.doBack()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func selectStyleTitle(index: Int) {
        styleLabel.isHidden = true
        styleImage.isHidden = false
        styleImage.styleNumber = index
        styleImage.reloadData()
    }
    
    func selectStyleImage(index: Int, number: Int) {
        var cLatent = self.currentLatent
        var latent = number
        var value:Float = Float(index)
        if(number==0 && index==0){
            cLatent = self.sourceLatent
        }else if (number == 0) {
            latent = index; value = 3;
        }else{
            let value_data = [1.5,3,4.5,-1.5,-3,-4.5]
            value = Float(value_data[index])
        }
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        
        DispatchQueue.global().async {
            let image = TorchUtil.share().buildImage(cLatent, latent: latent, value: value)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.imageView.image = image
            }
        }
    }
}
