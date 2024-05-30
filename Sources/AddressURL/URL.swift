import Foundation
import Network

extension URL {
    // MARK: - Initializers
    /**
    - SeeAlso:
    [Swift by Sundell](https://www.swiftbysundell.com/articles/constructing-urls-in-swift/)
     */
    public init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }

    public init(httpAddress address: IPv4Address) {
        self = URLComponent.host("\(address)").url!.with(component: .scheme("http"))!
    }
	
	public init(httpsAddress address: IPv4Address) {
		self = URLComponent.host("\(address)").url!.with(component: .scheme("https"))!
	}
    
    public init(httpAddress address: IPv6Address) {
        self = URLComponent.host("[\(address)]").url!.with(component: .scheme("http"))!
    }
	
	public init(httpsAddress address: IPv6Address) {
		self = URLComponent.host("[\(address)]").url!.with(component: .scheme("https"))!
	}
    
    // TODO: I want url.component(.host) to return the URLComponent.host

    public func with(component: URLComponent, resolvingAgainstBaseURL: Bool = false) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: resolvingAgainstBaseURL) else {
            return nil
        }
        switch component {
        case .host(let host):
            components.host = host
        case .scheme(let scheme):
            components.scheme = scheme
        case .user(let user):
            components.user = user
        case .password(let password):
            components.password = password
        case .path(let path):
            components.path = path
		case .port(let port):
			components.port = port
        }
        return components.url
    }

    // MARK: - Helpers
    
    /**
    - SeeAlso:
     [TLDExtractSwift](https://github.com/gumob/TLDExtractSwift/blob/master/Source/TLDExtract.swift#L59)
     */
    public var hostname: String? {
        if let host = self.host {
            return host
        }
        guard let toParse = self.absoluteString.removingPercentEncoding else {
            return nil
        }
        let schemePattern: String = "^(\\p{L}+:)?//"
        let hostPattern: String = "([0-9\\p{L}][0-9\\p{L}-]{1,61}\\.?)?   ([\\p{L}-]*  [0-9\\p{L}]+)  (?!.*:$).*$".replacingOccurrences(of: " ", with: "", options: .regularExpression)
        if let regex: NSRegularExpression = try? NSRegularExpression(pattern: "^\(schemePattern)"), regex.matches(in: toParse, range: NSRange(location: 0, length: toParse.count)).count > 0 {
            let components: [String] = toParse.replacingOccurrences(of: schemePattern, with: "", options: .regularExpression).components(separatedBy: "/")
            guard let component: String = components.first, !component.isEmpty else { return nil }
            return component
        } else if let regex: NSRegularExpression = try? NSRegularExpression(pattern: "^\(hostPattern)"), regex.matches(in: toParse, range: NSRange(location: 0, length: toParse.count)).count > 0 {
            let components: [String] = toParse.replacingOccurrences(of: schemePattern, with: "", options: .regularExpression).components(separatedBy: "/")
            guard let component: String = components.first, !component.isEmpty else { return nil }
            return component
        }

        return nil
    }

    internal func dump_components() -> [String: Any?] {
        let dict: [String:Any?] = [
            "scheme": self.scheme,
            "user": self.user,
            "password": self.password,
            "host": self.host,
            "port": self.port,
            "path": self.path,
            "pathExtension": self.pathExtension,
            "pathComponents": self.pathComponents,
            "query": self.query,
            "baseUrl": self.baseURL,
            "fragment": self.fragment,
        ]
        return dict
    }

    /**
        When a URL recieves a string with out a valid schema it may still create the url, this will attempt to fix that
        as just settings the URLComponent.schema doesn't always give the desired output
     */
    public func with(scheme newScheme: String) -> URL? {
        var using = self
        if self.scheme != nil {
            using = self.with(component: .scheme(nil))!
        }
        var absStr = using.absoluteString
        if using.absoluteString.hasPrefix("//") {
            absStr = String(using.absoluteString.suffix(using.absoluteString.count - "//".count))
        }
        if newScheme.hasSuffix("://") {
            return URL(string: newScheme + absStr)
        } else if newScheme.hasSuffix(":") {
            return URL(string: newScheme + "//" + absStr)
        } else {
            return URL(string: newScheme + "://" + absStr)
        }
    }

    // MARK: - IPv4
    public var ipv4Address: IPv4Address? {
        guard let host = self.hostname else {
            return nil
        }
        return IPv4Address(host)
    }
    
    public var isIPv4: Bool {
        return self.ipv4Address != nil ? true : false
    }
    
    // MARK: - IPv6
    public var ipv6Address: IPv6Address? {
        guard let host = self.hostname else {
            return nil
        }
        return IPv6Address(host)
    }
    
    public var isIPv6: Bool {
        return self.ipv6Address != nil ? true : false
    }
}
