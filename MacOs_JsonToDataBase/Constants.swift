//
//  Constants.swift
//  MacOs_JsonToDataBase
//
//  Created by Hoang Dinh Huy on 12/28/20.
//  Copyright © 2020 thailinh. All rights reserved.
//

import Foundation

struct Constants {
    static let kSelectedFolder = "kSelectedFolder"
    static let defaultClassName = "CTLClass"
    
    static let defaultPrefix = "CTL"
    
    struct DO_Object {
        
        static let initStr = "\tpublic convenience init("
        static let selfInitStr = "\t\tself.init()\n"
        
        static func declareStr(uClassName: String) -> String {
            return "public class DO_\(uClassName) : Object {\n\n"
        }
        
        static func declareWrapFunc(uClassName: String) -> String {
            "\tfunc wrapTo\(uClassName)Object() -> \(uClassName) {\n\t\t"
        }
    }
    
    struct Object {
        
    }
    
    static let listKeyWord = [
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
    
    static let listDataTypeKeyWord = [
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
}


//struct KeyWord {
//    static let class = ""
//    static let operator = ""
//    static let deinit = ""
//    static let enum = ""
//    static let extension = ""
//    static let func = ""
//    static let import = ""
//    static let init = ""
//    static let let = ""
//    static let protocol = ""
//    static let static = ""
//    static let struct = ""
//    static let subscript = ""
//    static let typealias = ""
//    static let var = ""
//    static let break = ""
//    static let case = ""
//    static let continue = ""
//    static let default = ""
//    static let do = ""
//    static let else = ""
//    static let fallthrough = ""
//    static let if = ""
//    static let in = ""
//    static let for = ""
//    static let return = ""
//    static let switch = ""
//    static let where = ""
//    static let while = ""
//    static let as = ""
//    static let is = ""
//    static let new = ""
//    static let super = ""
//    static let self = ""
//    static let Self = ""
//    static let Type = ""
//    static let associativity = ""
//    static let didSet = ""
//    static let get = ""
//    static let infix = ""
//    static let inout = ""
//    static let mutating = ""
//    static let nonmutating = ""
//    static let operator = ""
//    static let override = ""
//    static let postfix = ""
//    static let precedence = ""
//    static let prefix = ""
//    static let set = ""
//    static let unowned = ""
//    static let weak = ""
//    static let Any = ""
//    static let AnyObject = ""
//}
