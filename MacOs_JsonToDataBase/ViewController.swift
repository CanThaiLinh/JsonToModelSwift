//
//  ViewController.swift
//  MacOs_JsonToDataBase
//
//  Created by thailinh on 4/19/19.
//  Copyright © 2019 thailinh. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    var data = [String]()
    var classNameDeclare = [String]()
    var dataRealm = [String]()
    var selectedFolder: URL?
    var listKeyWord =
    [
    "class",
    "operator",
    "deinit",
    "enum",
    "extension",
    "func",
    "import",
    "init",
    "let",
    "protocol",
    "static",
    "struct",
    "subscript",
    "typealias",
    "var",
    "break",
    "case",
    "continue",
    "default",
    "do",
    "else",
    "fallthrough",
    "if",
    "in",
    "for",
    "return",
    "switch",
    "where",
    "while",
    "as",
    "is",
    "new",
    "super",
    "self",
    "Self",
    "Type",
    "associativity",
    "didSet",
    "get",
    "infix",
    "inout",
    "mutating",
    "nonmutating",
    "operator",
    "override",
    "postfix",
    "precedence",
    "prefix",
    "set",
    "unowned",
    "weak",
    "Any",
    "AnyObject"
    ]
    var listDataTypeKeyWord =
        [
            "data",
            "date",
            "string",
            "int",
            "double",
            "float",
            "color",
            "var",
            "weak",
            "strong"
            ]
    @IBOutlet weak var cbxUseDB: NSButton!
    @IBOutlet var txvView: NSTextView!
    @IBOutlet weak var txtRootClassName: NSTextField!
    @IBOutlet weak var txtPrefix: NSTextField!
    @IBOutlet weak var txtUrl: NSTextField!
    @IBOutlet weak var txvLog: NSTextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let url = UserDefaults.standard.url(forKey: "kSelectedFolder"){
            self.selectedFolder = url
            self.txtUrl.stringValue = self.selectedFolder?.path ?? ""
        }
        let dateFirst = UserDefaults.standard.double(forKey: "dateFirst")
        if dateFirst <= 0{
            let dateF = Date().timeIntervalSince1970
            UserDefaults.standard.set(dateF, forKey: "dateFirst")
            print("First date = \(dateF)")
            UserDefaults.standard.synchronize()
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    //MARK: -Action
    @IBAction func btnConvertPress(_ sender: Any) {
        let jsonText = txvView.string
        let dic = self.convertStringToDictionary(jsonText: jsonText)
        let fileName = (self.txtRootClassName.stringValue != nil && self.txtRootClassName.stringValue != "" ) ? self.txtRootClassName.stringValue : "CTLClass"
        self.genCode(key: fileName, dic: dic)
        let isUseDB : Bool = cbxUseDB.state.rawValue == 1 ? true : false
        if isUseDB{
            data.append(contentsOf: dataRealm)
        }
        
        self.writeToDesktop(list: data)
//        self.writeToDesktop(list: dataRealm)
        
        
    }
    @IBAction func btnSelecteFolder(_ sender: Any) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                self.selectedFolder = panel.urls[0]
                self.txtUrl.stringValue = self.selectedFolder?.path ?? ""
                UserDefaults.standard.set(self.selectedFolder, forKey: "kSelectedFolder")
                UserDefaults.standard.synchronize()
                
            }
        }
    }
    
    
    func convertStringToDictionary(jsonText: String)-> [String : Any]{
        if let data = jsonText.data(using: String.Encoding.utf8){
            if let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments){
                return dic as! [String : Any]
            }
        }
        print(" Khong phai json")
        self.showLog(log: "Khong phai json")
        return [String : Any]()
    }
    
    func genCode(key : String, dic : [String : Any]){
        data = [String]()
        dataRealm = [String]()
        data.append(self.convertJsonToObject(key: key, dic: dic, listRequireProperty: [String]() ) )
    }
    
    func convertJsonToObject(key : String, dic : [String : Any], listRequireProperty : [String]) -> String{
        if listRequireProperty.count > 0{
            print("listRequireProperty count = \(listRequireProperty.count)")
            
            print("dic = \(dic)")
        }
        let isUseDB : Bool = cbxUseDB.state.rawValue == 1 ? true : false
        
        /// declaare property
        var stringProperty = ""
        
        /// declare func init, list parameter
        var stringInit = ""
        
        /// decalare func wrapTo DataBaseObject of Realm , list parameter
        var stringWrap = "\tfunc wrapToDO\(self.upperCase(className: key))Object() -> DO_\(self.upperCase(className: key)){\n"
        
        /// declare content of func wrapTo
        var stringWrapContent = "\t\tlet model = DO_\(self.upperCase(className: key))("
        /// declare content of func init
        var stringInitContent = "\t\tself.init()\n"
        
        
        /// Declara property for Realm Object
        var stringPropertyRealm = ""
        /// declare content of func wrap RealmObject to Object for using, list parameter
        var stringWrapRealm = "\tfunc wrapTo\(self.upperCase(className: key))Object() -> \(self.upperCase(className: key)){\n"
        /// declare content of func wrap RealmObject to Object for using
        var stringWrapContentRealm = "\t\tlet model = \(self.upperCase(className: key))("
        
        // class root
        
        stringProperty +=  "public class \(self.upperCase(className: key)){\n"
        stringInit += "\tpublic convenience init("
        
        stringPropertyRealm +=  "public class DO_\(self.upperCase(className: key)) : Object {\n"
        
        //create class
        var stringListParam = ""
        
        let listKeys = dic.keys
        for pkey in listKeys{
            var optionalSymbol = "!"
            var optionalSymbolForDeclare = ""
            if listRequireProperty.count > 0{
                optionalSymbol = listRequireProperty.contains(pkey) ? "!" : "?"
                optionalSymbolForDeclare = listRequireProperty.contains(pkey) ? "" : "?"
            }
            
            if let value = dic[pkey]{
                let lKey = self.lowerCase(propertyName: pkey)
                if value is String{
                    //create property
                    stringProperty += self.createPropertyString(key: pkey, value: value as! String, optionalSymbol: optionalSymbol,isRealm: false)
                    stringListParam += "\(lKey) : String\(optionalSymbolForDeclare), "
                    stringPropertyRealm += self.createPropertyString(key: pkey, value: value as! String, optionalSymbol: optionalSymbol,isRealm: true)
                }else if value is Int64{
                    //create property
                    stringProperty += self.createPropertyNumber(key: pkey, value: value as! Int64,optionalSymbol: optionalSymbol, isRealm: false)
                    stringListParam += "\(lKey) : Int64\(optionalSymbolForDeclare), "
                    stringPropertyRealm += self.createPropertyNumber(key: pkey, value: value as! Int64,optionalSymbol: optionalSymbol, isRealm: true)
                }else if value is Double{
                    //create property
                    stringProperty += self.createPropertyNumber(key: pkey, value: value as! Double,optionalSymbol: optionalSymbol,isRealm: false)
                    stringListParam += "\(lKey) : Double\(optionalSymbolForDeclare), "
                    stringPropertyRealm += self.createPropertyNumber(key: pkey, value: value as! Double,optionalSymbol: optionalSymbol,isRealm: true)
                }else if value is Array<Any>{
                    //create array
//                    self.createPropertyArray(key: key, value: value, isRealm: false)
                    let dataTypeOfArray = self.createPropertyArray(numberOfChildren: 0, key: pkey, value: value as! Array<Any>, isRealm: false)
//                    print("dataTypeOfArray = \(dataTypeOfArray)")
                    
                    stringProperty +=  "\tpublic var \(lKey) \t: \(dataTypeOfArray)\(optionalSymbol) \n"
                    stringListParam += "\(lKey) : \(dataTypeOfArray)\(optionalSymbolForDeclare), "
//                    print("stringListParam = \(stringListParam)")
                }else if value is [String : Any]{
                    //create Object
//                    stringProperty += self.convertJsonToObject(key: key, dic: value as! [String : Any])
//                    stringProperty += "\n"
                    stringProperty += "\tpublic var \(lKey ) \t: \(self.upperCase(className: pkey))\(optionalSymbol) \n"
                    stringPropertyRealm += "\t@objc dynamic public var \(lKey ) \t: DO_\(self.upperCase(className: pkey))\(optionalSymbol) \n"
                    stringListParam += "\(lKey) : \(self.upperCase(className: pkey))\(optionalSymbolForDeclare), "
                    data.append(self.convertJsonToObject(key: lKey, dic: value as! [String : Any], listRequireProperty: [String]()))
                }
                stringInitContent += "\t\tself.\(lKey) = \(lKey)\n"
            }
        
        }
        // remove ", " at the last declare parameter
        if listKeys.count > 0{
            stringListParam.removeLast()
            stringListParam.removeLast()
        }
        stringInit += stringListParam + "){\n"
        stringInitContent += "\t}\n"
        
        stringProperty += stringInit + stringInitContent
        
        
        if isUseDB{
            stringWrap += stringWrapContent + stringListParam + ")\n\t\treturn model\n\t}\n"
             stringProperty +=  stringWrap
            stringPropertyRealm += stringInit + stringInitContent
            stringWrapRealm += stringWrapContentRealm + stringListParam + ")\n\t\treturn model\n\t}\n"
            stringPropertyRealm += stringWrapRealm + "}\n"
        }
        
        stringProperty +=  "}\n"
        dataRealm.append(stringPropertyRealm)
        return stringProperty
    }
    
    func createPropertyString(key : String, value : String,optionalSymbol : String, isRealm : Bool)-> String{
        if isRealm {
            return "\t@objc dynamic  public var \( self.lowerCase(propertyName: key)) \t: String\(optionalSymbol) \n"
        }
        return "\tpublic var \( self.lowerCase(propertyName: key)) \t: String\(optionalSymbol) \n"
    }
    
    func createPropertyNumber(key : String, value : Int64,optionalSymbol : String, isRealm : Bool)-> String{
        if isRealm {
            return "\t@objc dynamic public var \( self.lowerCase(propertyName: key)) \t: Int64\(optionalSymbol) \n"
        }
        return "\tpublic var \( self.lowerCase(propertyName: key)) \t: Int64\(optionalSymbol) \n"
    }
    
    func createPropertyNumber(key : String, value : Double,optionalSymbol : String, isRealm : Bool)-> String{
        if isRealm {
            return "\t@objc dynamic public var \( self.lowerCase(propertyName: key)) \t: Double\(optionalSymbol) \n"
        }
        return "\tpublic var \( self.lowerCase(propertyName: key)) \t: Double\(optionalSymbol) \n"
    }
    
    func createPropertyArray(numberOfChildren : Int, key : String, value : [Any], isRealm : Bool) -> String{
//        if isRealm {
//            return "\t@objc dynamic public var \(key) \t: [] \n"
//        }
        if value.count > 0{
            let firstItem = value.first!
            if firstItem is String{
                if numberOfChildren == 0{
                    return "[String]"
                }
                return "String"
            }else if firstItem is Int64{
                if numberOfChildren == 0{
                    return "[Int64]"
                }
                return "Int64"
            }else if value is Double{
                if numberOfChildren == 0{
                    return "[Double]"
                }
                return "Double"
            }else if firstItem is Array<Any>{
                if numberOfChildren != 0 {
                    return "[" + self.createPropertyArray(numberOfChildren: numberOfChildren + 1, key: key, value: value, isRealm: isRealm) + "]"
                }
                return "\(self.createPropertyArray(numberOfChildren: numberOfChildren + 1, key: key, value: value, isRealm: isRealm))]"
                
            }else if firstItem is [String : Any]{
//                dictionary of all properties in all objects in array.
                var dicToalPropertyOfArray = [String : Any]()
                // list key having in all objects in array
                var listKeyHavingInAllElement = [String : Int]()
                // count of array
                let count = value.count
                
                //count key item appear in array
                // if count key == count then it appear in all objects
                for item in value{
                    let itemDic = item as! [String : Any]
                    let itemKeys = itemDic.keys
                    for kk in itemKeys{
                        let countTemp = listKeyHavingInAllElement[kk] ?? 0
                        if countTemp == 0{
                            dicToalPropertyOfArray[kk] = itemDic[kk]
                        }
                        listKeyHavingInAllElement[kk] = countTemp + 1
                    }
                }
                // remove all countkey < count. it means remove all key which is not appear in all objects
                for itemKey in listKeyHavingInAllElement.keys{
                    if listKeyHavingInAllElement[itemKey] != nil && listKeyHavingInAllElement[itemKey]! < count{
                        listKeyHavingInAllElement.removeValue(forKey: itemKey)
                    }
                    
                }
                self.showLog(log: "item key require :")
                for itemKey in listKeyHavingInAllElement.keys{
                    print("item key require = \(itemKey)")
                    self.showLog(log: itemKey)
                }
//                self.convertJsonToObject(key: key, dic: firstItem, listRequireProperty: <#[String]#>)
                if listKeyHavingInAllElement.count == 0{
                    let listRequireProperty = [String]()
                    data.append(self.convertJsonToObject(key: key, dic: dicToalPropertyOfArray, listRequireProperty: listRequireProperty))
                }else{
                    let listRequireProperty = listKeyHavingInAllElement.map{$0.key}
                    data.append(self.convertJsonToObject(key: key, dic: dicToalPropertyOfArray, listRequireProperty: listRequireProperty))
                }
                return "\(self.upperCase(className: key))"
                
            }
        }else{
            // ko lam
            print("array rong")
            self.showLog(log: "array rong thi parser Any nhe.")
        }

        return "[Any]"
    }
    
    func writeToDesktop(list : [String]){
        let dateFirst = UserDefaults.standard.double(forKey: "dateFirst")
        let dateNow = Date().timeIntervalSince1970 as! Double
        print("dateNow \(dateNow)")
        let subDate = dateNow - dateFirst
        print("subdate \(subDate)")
        
//        if  subDate > 600.0{
//            print("het han su dung")
//            return
//        }
        var lastStr = ""
        for item in list{
            lastStr += item
        }
        if lastStr.count > 0{
            self.writeToDesktop(string: lastStr)
        }else{
            print("KO co du lieu")
            self.showLog(log: "KO co du lieu de in ra")
        }
        
    }
    func writeToDesktop(string : String){

        let home = FileManager.default.homeDirectoryForCurrentUser
        let fileName = (self.txtRootClassName.stringValue != nil && self.txtRootClassName.stringValue != "" ) ? self.txtRootClassName.stringValue : "CTLClass"
        
        let fileUrl = home
            .appendingPathComponent(fileName)
            .appendingPathComponent(fileName)
            .appendingPathExtension("txt")

        let desktopUrl = fileUrl.deletingLastPathComponent()
        desktopUrl.path
        do{
            let value = try string.write(to: desktopUrl, atomically: false, encoding: .utf8)
        }catch{
            
        }
        
        guard let window = view.window else { return }
        
        // 2
        let panel = NSSavePanel()
        // 3
//        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        panel.directoryURL = self.selectedFolder ?? home
        // 4
        panel.nameFieldStringValue =  desktopUrl
            .deletingPathExtension()
            .appendingPathExtension("swift")
            .lastPathComponent
        
        // 5
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSFileHandlingPanelOKButton,
                let url = panel.url {
                // 6
                do {
                    var infoAsText = ""
                    infoAsText += self.writeComment()
                    //do header if need
                    let isUseDB : Bool = self.cbxUseDB.state.rawValue == 1 ? true : false
                    if isUseDB{
                        infoAsText += "import RealmSwift\n\n"
                    }
                    infoAsText += string
                    try infoAsText.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("KO dc")
                    self.showLog(log: "ko the write file")
                }
            }
        }       
    }
    
    func writeComment()->String{
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        let dateStr = df.string(from: date)
        let fileName = (self.txtRootClassName.stringValue != nil && self.txtRootClassName.stringValue != "" ) ? self.txtRootClassName.stringValue : "CTLClass"
        var str = "//\n//   Automatically generated by the ThaiLinh compiler, do not modify.\n//\n//  \(fileName).swift\n//  Swift version 4.2\n//\n//  Created by thailinh on \(dateStr)).\n//  Copyright © \(dateStr) thailinh. All rights reserved.\n//\n\n"
        return str
    }
    
    func upperCase(className : String)-> String{
        let result = "CTL" + className.prefix(1).uppercased() + className.dropFirst()
        if listKeyWord.contains(className) || listDataTypeKeyWord.contains(className){
//            classNameDeclare.append(result)
            return result
        }
//        if classNameDeclare.contains(className) || classNameDeclare.contains(result){
//            let result2 = "CTL" + className.prefix(1).uppercased() + className.dropFirst() + "A"
//            classNameDeclare.append(result2)
//            return result2
//        }
        return className.prefix(1).uppercased() + className.dropFirst()
    }
    func lowerCase(propertyName : String)-> String{
        let result = "ctl" + propertyName.prefix(1).lowercased() + propertyName.dropFirst()
        if listKeyWord.contains(className) || listDataTypeKeyWord.contains(className){
//            classNameDeclare.append(result)
            return result
        }
        return propertyName.prefix(1).lowercased() + propertyName.dropFirst()
    }
    
    func showLog(log : String){
        self.txvLog.string += log + ".\n"
    }
    
}


