import UIKit

class FaceMainImage : UICollectionView {

    var mainView  : FaceMainView?
    var beanSet = [MainBean]()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width/3.0-3
        print(width, width)
        layout.estimatedItemSize = CGSize(width: width, height: width)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        super.init(frame: .zero, collectionViewLayout: layout)
        
        register(FaceMainImageCell.self, forCellWithReuseIdentifier: "Suggestion")
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate   = self
        alwaysBounceVertical = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


extension FaceMainImage: UICollectionViewDataSource, UICollectionViewDelegate {

    public func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.beanSet.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Suggestion", for: indexPath) as! FaceMainImageCell
        let bean = beanSet[indexPath.row]
        cell.imageView.image = UIImage(contentsOfFile: bean.imagePath!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == beanSet.count-1 {
            let takingPicture =  UIImagePickerController.init()
            takingPicture.sourceType = .photoLibrary
            takingPicture.allowsEditing = false
            takingPicture.delegate = self.mainView
            DispatchQueue.main.async {
                self.mainView?.present(takingPicture, animated: true, completion: nil)
            }
        }else{
            let styleView = FaceStyleView()
            let bean = beanSet[indexPath.row]
            styleView.sourceImagePath = bean.imagePath
            styleView.sourceLatent = bean.latentPath
            styleView.currentImage = UIImage(contentsOfFile: bean.imagePath!)
            styleView.currentLatent = bean.latentPath
            let style = UINavigationController(rootViewController: styleView)
            style.modalPresentationStyle = .fullScreen
            style.modalTransitionStyle = .crossDissolve
            DispatchQueue.main.async {
                self.mainView?.present(style, animated: true, completion: nil)
            }
        }
    }
}

private class FaceMainImageCell: UICollectionViewCell {
    var imageView: UIImageView
    
    override init(frame: CGRect) {
        self.imageView = UIImageView()
        super.init(frame: frame)
        imageView.frame.size = frame.size
        self.contentView.addSubview(imageView)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
