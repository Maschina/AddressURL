//
//  File.swift
//  
//
//  Created by Zachary Gorak on 2/15/20.
//

import Foundation
import Network

extension IPv6Address {
    public init?(url: URL) {
        guard let host = url.hostname else {
            return nil
        }
        self.init(host)
    }

	public var httpUrl: URL {
		return URL(httpAddress: self)
	}
	
	public var httpsUrl: URL {
		return URL(httpsAddress: self)
	}
}
