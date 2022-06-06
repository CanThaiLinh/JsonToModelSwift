//
//  ViewController.swift
//  MacOs_JsonToDataBase
//
//  Created by thailinh on 4/19/19.
//  Copyright © 2019 thailinh. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var dictObject: [String: [String: CTLValueType]] = [:]
    
    var selectedFolder: URL?
    
    var usingInt64 = false
    var usingForceUnwrapping = false
    
    var listKeyWord = Constants.listKeyWord
    var listDataTypeKeyWord = Constants.listDataTypeKeyWord
    
    @IBOutlet weak var cbxUseDB: NSButton!
    @IBOutlet weak var cbxDeepCopy: NSButton!
    @IBOutlet weak var cbxUseJsonInit: NSButton!
    @IBOutlet var txvView: NSTextView!
    @IBOutlet weak var txtRootClassName: NSTextField!
    @IBOutlet weak var txtPrefix: NSTextField!
    @IBOutlet weak var txtUrl: NSTextField!
    @IBOutlet weak var txvLog: NSTextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let url = UserDefaults.standard.url(forKey: Constants.kSelectedFolder){
            self.selectedFolder = url
            self.txtUrl.stringValue = self.selectedFolder?.path ?? ""
        }
        
        let dateFirst = UserDefaults.standard.double(forKey: "dateFirst")
        if dateFirst <= 0 {
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
        
        dictObject = [:]
        
        let jsonText = txvView.string
        
        let dic = self.convertStringToDictionary(jsonText: jsonText)
        
        var fileName: String = Constants.defaultClassName
        if self.txtRootClassName.stringValue.isEmpty == false  {
            fileName = self.txtRootClassName.stringValue
        }
        
        let usingInt64 = self.usingInt64
        
        self.convertJsonToObject(objectName: fileName, dic: dic, listRequireProperty: [], usingInt64: usingInt64)
        
        let symbol: CTLSymbol = usingForceUnwrapping == true ? .forceUnwrap : .optional
        let isUsingDB = cbxUseDB.state.rawValue == 1 ? true : false
        let isDeepCopy = cbxDeepCopy.state.rawValue == 1 ? true : false
        let isUsingJsonInit = cbxUseJsonInit.state.rawValue == 1 ? true : false
        
        let result = self.convertToString(symbol: symbol,
                                          isUsingDB: isUsingDB,
                                          isUsingDeepCopy: isDeepCopy,
                                          isUsingJsonInit: isUsingJsonInit)
        self.writeToDesktop(string: result)
    }
    
    @IBAction func btnSelecteFolder(_ sender: Any) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                self.selectedFolder = panel.urls[0]
                self.txtUrl.stringValue = self.selectedFolder?.path ?? ""
                UserDefaults.standard.set(self.selectedFolder, forKey: Constants.kSelectedFolder)
                UserDefaults.standard.synchronize()
                
            }
        }
    }
    
    @IBAction func rbtnIntWasTapped(_ sender: Any) {
        if let rbtn = sender as? NSButton {
            usingInt64 = rbtn.tag == 1
        }
    }
    
    @IBAction func rbtnOptionalWasTapped(_ sender: Any) {
        if let rbtn = sender as? NSButton {
            usingForceUnwrapping = rbtn.tag == 1
        }
    }
    
    func writeToDesktop(list : [String]){
        let dateFirst = UserDefaults.standard.double(forKey: "dateFirst")
        let dateNow = Date().timeIntervalSince1970
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
        if lastStr.count > 0 {
            self.writeToDesktop(string: lastStr)
        } else {
            print("KO co du lieu")
            self.showLog(log: "KO co du lieu de in ra")
        }
        
    }
    
    func writeToDesktop(string : String){
        
        let home = FileManager.default.homeDirectoryForCurrentUser
        let fileName = self.txtRootClassName.stringValue.isEmpty == false  ? self.txtRootClassName.stringValue : Constants.defaultClassName
        
        let fileUrl = home
            .appendingPathComponent(fileName)
            .appendingPathComponent(fileName)
            .appendingPathExtension("txt")
        
        let desktopUrl = fileUrl.deletingLastPathComponent()
        
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
            if result == NSApplication.ModalResponse.OK,
                let url = panel.url {
                // 6
                do {
                    var infoAsText = ""
                    infoAsText += self.writeComment()
                    //do header if need
                    let isUseDB : Bool = self.cbxUseDB.state.rawValue == 1 ? true : false
                    infoAsText += "import Foundation\n\n"
                    if isUseDB {
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
    
    func writeComment() -> String {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        let dateStr = df.string(from: date)
        let fileName = self.txtRootClassName.stringValue.isEmpty == false ? self.txtRootClassName.stringValue : "CTLClass"
        let str = "//\n//   Automatically generated by the ThaiLinh compiler, do not modify.\n//\n//  \(fileName).swift\n//  Swift version 4.2\n//\n//  Created by thailinh on \(dateStr)).\n//  Copyright © \(dateStr) thailinh. All rights reserved.\n//\n\n"
        return ""//str
    }
    
    func upperCase(className : String) -> String {
        let defaultPrefix = Constants.defaultPrefix.uppercased()
        var prefix = self.txtPrefix.stringValue.uppercased()
        prefix = prefix.isEmpty == true ? defaultPrefix : prefix
        
        let result = prefix + String(className.prefix(1).uppercased()) + className.dropFirst()
        if listKeyWord.contains(className) || listDataTypeKeyWord.contains(className){
            return result
        }
        
        return className.prefix(1).uppercased() + className.dropFirst()
    }
    func lowerCase(className : String)-> String{
        let defaultPrefix = Constants.defaultPrefix.lowercased()
        var prefix = self.txtPrefix.stringValue.lowercased()
        prefix = prefix.isEmpty == true ? defaultPrefix : prefix
        
        let result = prefix + String(className.prefix(1).lowercased()) + className.dropFirst()
        if listKeyWord.contains(className) || listDataTypeKeyWord.contains(className){
            return result
        }
        return className.prefix(1).lowercased() + className.dropFirst()
    }
    
    func showLog(log : String){
        self.txvLog.string += log + ".\n"
    }
    
}


//MARK: - Convert json to dict

extension ViewController {
    func convertStringToDictionary(jsonText: String)-> [String : Any] {
        if let data = jsonText.data(using: String.Encoding.utf8){
            if let dic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
                
                return dic as! [String : Any]
            }
        }
        
        print("Khong phai json")
        self.showLog(log: "Khong phai json")
        return [String : Any]()
    }
    
    func convertJsonToObject(objectName : String,
                             dic : [String : Any],
                             listRequireProperty : [String],
                             usingInt64: Bool) {
        
        if listRequireProperty.count > 0 {
            print("listRequireProperty count = \(listRequireProperty.count)")
            
            print("dic = \(dic)")
        }
        
        let className = self.upperCase(className: objectName)
        dictObject[className] = [:]
        for (key, value) in dic {
            
            let propertyName = key//self.lowerCase(className: )
            
            if type(of: value) == type(of: NSNumber(integerLiteral: 1)) {
                if let _ = value as? Int {
                    dictObject[className]?[propertyName] = usingInt64 == true ? .kInt64 : .kInt
                } else if let _ = value as? Float {
                    dictObject[className]?[propertyName] = .kFloat
                } else if let _ = value as? Double {
                    dictObject[className]?[propertyName] = .kDouble
                }
                continue
            } else if type(of: value) == type(of: NSNumber(booleanLiteral: true)) {
                dictObject[className]?[propertyName] = CTLValueType.bool
                continue
            }
            
            switch value {
                
            case is String:
                
                dictObject[className]?[propertyName] = CTLValueType.kString
                
            case is Array<Any>:
                
                let dataTypeOfArray = self.createPropertyArray(numberOfChildren: 0,
                                                               key: objectName + "_" + propertyName,
                                                               value: value as! Array<Any>,
                                                               isRealm: false,
                                                               usingInt64: usingInt64)
                dictObject[className]?[propertyName] = .kArray(dataTypeOfArray)
                
                
            case is [String : Any]:
                
                guard let value = value as? [String: Any] else { fatalError("???")}
                
                let objectName = self.upperCase(className: objectName + "_" + propertyName)
                dictObject[className]?[propertyName] = .kObject(objectName)
                
                self.convertJsonToObject(objectName: objectName,
                                         dic: value,
                                         listRequireProperty: [String](),
                                         usingInt64: usingInt64)
            case is NSNull:
                dictObject[className]?[propertyName] = .kAny
            default:
                break
            }
            
            
        }
    }
    
    func createPropertyArray(numberOfChildren : Int,
                             key : String,
                             value : [Any],
                             isRealm : Bool,
                             usingInt64: Bool) -> CTLValueType {
        
        guard let firstItem = value.first else {
            // ko lam
            print("array rong")
            self.showLog(log: "array rong thi parser Any nhe.")
            
            let valueType: CTLValueType = .kAny
            return numberOfChildren == 0 ? valueType : .kArray(valueType)
        }
        
        if type(of: value) == type(of: NSNumber(integerLiteral: 1)) {
            var valueType: CTLValueType = usingInt64 == true ? .kInt64 : .kInt
            
            if let _ = value as? [Float] {
                valueType = .kFloat
            } else if let _ = value as? [Double] {
                valueType = .kDouble
            }
            
            return numberOfChildren == 0 ? valueType : .kArray(valueType)
        } else if type(of: value) == type(of: NSNumber(booleanLiteral: true)) {
            let valueType: CTLValueType = .bool
            return numberOfChildren == 0 ? valueType : .kArray(valueType)
        }
        
        switch firstItem {
            
        case is String:
            let valueType: CTLValueType = .kString
            return numberOfChildren == 0 ? valueType : .kArray(valueType)
            
        case is Double:
            
            let valueType: CTLValueType = .kDouble
            return numberOfChildren == 0 ? valueType : .kArray(valueType)
            
        case is Array<Any>:
            
            guard let firstItem = firstItem as? [Any] else {
                fatalError("???")
            }
            
            let property = self.createPropertyArray(numberOfChildren: numberOfChildren + 1,
                                                    key: key,
                                                    value: firstItem,
                                                    isRealm: isRealm,
                                                    usingInt64: usingInt64)
            
            return numberOfChildren == 0 ? property : .kArray(property)
            
        case is [String : Any]:
            
            //                dictionary of all properties in all objects in array.
            var dicToalPropertyOfArray = [String : Any]()
            // list key having in all objects in array
            var listKeyHavingInAllElement = [String : Int]()
            // count of array
            let count = value.count
            
            //count key item appear in array
            // if count key == count then it appear in all objects
            for item in value {
                
                let itemDic = item as! [String : Any]
                
                for kk in itemDic.keys {
                    
                    let countTemp = listKeyHavingInAllElement[kk] ?? 0
                    
                    if countTemp == 0 {
                        dicToalPropertyOfArray[kk] = itemDic[kk]
                    }
                    listKeyHavingInAllElement[kk] = countTemp + 1
                }
            }
            // remove all countkey < count. it means remove all key which is not appear in all objects
            for itemKey in listKeyHavingInAllElement.keys {
                
                if listKeyHavingInAllElement[itemKey] != nil && listKeyHavingInAllElement[itemKey]! < count {
                    
                    listKeyHavingInAllElement.removeValue(forKey: itemKey)
                }
                
            }
            
            self.showLog(log: "item key require :")
            
            for itemKey in listKeyHavingInAllElement.keys {
                print("item key require = \(itemKey)")
                self.showLog(log: itemKey)
            }
            
            if listKeyHavingInAllElement.count == 0 {
                let listRequireProperty = [String]()
                self.convertJsonToObject(objectName: key,
                                         dic: dicToalPropertyOfArray,
                                         listRequireProperty: listRequireProperty,
                                         usingInt64: usingInt64)
            } else {
                let listRequireProperty = listKeyHavingInAllElement.map{$0.key}
                self.convertJsonToObject(objectName: key,
                                         dic: dicToalPropertyOfArray,
                                         listRequireProperty: listRequireProperty,
                                         usingInt64: usingInt64)
            }
            return .kObject(self.upperCase(className: key))
            
        default:
            
            let valueType: CTLValueType = .kAny
            return numberOfChildren == 0 ? valueType : .kArray(valueType)
        }
    }
}


// MARK: - Convert to String
extension ViewController {
    func convertToString(symbol: CTLSymbol, isUsingDB: Bool, isUsingDeepCopy: Bool, isUsingJsonInit: Bool) -> String {
        var result = ""
        
        for (objectName, objectValues) in dictObject {
            let strObject =
                self.convertToObjectString(objectName: objectName,
                                           objectValues: objectValues,
                                           symbol: symbol,
                                           isUsingDB: isUsingDB,
                                           isUsingDeepCopy: isUsingDeepCopy,
                                           isUsingJsonInit: isUsingJsonInit)
            result += strObject
            if isUsingDB == true {
                let strRealmObject =
                    self.convertToRealmObjectString(objectName: objectName,
                                                    objectValues: objectValues,
                                                    symbol: symbol,
                                                    isUsingDeepCopy: isUsingDeepCopy,
                                                    isUsingJsonInit: isUsingJsonInit)
                result += strRealmObject
            }
        }
        return result
    }
    
    func convertToRealmObjectString(objectName : String, objectValues : [String : CTLValueType], symbol: CTLSymbol, isUsingDeepCopy: Bool, isUsingJsonInit: Bool) -> String {
        
        let uClassName = self.upperCase(className: objectName)
        
        //Object
        var strRealmObject = "public class DO_\(uClassName) : Object {\n\n"
        
        var strRealmInit = "\tpublic convenience init("
        var strRealmListParameters = ""
        var strRealmProperties = ""
        var strRealmInitContent = "\t\tself.init()\n"
        
        //Json init
        
        let strJsonInit = "\tpublic convenience init(json: [String: Any]) {"
        var strJsonInitContent = "\n\t\tself.init()"
        
        //Wrapper
        var strWrapParameters = ""
        var strWrapListToObject = ""
        
        var strWrapToObject = "\tfunc wrapTo\(uClassName)Object() -> \(uClassName) {\n\t\t"
        let strWrapToObjectContent = "let model = \(uClassName)("
        
        
        //Using Deep Copy
        
        var strRealmDeepCopy = "\n\tpublic func copy(with zone: NSZone? = nil) -> Any {\n"
        var strRealmDeepCopyContent = "\t\tlet modal = DO_\(uClassName)()\n"
        
        for (pName, pValue) in objectValues.sorted(by: {$0.key < $1.key}) {
            let lowPName = self.lowerCase(className: pName)
            
            strRealmInitContent += "\t\tself.\(lowPName) = \(lowPName)\n"
            strRealmListParameters += "\(lowPName): \(self.upperCase(className: pValue.descriptionDO))\(symbol.rawValue), \n\t\t\t\t\t\t\t"
            strRealmProperties += createProperty(pValue,
                                                 key: lowPName,
                                                 symbol: symbol,
                                                 isRealm: true)
            if isUsingJsonInit == true {
                strJsonInitContent += "\n\t\tif let wrapValue = json[\"\(pName)\"] as? \(pValue.jsonInitWrapper)"
                strJsonInitContent += "{\n\t\t\tlet jsonValue = \(pValue.jsonObjectMapper(propertyCall: "wrapValue", isArray: false, isDOObject: true))"
                strJsonInitContent += "\n\t\t\tself.\(lowPName) = jsonValue\n\t\t}"
            }
            
            if let counter = pValue.arrayObjectCounter() {
                if counter == 0 {
                    strWrapListToObject += "let wrapper\(self.upperCase(className: lowPName)) = \(lowPName).\(pValue.arrayWrapperObject)\n\t\t"
                    strWrapParameters += "\(lowPName): wrapper\(self.upperCase(className: lowPName)), \n\t\t\t\t\t\t\t"
                } else {
                    
                    var mapping = "map({ $0."
                    var mapTall = "})"
                    for _ in 1..<counter {
                        mapping += "map({ $0."
                        mapTall += "})"
                    }
                    
                    let mapResult = "\(mapping)\(pValue.arrayWrapperObject)\(mapTall)"
                    strWrapListToObject += "let wrapper\(self.upperCase(className: pName)) = \(lowPName).\(mapResult)\n\t\t\t\t\t\t\t"
                    strWrapParameters += "\(lowPName): wrapper\(self.upperCase(className: pName)), \n\t\t\t\t\t\t\t"
                }
            } else {
                strWrapParameters += "\(lowPName): self.\(lowPName), \n\t\t\t\t\t\t\t"
            }
            
            if isUsingDeepCopy == true {
                strRealmDeepCopyContent += "\t\tmodal.\(lowPName) = self.\(lowPName)\n"
            }
        }
        
        if strWrapParameters.count > 9 {
            strWrapParameters.removeLast(10)
        }
        if strRealmListParameters.count > 9 {
            strRealmListParameters.removeLast(10)
        }
        
        strRealmInit += strRealmListParameters
        strRealmInit += ") {\n\n"
        strRealmInit += strRealmInitContent + "\t}\n"
        
        strRealmObject += strRealmProperties + "\n" + strRealmInit + "\n"
        strWrapToObject += strWrapListToObject + strWrapToObjectContent + strWrapParameters + ")\n\t\treturn model\n\t}\n"
        strRealmObject += strWrapToObject
        
        if isUsingJsonInit == true {
            strRealmObject += "\n\n" + strJsonInit + strJsonInitContent + "\n\t}"
        }
        
        if isUsingDeepCopy == true {
            strRealmDeepCopy += strRealmDeepCopyContent + "\t\treturn modal\n\t}"
            strRealmObject += strRealmDeepCopy
        }
        
        strRealmObject += "\n}\n\n"
        
        return strRealmObject
    }
    
    func convertToObjectString(objectName : String, objectValues : [String : CTLValueType], symbol: CTLSymbol, isUsingDB: Bool, isUsingDeepCopy: Bool, isUsingJsonInit: Bool) -> String {
        
        let uClassName = self.upperCase(className: objectName)
        var strObject = isUsingDeepCopy == true ? "public class \(uClassName): NSCopying {\n\n" : "public class \(uClassName) {\n\n"
        
        var strProperties = ""
        var strInit = "\tpublic convenience init("
        var strListParameters = ""
        var strInitContent = "\t\tself.init()\n"
        
        //Json init
        
        let strJsonInit = "\tpublic convenience init(json: [String: Any]) {"
        var strJsonInitContent = "\n\t\tself.init()"
        
        //Using DB
        
        var strWrapParameters = ""
        var strWrapListToRealm = ""
        
        var strWrapToRealm = "\n\tfunc wrapToDO\(uClassName)Object() -> DO_\(uClassName) {\n\t\t"
        let strWrapToRealmContent = "let model = DO_\(uClassName)("
        
        
        //Using Deep Copy
        var strObjectDeepCopy = "\n\tpublic func copy(with zone: NSZone? = nil) -> Any {\n\t\t"
        var strObjectDeepCopyContent = "let modal = \(uClassName)()\n"
        
        for (pName, pValue) in objectValues.sorted(by: {$0.key < $1.key}) {
            
            let lowPName = self.lowerCase(className: pName)
            
            strProperties += createProperty(pValue,
                                            key: lowPName,
                                            symbol: symbol,
                                            isRealm: false)
            strListParameters += "\(lowPName): \(self.upperCase(className: pValue.description))\(symbol.rawValue), \n\t\t\t\t\t\t\t"
            strInitContent += "\t\tself.\(lowPName) = \(lowPName)\n"
            
            if isUsingJsonInit == true {
                strJsonInitContent += "\n\t\tif let wrapValue = json[\"\(pName)\"] as? \(pValue.jsonInitWrapper) "
                strJsonInitContent += "{\n\t\t\tlet jsonValue = \(pValue.jsonObjectMapper(propertyCall: "wrapValue", isArray: false, isDOObject: false))"
                strJsonInitContent += "\n\t\t\tself.\(lowPName) = jsonValue\n\t\t}"
            }
            
            if isUsingDB == true {
                if let counter = pValue.arrayObjectCounter() {
                    if counter == 0 {
                        strWrapListToRealm += "let wrapper\(self.upperCase(className: lowPName)) = \(lowPName).\(pValue.arrayWrapperDO)\n\t\t"
                        strWrapParameters += "\(lowPName): wrapper\(self.upperCase(className: lowPName)), \n\t\t\t\t\t\t\t"
                    } else {
                        
                        var mapping = "map({ $0."
                        var mapTall = "})"
                        for _ in 1..<counter {
                            mapping += "map({ $0."
                            mapTall += "})"
                        }
                        
                        let mapResult = "\(mapping)\(pValue.arrayWrapperDO)\(mapTall)"
                        strWrapListToRealm += "let wrapper\(self.upperCase(className: pName)) = \(lowPName).\(mapResult)\n\t\t"
                        strWrapParameters += "\(lowPName): wrapper\(self.upperCase(className: pName)), \n\t\t\t\t\t\t\t"
                    }
                } else {
                    strWrapParameters += "\(lowPName): self.\(lowPName), \n\t\t\t\t\t\t\t"
                }
            }
            
            if isUsingDeepCopy == true {
                strObjectDeepCopyContent += "\t\tmodal.\(lowPName) = self.\(lowPName)\n"
            }
        }
        
        if strListParameters.count > 9 {
            strListParameters.removeLast(10)
        }
        
        strInit += strListParameters
        strInit += ") {\n\n"
        strInit += strInitContent + "\t}\n"
        strObject += strProperties + "\n" + strInit
        
        if isUsingJsonInit == true {
            strObject += "\n\n" + strJsonInit + strJsonInitContent + "\n\t}"
        }
        
        if isUsingDB == true {
            if strWrapParameters.count > 9 {
                strWrapParameters.removeLast(10)
            }
            
            strWrapToRealm += strWrapListToRealm + strWrapToRealmContent + strWrapParameters + ")\n\t\treturn model\n\t}\n"
            
            strObject += strWrapToRealm
        }
        
        if isUsingDeepCopy == true {
            strObjectDeepCopy += strObjectDeepCopyContent + "\t\treturn modal\n\t}"
            strObject += strObjectDeepCopy
        }
        
        strObject += "\n}\n\n"
        
        return strObject
    }
    
    func createProperty(_ valueType: CTLValueType,
                        key : String,
                        symbol : CTLSymbol,
                        isRealm : Bool) -> String {
        let strValueType = isRealm == true ? valueType.descriptionDO : valueType.description
        let result = "public var \(self.lowerCase(className: key)) \t: \(strValueType)\(symbol.rawValue) \n"
        if isRealm {
            return "\t@objc dynamic " + result
        }
        return "\t" + result
    }
}
