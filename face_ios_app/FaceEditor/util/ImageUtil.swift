
import Foundation



extension UIImage {
    
    func resize(_ width: CGFloat) -> UIImage? {
        if self.size.width <= width{
            return self
        }
        let size = CGSize(width: width, height: width/self.size.width*self.size.height )
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
