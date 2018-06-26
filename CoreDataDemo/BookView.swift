//
//  BookView.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/19.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit

class BookView: UIView {
    
    init(frame: CGRect, book: Book) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(white: 0.8, alpha: 0.5)
        self.layer.borderColor = UIColor.init(white: 0.7, alpha: 1).cgColor
        self.layer.borderWidth = 1
        
        var image : UIImage!
        let imagePath = self.cachePath() + self.md5(book.imageURL)
        if FileManager.default.fileExists(atPath: imagePath) {
            image = UIImage.init(contentsOfFile: imagePath)
        } else {
            let imageURL = URL.init(string: book.imageURL!)
            let data = try? Data.init(contentsOf: imageURL!)
            image = UIImage.init(data: data! as Data)
            FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
        }
        let imageView = UIImageView.init(image: image)
        self.addSubview(imageView)
        imageView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height - 50)
        
        let label = UILabel.init()
        var name = book.author?.authorName!
        if name == nil {
            name = ""
        }
        
        label.text = "\(book.bookName!)" + ":" + name!
        label.frame = CGRect.init(x: 0, y: self.bounds.size.height - 40, width: self.bounds.size.width, height:30)
        label.textAlignment = .center
        self.addSubview(label)
        
    }
    
    func cachePath() -> String {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return libraryPath
        
    }
    
    func md5(_ string: String?) -> String {
        if string == nil {
            return ""
        }
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string!.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        return hexString
    }

    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
