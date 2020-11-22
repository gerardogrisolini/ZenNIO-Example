//
//  DeviceInfo.swift
//  
//
//  Created by Gerardo Grisolini on 22/11/20.
//

import Foundation

public struct DeviceInfo: Codable {
    public let deviceInfoAs, city, country, countryCode: String
    public let isp: String
    public let lat, lon: Double
    public let org, query, region, regionName: String
    public let status, timezone, zip: String
    
    enum CodingKeys: String, CodingKey {
        case deviceInfoAs = "as"
        case city, country, countryCode, isp, lat, lon, org, query, region, regionName, status, timezone, zip
    }

    public init() {
        deviceInfoAs = ""
        city = ""
        country = ""
        countryCode = ""
        isp = ""
        lat = 0
        lon = 0
        org = ""
        query = ""
        region = ""
        regionName = ""
        status = ""
        timezone = ""
        zip = ""
    }
}
