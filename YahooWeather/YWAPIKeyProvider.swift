//
//  YWAPIKeyProvider.swift
//  YahooWeather
//
//  Created by yuchen on 2017/8/28.
//  Copyright © 2017年 Yuchen Zhan. All rights reserved.
//

import UIKit

class YWAPIKeyProvider: NSObject {
    
    // APIKey should be read from external and be set only from internal.
    public private(set) var apiKey: String? {
        get {
            guard let key = UserDefaults.standard.string(forKey: "apiKey") else {
                return extractAPIKeyFromFile()
            }
            
            return key
        }
        
        set {
            self.apiKey = newValue
        }
    }
    
    func extractAPIKeyFromFile() -> String {
        var apiKey = ""
        guard let filePath = Bundle.main.path(forResource: "api_key", ofType: nil) else {
            debugPrint("Cannot find file contains apiKey.")
            return apiKey
        }
        
        do {
            let data = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            let lines: [String] = data.components(separatedBy: .newlines)
            
            for line in lines {
                
                // Ignore empty lines
                if line.characters.count == 0 {
                    continue
                }
                
                let components = line.characters.split{ $0 == " " }.map(String.init)
                if components[0] == "key" {
                    apiKey = components[1]
                    
                    debugPrint("apiKey: \(apiKey)")
                    
                    // Save to NSUserdefaults
                    UserDefaults.standard.set(apiKey, forKey: "apiKey")
                    break;
                }
            }
            
            return apiKey
            
        } catch {
            debugPrint("Could not read apiKey from file.")
        }
    }
}
