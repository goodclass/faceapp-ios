import UIKit

class FaceStyleLabel: UICollectionView {
    let titleArr = ["热门", "年龄", "性别", "微笑", "颜值"]
    let imageArr = ["lbl_hot", "lbl_age", "lbl_gander", "lbl_smile", "lbl_beauty"]

    var widthConstraint: NSLayoutConstraint?
    var styleView  : FaceStyleView?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 80, height: 80)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        super.init(frame: .zero, collectionViewLayout: layout)
        
        register(FaceStyleLabelCell.self, forCellWithReuseIdentifier: "Suggestion")
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate   = self
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setDefalutSelect(){
        let defaultSelectCell = IndexPath(row: 0, section: 0)
        self.selectItem(at: defaultSelectCell, animated: true, scrollPosition: .left)
    }
}

extension FaceStyleLabel: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArr.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Suggestion", for: indexPath) as! FaceStyleLabelCell
        cell.label.text = titleArr[indexPath.row]
        cell.imageView.image = UIImage(named: imageArr[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.styleView?.selectStyleTitle(index: indexPath.row)
    }
}

private class FaceStyleLabelCell: UICollectionViewCell {
    let label: UILabel = UILabel()
    let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: 16, y: 0, width: 46, height: 46)
        self.contentView.addSubview(imageView)
        
        label.frame = CGRect(x: 0, y: 48, width: frame.width, height: 14)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
