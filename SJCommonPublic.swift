

import Foundation
import UIKit
import Hue
import Alamofire
import SnapKit
import StoreKit
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let StatusBarH = UIApplication.shared.statusBarFrame.size.height

 let GetAppdelegate = UIApplication.shared.delegate as! AppDelegate





#if DEBUG

#else

#endif

/// 获取导航栏和状态栏高度
///
/// - Parameter nav: 导航栏
/// - Returns: 返回导航栏+状态栏高度
func NavBarHeightAndStatusHeight(nav:UINavigationController) -> CGFloat
{
    let nabbarHeight  = nav.navigationBar.frame.size.height
    return StatusBarH + nabbarHeight
}

//MARK: 控件自适应
func SCREEN_ADAPTATION(number: CGFloat) -> CGFloat {
    
    return number * SCREEN_WIDTH / 320.0 * (320 / 375)
}

// MARK:- 控件自适应高度
func SCREEN_ADATIONHEIGHT(number: CGFloat) -> CGFloat {
    let useHeight = SCREEN_HEIGHT - UIApplication.shared.statusBarFrame.size.height
    return number * useHeight / 667
}

//MARK: 字体自适应
func SCREEN_FONT_SIZE(Font: CGFloat) -> UIFont
{
    var font = UIFont()
    let fontsize = Font * SCREEN_WIDTH / 375
    font = UIFont.systemFont(ofSize: fontsize)
    return font
}
//MARK: 字体默认
func DEFAULT_SCREEN_FONT_SIZE() -> UIFont
{
    var font = UIFont()
    let fontsize = 12 * SCREEN_WIDTH / 375
    font = UIFont.systemFont(ofSize: fontsize)
    return font
}

// MARK:- 粗体
func BOLD_FOUNT_SIZE(font: CGFloat) -> UIFont {
    let ad_Font = font * SCREEN_WIDTH / 375
    let boldFont = UIFont.boldSystemFont(ofSize: ad_Font)
    return boldFont
}

func FONT_TEXTSTTLE_SIZE(_ font: CGFloat, _ style: String) -> UIFont {
    let f = font * SCREEN_WIDTH /  375.0
    let styleFont = UIFont(name: style, size: f)
    return styleFont!
}

/// 判断是否是IPHONEX系列
func ISIPHONEX() -> Bool {
    if UIScreen.main.bounds.height >= 812 {
        return true
    }
    return false
}
/// 判断是否是IPHONEP
func ISIPHONEPLUS() -> Bool {
    if UIScreen.main.bounds.width == 414 {
        return true
    }
    return false
}
func ISIPHONE6() -> Bool {
    if UIScreen.main.bounds.width == 375 {
        return true
    }
    return false
}
func ISIPHONE5() -> Bool {
    if UIScreen.main.bounds.width == 320 {
        return true
    }
    return false
}

/// 获取主界面
///
/// - Returns: Window
func WINDOW_GET_ROOVIEW () -> UIWindow
{
    return UIApplication.shared.keyWindow!
}

func HKDefaultLabel(_ lab: UILabel, _ font: CGFloat, _ style: String = TEXTSTYLE_REGULAR, _ color: String = "000000") {
    lab.textColor = UIColor(hex: color)
    let fontsize = font * SCREEN_WIDTH / 375
    lab.font = UIFont(name: style, size: fontsize)
}

// 设置Label,默认是黑色字体
func HKLable_Font_Color_Style(lab:UILabel, font: CGFloat, style: String = TEXTSTYLE_REGULAR, hexColor: String = "000000") {
    lab.textColor = UIColor(hex: hexColor)
    let fontsize = font * SCREEN_WIDTH / 375
    lab.font = UIFont(name: style, size: fontsize)
}
func HKButton_Font_Color_Style(button:UIButton, font: CGFloat, style: String, hexColor: String = "white") {
    if hexColor != "white" {
           button.titleLabel?.tintColor = UIColor(hex: hexColor)
         button.setTitleColor(UIColor(hex: hexColor), for: .normal)
    } else {
        button.setTitleColor(UIColor.white, for: .normal)
    }
    let fontsize = font * SCREEN_WIDTH / 375
      button.titleLabel?.font = UIFont(name: style, size: fontsize)

}

func PUBLICCALUATEIMAGEDATAWITHDATA(data:Data) -> (Float)
{
    return  Float(data.count)/1000.0/1000.0
}
/// 跳转设置界面
///
/// - Parameter scheme: 设置界面跳转
func open(scheme: String) {
    if let url = URL(string: scheme) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:],
                                      completionHandler: {
                                        (success) in
                                        //  print("Open \(scheme): \(success)")
            })
        } else {
            _ = UIApplication.shared.openURL(url)
            //   print("Open \(scheme): \(success)")
        }
    }
}



/// 获取系统当前语言
func getCurrentLangage() -> String {
    let preferrendL = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
    return preferrendL.first!
}

// MARK:读取本地化文件
func GETLOCALIZED(str:String)->(String)
{
    return  NSLocalizedString(str, comment: " ")
}

func LOCALIZED(_ str: String) -> String {
    return  NSLocalizedString(str, comment: " ")
}

// 获取App的版本号
func GetAppVerson() ->(String)
{
    let infoDic = Bundle.main.infoDictionary
    let appVersion :String = infoDic?["CFBundleShortVersionString"] as! String
    return appVersion
}

/// 获取系统通知开启的状态
func getNotificationEnable() -> Bool {
    let notiSetting = UIApplication.shared.currentUserNotificationSettings
    if notiSetting?.types != UIUserNotificationType.init(rawValue: 0) {
        return true
    } else {
        return false
    }
}

func scoreRequest () ->()
{
    if #available(iOS 10.3, *)
    {
        SKStoreReviewController.requestReview()
    }
    else
    {
        open(scheme: "itms-apps://itunes.apple.com/cn/app/id1290158252?mt=8")
    }
}
func GETUSERDEFAULT(str:String) -> (String)
{
    if let temp = UserDefaults.standard.string(forKey: str) {
        return temp
    }
    else
    {
        return ""
    }
}
func SETUSERDEFAULT(str:String,key:String)
{
    let temp = UserDefaults.standard
    temp.set(str, forKey: key)

}
func GETNOWTIME() ->(String)
{
    let date = NSDate()

    let timeFormatter = DateFormatter()

    timeFormatter.dateFormat = "yyyy-MM-dd"

    let strNowTime = timeFormatter.string(from: date as Date)
    return strNowTime
}
/// GCD定时器倒计时⏳
///   - timeInterval: 循环间隔时间
///   - repeatCount: 重复次数
///   - handler: 循环事件, 闭包参数： 1. timer， 2. 剩余执行次数
public func DispatchTimer(timeInterval: Double, repeatCount:Int, handler:@escaping (DispatchSourceTimer?, Int)->())
{
    if repeatCount <= 0 {
        return
    }
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    var count = repeatCount
    timer.schedule(wallDeadline: .now(), repeating: timeInterval)
    timer.setEventHandler(handler: {
        count -= 1
        DispatchQueue.main.async {
            handler(timer, count)
        }
        if count == 0 {
            timer.cancel()
        }
    })
    timer.resume()
}
/// GCD定时器循环操作
///   - timeInterval: 循环间隔时间
///   - handler: 循环事件
public func DispatchTimer(timeInterval: Double, handler:@escaping (DispatchSourceTimer?)->())
{
    let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    timer.schedule(deadline: .now(), repeating: timeInterval)
    timer.setEventHandler {
        DispatchQueue.main.async {
            handler(timer)
        }
    }
    timer.resume()
}
/// GCD延时操作
///   - after: 延迟的时间
///   - handler: 事件
public func DispatchAfter(after: Double, handler:@escaping ()->())
{
    DispatchQueue.main.asyncAfter(deadline: .now() + after) {
        handler()
    }
}

// MARK:- 自定义打印方法
func ZQQLog(_ messages : Any..., file : String = #file, funcName : String = #function, lineNum : Int = #line) {
    
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("\(fileName)[\(lineNum)], \(funcName):\(messages.description)")
    #endif
}
//func SETFIREBASE(Event:String,parameters:Dictionary<String, Any>?)
//{
//    if  (parameters != nil)
//    {
//        Analytics.logEvent(Event, parameters: parameters)
//    }
//    else
//    {
//        Analytics.logEvent(Event, parameters: nil)
//    }
//
//}
public extension Int {
    /*这是一个内置函数
     lower : 内置为 0，可根据自己要获取的随机数进行修改。
     upper : 内置为 UInt32.max 的最大值，这里防止转化越界，造成的崩溃。
     返回的结果： [lower,upper) 之间的半开半闭区间的数。
     */
    public static func randomIntNumber(lower: Int = 0,upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
    /**
     生成某个区间的随机数
     */
    public static func randomIntNumber(range: Range<Int>) -> Int {
        return randomIntNumber(lower: range.lowerBound, upper: range.upperBound)
    }
}
func GetPhonePrivate(str:String) ->(String)
{
    let starString = str.subStringStart(start: 0, length: 3)
    let endString = str.subStringStart(start: str.count - 4, length: 4)
    return starString + "****" + endString
}
func GetEmailPrivate(str:String)->(String)
{
    let rangel = str.positionOf(sub: "@")
    let tempStar = str.subStringStart(start: 0, length: rangel)
    let tempEnd = str.subStringStart(start: tempStar.count, length: str.count - tempStar.count)
    let starString = tempStar.subStringStart(start: 0, length: 2)
    let endString = tempStar.subStringStart(start: tempStar.count - 2, length: 2)
    return starString + "****" + endString + tempEnd
}




extension String {
    //根据开始位置和长度截取字符串
    func subStringStart(start:Int, length:Int = -1) -> String {
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy:start)
        let en = self.index(st, offsetBy:len)
        return String(self[st ..< en])
    }
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    /// 输出所有字体
    func PrintFonts() {
        let familyNames = UIFont.familyNames
        var index:Int = 0
        for familyName in familyNames
        {
            let fontNames = UIFont.fontNames(forFamilyName: familyName as String)
            for fontName in fontNames
            {
                index += 1
                print("序号\(index):\(fontName)")
            }
        }
    }
}
//  UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
// 计算文字高度或者宽度与weight参数无关
extension String {
    func ga_widthForComment(fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        return ceil(rect.width)
    }

    func ga_heightForComment(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        return ceil(rect.height)
    }

    func ga_heightForComment(fontSize: CGFloat, width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
    }
}
extension UIView {

    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
