//
//  Enums.swift
//  MacOs_JsonToDataBase
//
//  Created by HuyHoangDinh on 2/8/21.
//  Copyright © 2021 thailinh. All rights reserved.
//

import Foundation

enum CTLSymbol: String {
    case optional = "?"
    case forceUnwrap = "!"
}

indirect enum CTLValueType {
    case kArray(CTLValueType)
    case kObject(String)
    
    case kInt
    case kInt64
    case bool
    case kString
    case kDouble
    case kFloat
    case kAny
    
    var description: String {
        switch self {
        case .kArray(let value):
            return "[\(value.description)]"
            
        case .kObject(let objectName):
            return objectName
            
        case .kInt:
            return "Int"
            
        case .kInt64:
            return "Int64"
            
        case .kString:
            return "String"
            
        case .kDouble:
            return "Double"
            
        case .kAny:
            return "Any"
            
        case .bool:
            return "Bool"
        case .kFloat:
            return "Float"
        }
    }
    
    var descriptionDO: String {
        switch self {
        case .kArray(let value):
            return "[\(value.descriptionDO)]"
            
        case .kObject(let objectName):
            return "DO_\(objectName)"
            
        case .kInt:
            return "Int"
            
        case .kInt64:
            return "Int64"
            
        case .kString:
            return "String"
            
        case .kDouble:
            return "Double"
            
        case .kAny:
            return "Any"
            
        case .bool:
            return "Bool"
        case .kFloat:
            return "Float"
        }
    }
    
    var jsonInitWrapper: String {
        switch self {
        case .kArray(let value):
            return "[\(value.jsonInitWrapper)]"
            
        case .kObject(_):
            return "[String: Any]"
            
        case .kInt:
            return "Int"
            
        case .kInt64:
            return "Int64"
            
        case .kString:
            return "String"
            
        case .kDouble:
            return "Double"
            
        case .kAny:
            return "Any"
        
        case .bool:
            return "Bool"
            
        case .kFloat:
            return "Float"
        }
    }
    
    func jsonObjectMapper(propertyCall: String, isArray: Bool, isDOObject: Bool) -> String {
        
        let prefixDO = isDOObject == true ? "DO_" : ""
        switch self {
        case .kArray(let value):
            let callMap = isArray ? "" : propertyCall
            
            switch value {
            case .kArray(_):
                let itemResult = value.jsonObjectMapper(propertyCall: propertyCall, isArray: true, isDOObject: isDOObject)
                return itemResult == callMap ? callMap : callMap + ".map({ $0.\(itemResult)})"
            case .kObject(let objectName):
                return callMap + ".map({ \(prefixDO + objectName)(json: $0)})"
            default:
                return callMap
            }
            
        case .kObject(let objectName):
            return "\(prefixDO + objectName)(json: \(propertyCall))"
            
        default:
            return propertyCall
        }
    }
    
    var arrayWrapperDO: String {
        switch self {
        case .kArray(let value):
            
            return value.arrayWrapperDO
        case .kObject(let objectName):
            
            return "wrapToDO\(objectName)Object()"
        default:
            
            return ""
        }
    }
    
    var arrayWrapperObject: String {
        switch self {
        case .kArray(let value):
            
            return value.arrayWrapperObject
        case .kObject(let objectName):
            
            return "wrapTo\(objectName)Object()"
        default:
            
            return ""
        }
    }
    
    func arrayObjectCounter(start: Int = 0) -> Int? {
        if start < 0 {
            fatalError("list nhỏ hơn 0 ????")
        }
        switch self {
        case .kArray(let value):
            
            if let counter = value.arrayObjectCounter(start: start) {
                return counter + 1
            }
            return nil
        case .kObject(_):
            
            return start
        default:
            
            return nil
        }

    }
}
