import Foundation

extension NSObject {
    static var identifier:String{
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }
}
