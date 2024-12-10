//
//  SummaryList.swift
//  DLE
//
//  Created by meet sharma on 17/07/23.
//

import Foundation

struct SummaryList:Codable {
    var date:String?
    var time:String?
    enum CodingKeys: String, CodingKey {
        case date,time
    }
}
