# <center>![BitRecord]</center>


## What is BitRecord?
BitRecord means 'BitBill Coredata Record'. BitRecord is Protocol Oriented Programming in Swift for CoreData, it consult the github Project named 'SugarRecord(MIT License)'

## Features
- Swift 3.2 compatible (Xcode 10.0).
- Protocols based design.
- For **beginners** and **advanced** users
- Fully customizable. Build your own stack!
- Friendly syntax (fluent)
- Away from Singleton patterns! No shared states :tada:

## Setup

### [CocoaPods](https://cocoapods.org)

1. Install [CocoaPods](https://cocoapods.org). You can do it with `gem install cocoapods`
2. Edit your `Podfile` file and add the following lines

```Podfile
source ‘https://github.com/bitbill/wallet-ios-coredata.git’
target 'XXX' do
  pod 'BitRecord', '~>1.2.0'
end
```

3. Update your pods with the command `pod install`
4. Open the project from the generated workspace (`.xcworkspace` file).


# How to use

#### Creating your Manager
A storage represents your database. The first step to start using SugarRecord is initializing the storage. SugarRecord provides a default storages, `CoreDataDefaultStorage`.

```swift
// Initializing ModelManager
class ModelManager: NSObject, ModelManagerProtocol {

init(main : Bool) {
    if main {
        self.context = self.container.viewContext
    } else {
        let privateContext : NSManagedObjectContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.context = privateContext
    }
}

```


#### ContextProtocol
For curious developers, in case of CoreData a contextProtocol is a wrapper around `NSManagedObjectContext`. The available contexts are:

- **MainContext:** Use it for main thread operations, for example fetches whose data will be presented in the UI.
- **PrivateContext:** Use this context for background operations. That context is used for manager operations.

#### Fetching data

```swift
var author : Author? = try! context.fetch(BILFetchRequest().filtered(with: "authorId", equalTo: "\(authorId)")).first
let tasks: [Task] = try! context.fetch(BILFetchRequest())
let citiesByName: [City] = try! context.fetch(BILFetchRequest().sorted(with: "name", ascending: true))
```

#### Remove/Insert/Update operations

You can use the `operation` method provided by the ModelManager for operations that imply modifications of the database models:

- **Context**: You can use it for fetching, inserting, deleting. Whatever you need to do with your data.
- **Save**: All the changes you apply to that context are in a memory state unless you call the `save()` method. That method will persist the changes to your store and propagate them across all the available contexts.

```swift
manager.perform({ (context, save) in
    do {
        //try something
        let newTask: Track = try context.new()
        newTask.name = "Make CoreData easier!"
        try context.insert(newTask)
        save()
    } catch {
        //handle error
    }
}, completion: { (error) in
    //This is the completion block, not the error exception 
    //Always main thread, you can update UI here
})
```

## License
The MIT License (MIT)

Copyright (c) 2017 Caramba

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
