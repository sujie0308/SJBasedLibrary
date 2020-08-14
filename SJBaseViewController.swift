//
//  BaseViewController.swift
//  SuperClean-Swift
//
//  Created by iMac on 2017/10/12.
//  Copyright © 2017年 iOS. All rights reserved.
//
import UIKit
enum enum_pushState {
    case poproot
    case dismiss
    case popBlock
}
enum enum_TopState
{
    case NavAndStateBar
    case stateBar
    case zero
}
typealias leftClickBlock = () -> ()
 class SJBaseViewController: UIViewController,UINavigationControllerDelegate {
    // MARK:=============对外暴露containerView
   public var containerView = UIView()
   public var strBackImage : String?

   public var str_ButtonBackTitle : String?
   public var pushState : enum_pushState?
    //containerView是否需顶到屏幕上访 针对导航栏透明需要透明
   public var TopState : enum_TopState? = .NavAndStateBar
    //containerView背景颜色
   public var backColor : UIColor? = UIColor.white
    //是否需要创建左侧返回按钮 默认创建
   public var Bool_Left_State :Bool? = true
    //是否取消手势返回 默认有手势
   public var Bool_TapBack : Bool? = true
    //左侧返回按钮block
   public var popBolck : leftClickBlock?
    //是否有标签栏 关系到containerView 默认没有
    public  var boolBarHidenState : Bool? = false
    public  var navBarHidden : Bool? = false
    public var Bool_ContainViewBottom : Bool? = false
    public var Bool_ViewNavBar :Bool? = false
    var view_NavBar = UIView()
     override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        if self.Bool_Left_State == true
        {
            setBackItem()
        }
       self.containerView.backgroundColor = backColor
        self.view.backgroundColor = UIColor.white
        setupContainerView()
        if self.Bool_ViewNavBar == true {
             self.view_NavBar.backgroundColor = UIColor.white
             self.view.addSubview(view_NavBar)
            view_NavBar.snp.makeConstraints { (make) in
                make.top.left.right.equalTo(0)
                if ISIPHONEX()
                {
                    make.height.equalTo(88)
                }
                else
                {
                   make.height.equalTo(64)
                }
            }
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        if  (Bool_TapBack  == true)
        {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        }
        else
        {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }

    
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    func setBackItem()
    {
        let btn = UIButton(type: .custom)
        if (strBackImage != nil)
        {
            btn.setImage(UIImage(named: strBackImage!), for: .normal)
        }
        else
        {
            btn.setImage(UIImage(named: "back_arrow"), for: .normal)
        }
        btn.frame.size = CGSize(width: 100, height: 40)
        if (str_ButtonBackTitle != nil)
        {
            btn.setTitle(str_ButtonBackTitle, for: .normal)
            let margin = SCREEN_ADAPTATION(number: 14)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: -margin)
            HKLable_Font_Color_Style(lab: btn.titleLabel!, font: 18, style: TEXTSTYLE_REGULAR)
        }
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(backItemClick), for: .touchUpInside)
        let backBarItem = UIBarButtonItem(customView: btn)
        self.navigationItem.leftBarButtonItem = backBarItem
    }
    @objc func backItemClick() {
        if (pushState == nil)
        {
            self.navigationController?.popViewController(animated: true)
           
            return
        }
         if pushState == enum_pushState.poproot {

            self.navigationController?.popToRootViewController(animated: true)
            
            return
        }
         if pushState == enum_pushState.dismiss
        {

            self.dismiss(animated: true) {

            }
            return
        }
        if pushState == enum_pushState.popBlock
        {
            self.popBolck?()
        }

    }


}

extension SJBaseViewController {

    fileprivate func setupNavBar() {
       
        // 1、设置导航栏标题属性：设置标题颜色
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:SCREEN_FONT_SIZE(Font: 15)]

        // 2、设置导航栏前景色：设置item指示色
        self.navigationController?.navigationBar.tintColor = UIColor.white

        // 3、设置导航栏半透明
        self.navigationController?.navigationBar.isTranslucent = true

        // 4、设置导航栏背景图片
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)

        // 5、设置导航栏阴影图片
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }



    fileprivate func setupContainerView() {
        view.addSubview(containerView)
        var top : CGFloat = 0
        var bottom : CGFloat = 0
        if TopState == enum_TopState.NavAndStateBar
        {
            if ISIPHONEX()
            {
                top = 88
            }
            else
            {
                top = 64
            }
            if self.boolBarHidenState == true
            {


                if ISIPHONEX()
                {
                    bottom =  84
                }
                else
                {
                    bottom = 49
                }
            }
            else
            {
                if ISIPHONEX()
                {
                    bottom = 35
                }
                else
                {
                    bottom  = 0
                }
            }
        }
        else if TopState == enum_TopState.stateBar
        {
            if ISIPHONEX()
            {
                top = 44
            }
            else
            {
               top = 20
            }
            if self.boolBarHidenState == true
            {

                if ISIPHONEX()
                {
                    bottom =  84
                }
                else
                {
                    bottom = 49
                }

            }
            else
            {
                if ISIPHONEX()
                {
                    bottom = 35
                }
                else
                {
                    bottom  = 0
                }

            }
        }
        else
        {
            top = 0
            if self.boolBarHidenState == true
            {
                if ISIPHONEX()
                {
                    bottom =  84
                }
                else
                {
                    bottom = 49
                }
            }
            else
            {
                if ISIPHONEX()
                {
                    bottom = 35
                }
                else
                {
                    bottom  = 0
                }

            }
        }

        if Bool_ContainViewBottom == true
        {

            if ISIPHONEX()
            {
                bottom = 0
            }
            else
            {
                bottom  = 0
            }
        }
        containerView.frame = CGRect(x: CGFloat( 0 ), y: top, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - bottom - top)
//
//            containerView.snp.makeConstraints { (make) in
//                make.left.right.equalToSuperview()
//                if TopState == enum_TopState.NavAndStateBar
//                {
//                    if ISIPHONEX()
//                    {
//                        make.top.equalTo(88)
//                    }
//                    else
//                    {
//                        make.top.equalTo(64)
//                    }
//                }
//                else if TopState == enum_TopState.stateBar
//                {
//                    if ISIPHONEX()
//                    {
//                        make.top.equalTo(44)
//                    }
//                    else
//                    {
//                        make.top.equalTo(20)
//                    }
//                }
//                else
//                {
//                 make.top.equalTo(0)
//                }
//                if self.boolBarHidenState == true
//                {
//                    if ISIPHONEX()
//                    {
//                        make.bottom.equalTo(-35)
//                    }
//                    else
//                    {
//                    make.bottom.equalTo(0)
//                    }
//                }
//                else
//                {
//
//                    if ISIPHONEX()
//                    {
//                      make.bottom.equalTo(-84)
//                    }
//                    else
//                    {
//                      make.bottom.equalTo(-49)
//                    }
//                }
//
//
//
//            }


    }
    
    open func setupTitle(title: String) {
        let titleLabel = UILabel()
        titleLabel.text = GETLOCALIZED(str: title)
        HKLable_Font_Color_Style(lab: titleLabel, font: 16, style: TEXTSTYLE_BOLD)
        navigationItem.titleView = titleLabel;
    }
}
