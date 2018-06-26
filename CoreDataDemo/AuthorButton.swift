//
//  AuthorButton.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/19.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit

class AuthorButton: UIButton {

    
    init(frame: CGRect, author: Author) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.purple
        self.layer.borderColor = UIColor.init(white: 0.7, alpha: 1).cgColor
        self.layer.borderWidth = 1
        let button = UIButton.init(frame: self.bounds)

        button.setTitle(author.authorName! + "-" + "\((String((author.books?.count)!)))", for: .normal)
        button.titleLabel?.textAlignment = .center
        self.addSubview(button)
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
