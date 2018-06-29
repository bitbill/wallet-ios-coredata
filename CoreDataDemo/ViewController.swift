//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by BitBill on 2018/6/14.
//  Copyright © 2018 BitBill. All rights reserved.
//

import UIKit
import CoreGraphics

enum DisplayMode {
    case Author
    case Book
}
let bil_bookManager = BILCoreDataModelManager<Book>()
let bil_authorManager = BILCoreDataModelManager<Author>()
class ViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var segView: UIView!
    @IBOutlet weak var authorButton: UIButton!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var totalCount: UITextField!
    @IBOutlet weak var threadCount: UITextField!
    @IBOutlet weak var insertCountPerThread: UITextField!
    
    var totalC :Int! = 4
    var threadC:Int! = 4
    var insertCPerThread:Int!  = 3
    
    var displayMode : DisplayMode = .Author
    
    @IBAction func refresh(_ sender: Any) {
        self.reloadData()
    }
    
    func contactDidChanged(_: NSNotification) {
        print("receive notification")
    }
    
    @IBAction func addItem(_ sender: Any)
    {
        totalC = Int(self.totalCount.text!)
        threadC = Int(self.threadCount.text!)
        insertCPerThread = Int(self.insertCountPerThread.text!)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(contactDidChanged), name:.contactDidChanged, object: nil)
        bil_contactManager.performAsync({
            let name = "ST"
            let contactModel : ContactModel = bil_contactManager.newModelIfNeeded(key: "name", value: name)
            contactModel.name = name
            contactModel.walletID = "aaafeee"
        }) { (error) in
            print("insert contact")
        }
        
        
        let manager = bil_bookManager
        for _ in 0..<threadC {
            manager.performAsync({
                for _ in 0..<self.insertCPerThread {
                    do {
                        let bookId = Int32(Int(arc4random()) % self.totalC)
                        var book : Book? =  bil_bookManager.fetch(key: "bookId", value: "\(bookId)")
                        if book == nil {
                            book = bil_bookManager.newModel()
                        }
                        book?.imageURL = self.imageURLArray()[Int(arc4random()%10)]
                        book?.bookName = self.randomStringWith(5).capitalized
                        book?.bookId = bookId
                        
                        let authorId = Int32(arc4random() % 4)
                        var author : Author? = bil_authorManager.fetch(key: "authorId", value: "\(authorId)")
                        if author == nil {
                            author = bil_authorManager.newModel()
                        }
                        author?.authorId = authorId
                        author?.authorName = self.authorName()[Int(authorId)]
                        
                        if book?.author == nil {
                            book?.author = author
                            author?.addToBooks(book!)
                        }
                        try Thread.current.context?.save()
                    } catch {
                        
                    }
                }
            }) { (error) in
                print(error?.localizedDescription ?? "")
                self.reloadData()
            }
            
        }
    }

    @IBAction func clickMenu(_ sender: Any)
    {
        let animation = CABasicAnimation.init(keyPath: "transform")
        animation.duration = 0.3
        
        let fromValue = NSValue(caTransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0))
        let toVale = NSValue(caTransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0))
        animation.fromValue = menuView.isHidden ?toVale : fromValue
        animation.toValue = menuView.isHidden ? fromValue : toVale
        self.menuView.layer.add(animation, forKey: nil)
        if menuView.isHidden {
            menuView.isHidden = !menuView.isHidden
        } else {
            
            self .perform(#selector(hideMenuView), with: nil, afterDelay: 0.3)
        }
        
    }
    
    @objc func hideMenuView() {
        menuView.isHidden = !menuView.isHidden
    }
    
    
    @IBAction func clean(_ sender: Any)
    {
        let authors : [Author] = bil_authorManager.mainContext.fetchModel(BILFetchRequest())
        for author in authors  {
            try? bil_authorManager.remove(model:author)
        }
        
        let books : [Book] = bil_bookManager.mainContext.fetchModel(BILFetchRequest())
        for book in books  {
            try? bil_bookManager.remove(model:book)
        }
        try? bil_bookManager.saveModels()
        self .reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.totalCount.text = String(totalC)
        self.threadCount.text = String(threadC)
        self.insertCountPerThread.text = String(insertCPerThread)
        segView.layer.borderColor = UIColor.brown.cgColor
        segView.layer.borderWidth = 1
        segView.layer.cornerRadius = 5
        self.authorButton.isSelected = true
        self.authorButton.setBackgroundImage(self.imageWith(UIColor.cyan, size: self.authorButton.frame.size), for: UIControlState.selected)
        self.authorButton.addTarget(self, action:#selector(handleAuthor), for: .touchUpInside)
        
        self.bookButton.setBackgroundImage(self.imageWith(UIColor.cyan, size: self.bookButton.frame.size), for: UIControlState.selected)
        self.bookButton.addTarget(self, action: #selector(handleBook), for: .touchUpInside)
        self .reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func reloadData() {
        for view in self.scrollView.subviews {
            if view is BookView || view is AuthorButton {
                view .removeFromSuperview()
            }
        }
        switch displayMode {
        case .Book:
            self.showAllBooks()
        default:
            self.showAllAuthors()
        }
    }
    
    func showAllBooks() {
        let allBooks : [Book] = bil_bookManager.mainContext.fetchModel(BILFetchRequest())
        let width = UIScreen.main.bounds.size.width/3 - 27
        let height = width * 1.5
        for i in 0..<allBooks.count {
            let book : Book = allBooks[i]
            let col = i % 3
            let row = i / 3
            let bookView = BookView.init(frame: CGRect.init(x: CGFloat(col) * (width + 20) + 20, y: 20 + CGFloat(row) * (height + 20), width: width, height: height), book: book)
            self.scrollView.addSubview(bookView)
            self.scrollView.contentSize = CGSize.init(width: self.scrollView.contentSize.width, height: bookView.frame.maxY)
        }
    }
    
    func showAllAuthors() {
        let allAuthors : [Author] = bil_authorManager.mainContext.fetchModel(BILFetchRequest())
        let width = UIScreen.main.bounds.size.width/3 - 27
        let height = width * 1.5
        for i in 0..<allAuthors.count {
            let author : Author = allAuthors[i]
            let col = i % 3
            let row = i / 3
            let authorButton = AuthorButton.init(frame: CGRect.init(x: CGFloat(col) * (width + 20) + 20, y: 20 + CGFloat(row) * (height + 20), width: width, height: height), author: author)
            self.scrollView.contentSize = CGSize.init(width: self.scrollView.contentSize.width, height: authorButton.frame.maxY)
            self.scrollView.addSubview(authorButton)
        }
    }
    
    
    func imageURLArray() -> Array<String> {
        return [
            "http://pic.58pic.com/58pic/17/67/89/5577eeda7f361_1024.jpg",
            "http://pic.58pic.com/58pic/16/99/07/75D58PICmVG_1024.jpg",
            "http://pic.58pic.com/01/03/63/71bOOOPICef.jpg",
            "http://pic1.16pic.com/00/06/68/16pic_668787_b.jpg",
            "http://pic2.ooopic.com/12/32/16/39bOOOPIC8b_1024.jpg",
            "http://img05.tooopen.com/images/20141121/sy_75467713863.jpg",
            "http://pic2.ooopic.com/12/22/24/15bOOOPIC99_1024.jpg",
            "http://pic2.ooopic.com/12/23/37/61bOOOPICf0_1024.jpg",
            "http://pic.58pic.com/58pic/17/05/67/84s58PICr64_1024.jpg",
            "http://pic2.ooopic.com/13/23/35/82b1OOOPIC03.jpg"
        ]
    }
    
    func authorName() -> Array<String> {
        return [
            "Po",
            "Ma",
            "Sq",
            "Wi"
        ]
    }

    @objc func handleAuthor() {
        if displayMode == .Author {
            return
        }
        self.authorButton.isSelected = true
        self.bookButton.isSelected = false
        displayMode = .Author
        self.reloadData()
    }
    
    @objc func handleBook() {
        if displayMode == .Book {
            return
        }
        self.authorButton.isSelected = false
        self.bookButton.isSelected = true
        displayMode = .Book
        self.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageWith(_ color:UIColor, size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        let fillRect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        context!.setFillColor(color.cgColor)
        context!.fill(fillRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    let letters : String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    func randomStringWith(_ length: Int) -> String {
        var string : String = ""
        for _ in 0...length {
            string = string + String(arc4random_uniform(UInt32(3)))
        }
        let start = string.index(string.startIndex, offsetBy: 0)
        let end = string.index(string.startIndex, offsetBy: length)
        return String(string[start..<end])
    }
    


}

