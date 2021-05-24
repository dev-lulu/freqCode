<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
  
  
import Foundation
import UIKit

extension String {
    func toDateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = self
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        let defaultTimeZoneStr = formatter.string(from: date)
        
        return defaultTimeZoneStr
    }
}

public protocol Storyboarded {
    static func instantiate(_ name: String) -> Self
}

public extension Storyboarded where Self: UIViewController {
    static func instantiate(_ name: String) -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)

        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]

        // load our storyboard
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)

        // instantiate a view controller with that identifier, and force cast as the type that was requested
        let vc = storyboard.instantiateViewController(withIdentifier: className) as! Self

        return vc
    }

}

protocol MiniHttp {
    static func getResult(urlString:String, comp:@escaping((Self) -> Void))
}

extension MiniHttp where Self:Decodable {
    static func getResult(urlString:String, comp:@escaping((Self) -> Void)) {
        guard let url = URL(string: urlString) else { return }
        #if DEBUG
        print(urlString)
        #endif
        
        URLSession.shared.dataTask(with: url) { data, response, err in
            guard let d = data else { return }
            
            do {
                let rss = try JSONDecoder().decode(Self.self, from: d)
                DispatchQueue.main.async {
                    comp(rss)
                }
           } catch  {
                print("error : \(String(describing: error))")
            }
        }.resume()
    }
}


struct Charts:Decodable, MiniHttp {
    var chartList:[ChartVO]
}

struct ChartVO:Decodable {
    var id, rank:Int
    var title, singer, imageUrl:String
    
    /// imageName.jpeg -> imageName
    var imgName:String {
        guard imageUrl.contains(".") else { return imageUrl }
        return imageUrl.components(separatedBy: ".")[0]
    }
    
    /// 세부정보 URL string
    var url:String {
        let domain = "http://localhost:3300/v1/chart/detail/"
        return "\(domain)\(id)"
    }
}
