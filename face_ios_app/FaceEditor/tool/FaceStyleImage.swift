import UIKit

class FaceStyleImage: UICollectionView {
    
    var styleNumber = 0
    let titleArr = [
        ["原图", "年龄+2", "性别+2", "微笑+2", "颜值+2"],
        ["年龄+1", "年龄+2", "年龄+3", "年龄-1", "年龄-2", "年龄-3"],
        ["性别+1", "性别+2", "性别+3", "性别-1", "性别-2", "性别-3"],
        ["微笑+1", "微笑+2", "微笑+3", "微笑-1", "微笑-2", "微笑-3"],
        ["颜值+1", "颜值+2", "颜值+3", "颜值-1", "颜值-2", "颜值-3"],
        ]
    let imageArr = [
        ["gansrc","ganage11","gangender11","gansmile11","ganbeauty11"],
        ["ganage10","ganage11","ganage12","ganage00","ganage01","ganage02"],
        ["gangender10","gangender11","gangender12","gangender00","gangender01","gangender02"],
        ["gansmile10","gansmile11","gansmile12","gansmile00","gansmile01","gansmile02"],
        ["ganbeauty10","ganbeauty11","ganbeauty12","ganbeauty00","ganbeauty01","ganbeauty02"],
    ]

    var styleView  : FaceStyleView?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 92, height: 100)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        super.init(frame: .zero, collectionViewLayout: layout)
        
        register(FaceStyleImageCell.self, forCellWithReuseIdentifier: "Suggestion")
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate   = self
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func reloadData() {
        super.reloadData()
        contentOffset = .zero
    }
}

extension FaceStyleImage: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArr[styleNumber].count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Suggestion", for: indexPath) as! FaceStyleImageCell
        cell.label.text = titleArr[styleNumber][indexPath.row]
        cell.imageView.image = UIImage(named: imageArr[styleNumber][indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.styleView?.selectStyleImage(index: indexPath.row, number: self.styleNumber)
    }
}

private class FaceStyleImageCell: UICollectionViewCell {
    let label: UILabel = UILabel()
    let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: 6, y: 0, width: 80, height: 80)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        self.contentView.addSubview(imageView)
        
        label.frame = CGRect(x: 0, y: 88, width: frame.width, height: 14)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
