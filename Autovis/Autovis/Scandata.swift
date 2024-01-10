//
//  Scandata.swift
//  Autovis
//
//  Created by Josh Halbert on 5/22/23.
//

import Foundation

struct Scandata:Identifiable {
    var id = UUID()
    let content:String
    
    init(content:String){
        self.content = content
    }
}
