//
//  SportGroupViewController.swift
//  Will
//
//  Created by Jinhao Fan on 2020/4/18.
//  Copyright © 2020 com.rdhy.will. All rights reserved.
//

import UIKit
import AttributedLib
import HandyJSON
import SwiftyUserDefaults
import SnapKit
enum AuditStatusCompany: Int, HandyJSONEnum {
    case status_default = 0 // 审核中
    case status_pass    = 1 // 已通过
    case status_refuse  = 2 // 已拒绝
    
    var image: UIImage {
        switch self {
        case .status_default:
            return #imageLiteral(resourceName: "company_status_ing")
        case .status_pass:
            return #imageLiteral(resourceName: "company_status_ok")
        case .status_refuse:
            return #imageLiteral(resourceName: "company_status_not")
        }
    }
}

class CompanyInfoModel: BaseModel {
    var id: Int?
    var name: String?
    var short_name: String?
    var total_members: Int = 0
    var department_count: Int?
    var company_id: Int?
    var audit_status: AuditStatusCompany?
    var area: String?
    var administrator_name: String?
    var logo_url: String?
    var administrator_phone: String?
    var company_code: String?
    var company_pwd: String?
    var region_name: String?
    var region_id: Int?
    var description: String?
    var join_status: Int?
    var service_status: UserJoinStatus?
    var is_join: Int?
    var is_administrator: Bool?
    var total_distance: Int = 0
    var trade: String?
    var is_private: Bool = false // 是否可以被搜索
    var audit_open_status: Bool = false // 审核开关是否开启
    var company_pwd_status: Bool = false // 密码开关
    var scale_type: Int?
    var industry_id: Int?
    var institutional_nature_id: Int?
    
    /***
     * region_id:industry_id:institutional_nature_id:scale_type
     * ps.0000,1111
     * self_update_status: 4位二进制，分别代表如上
     */
    var self_update_status: String?
    
    var industry_string: String? {
        if let industry_id = self.industry_id, let json = CompanyEnv.host?.industry, let string = json["\(industry_id)"] as? String { // 行业
            return string
        }
        return nil
    }
    
    var scale_type_string: String? {
        if let scale_type = self.scale_type, let json = CompanyEnv.host?.scale, let string = json["\(scale_type)"] as? String { // 规模
            return string
        }
        return nil
    }
    
    var institutional_nature_string: String? {
        if let institutional_nature_id = self.institutional_nature_id, let json = CompanyEnv.host?.institutional_nature, let string = json["\(institutional_nature_id)"] as? String  { // 性质
            return string
        }
        return nil
    }
    var sport_info: SportInfoModel?
    var join_users: JoinUsersModel?
}

enum UserJoinStatus: Int, HandyJSONEnum {
    case canApply = 1 // 可以申请
    case audit = 2 // 审核中
    case applyOthers = 3 // 申请或者加入其他
    case isMember = 4 // 已是成员
}

private class PageUserModel: BaseModel {
    var data = [RunTeamRankModel]()
    var user_rank: RunTeamRankModel?
}

private class ActivityModel: BaseModel {
    var data: [QualifyData]?
}

class SportInfoModel: BaseModel {
    var total_distance: Int?
    var total_duration: Int?
    var calories: Int?
    var total_step: Int?
    
    var stepString: (String, String, String) {
        if let step = total_step?.more100WString() {
            return (String(step), "步", "\n累计步数")
        }
        return ("0", "步", "累计步数")
    }
    
    var distanceString: (String, String, String) {
        if let distance = total_distance {
            return (distance.km2.more100WString(), "公里", "\n累计里程")
        }
        return ("0", "公里", "累计里程")
    }
    
    var kcalString: (String, String, String) {
        if let cal = calories?.more100WString() {
            return ("\(cal)", "千卡", "\n累计消耗")
        }
        return ("0", "千卡", "累计消耗")
    }
}

class JoinUsersModel: BaseModel {
    var data: [UserFaceModel]?
    var total_number: Int?
    var userString: String {
        if let total = total_number {
            return "\(total)名成员"
        }
        return ""
    }
}

class UserFaceModel: BaseModel {
    var face: String?
}

class SportGroupViewController: BaseTableViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var id: Int?
    
    private var model: CompanyInfoModel? {
        didSet {
            guard let mm = model else {
                return
            }
            let attr1 = Attributes {
                let paraph = NSMutableParagraphStyle()
                paraph.alignment = .center
                return $0.foreground(color: UIColor.white)
                    .font(UIFont.bebasNeue(size: 19))
                    .paragraphStyle(paraph)
            }
            let attr2 = Attributes {
                let paraph = NSMutableParagraphStyle()
                paraph.alignment = .center
                return $0.foreground(color: UIColor.hexColor(hex: 0xfeffff))
                    .font(UIFont.regularFont(size: 12))
                    .paragraphStyle(paraph)
            }
            let attr3 = Attributes {
                let paraph = NSMutableParagraphStyle()
                paraph.alignment = .center
                return $0.foreground(color: UIColor.hexColor(hex: 0x8e8f94))
                    .font(UIFont.regularFont(size: 12))
                    .paragraphSpacing(6)
                    .paragraphStyle(paraph)
            }
            
            companyIconView.nk_setImage(urlString: mm.logo_url, placeholderImage: #imageLiteral(resourceName: "company_empty"))
            companyNameLabel.text = mm.name
            if let id = mm.id, let region = mm.region_name {
                areaLabel.text = "ID:\(id) · \(region)"
            }
            areaLabel.sizeToFitWidth()
            companyStatusBtn.qmui_left = areaLabel.qmui_right + 6
            companyStatusBtn.setImage(mm.audit_status?.image, for: .normal)
            companyStatusBtn.isHidden = false
            if let sport_info = mm.sport_info {
                leftLabel.attributedText = sport_info.stepString.0.at.attributed(with: attr1)
                    + sport_info.stepString.1.at.attributed(with: attr2)
                    + sport_info.stepString.2.at.attributed(with: attr3)
                centerLabel.attributedText = sport_info.distanceString.0.at.attributed(with: attr1)
                    + sport_info.distanceString.1.at.attributed(with: attr2)
                    + sport_info.distanceString.2.at.attributed(with: attr3)
                rightLabel.attributedText = sport_info.kcalString.0.at.attributed(with: attr1)
                    + sport_info.kcalString.1.at.attributed(with: attr2)
                    + sport_info.kcalString.2.at.attributed(with: attr3)
            }
            iconsBaseView.removeAllSubViews()
            if let icons = mm.join_users?.data {
                for (i, icon) in icons.enumerated() {
                    let iconView = UIImageView(frame: CGRect(x: 12 + (8 + 24) * CGFloat(i), y: 16, width: 24, height: 24))
                    iconView.defaultCorner()
                    iconsBaseView.addSubview(iconView)
                    if i == 6 {
                        if icons.count > 7 {
                            iconView.image = #imageLiteral(resourceName: "person_more")
                        } else {
                            iconView.nk_setImage(urlString: icon.face, placeholderImage: #imageLiteral(resourceName: "defaults_user_icon"))
                        }
                        break
                    } else {
                        iconView.nk_setImage(urlString: icon.face, placeholderImage: #imageLiteral(resourceName: "defaults_user_icon"))
                    }
                }
            }
            let l = UILabel(frame: CGRect(x: iconsBaseView.qmui_width-120, y: 0, width: 94, height: 56))
            l.textAlignment = .right
            l.textColor = UIColor.hexColor(hex: willGray9)
            l.font = UIFont.regularFont(size: 13)
            l.text = mm.join_users?.userString
            iconsBaseView.addSubview(l)
            let img = UIImageView(frame: CGRect(x: iconsBaseView.qmui_width-20, y: 22, width: 6, height: 12))
            img.image = #imageLiteral(resourceName: "ic_right_arrow")
            iconsBaseView.addSubview(img)
        }
    }
    
    private var activityArr = [QualifyData]()
    
    private var userArr = [RunTeamRankModel]()
    
    private var me: RunTeamRankModel?
    
    var detailModel: CompanyInfoModel?
    
    private lazy var topBaseView: UIView = {
        let base = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 182 + 56))
        base.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoMemberList))
        base.addGestureRecognizer(tap)
        return base
    }()
    
    private lazy var topView: UIView = {
       let base = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 182))
        // fillCode
        let bgLayer = CAGradientLayer()
        bgLayer.colors = [UIColor(red: 0.21, green: 0.21, blue: 0.28, alpha: 0.4).cgColor, UIColor(red: 0.11, green: 0.11, blue: 0.15, alpha: 1).cgColor]
        bgLayer.locations = [0, 1]
        bgLayer.frame = base.bounds
        bgLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgLayer.endPoint = CGPoint(x: 0.5, y: 1)
        base.layer.addSublayer(bgLayer)
        base.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoSettingVc))
        base.addGestureRecognizer(tap)
        return base
    }()
    
    private lazy var companyIconView: UIImageView = {
        let icon = UIImageView(frame: CGRect(x: 15, y: 27, width: 60, height: 60))
        icon.cornerRadius(radius: 2)
        icon.nk_setImage(urlString: self.detailModel?.logo_url, placeholderImage: nil)
        return icon
    }()
    
    private lazy var companyNameLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: companyIconView.qmui_right + 11, y: 31, width: kScreenW - companyIconView.qmui_right - 11 - 34, height: 28))
        l.textColor = .white
        l.font = UIFont.mediumFont(size: 20)
        l.textAlignment = .left
        l.text = self.detailModel?.name
        return l
    }()
    
    private lazy var areaLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: companyNameLabel.qmui_left, y: companyNameLabel.qmui_bottom + 6, width: kScreenW - companyIconView.qmui_right - 11 - 34, height: 17))
        l.textColor = UIColor.hexColor(hex: 0x8e8f94)
        l.font = UIFont.regularFont(size: 12)
        l.textAlignment = .left
        l.text = self.detailModel?.region_name
        return l
    }()
    
    private lazy var companyStatusBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: areaLabel.qmui_right, y: areaLabel.qmui_top, width: 52, height: 16)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(clickAlert), for: .touchUpInside)
        return btn
    }()
    
    private lazy var rightArrow: UIImageView = {
       let img = UIImageView(frame: CGRect(x: kScreenW - 34, y: 48, width: 18, height: 18))
        img.image = #imageLiteral(resourceName: "running_setting")
        return img
    }()
    
    private lazy var leftLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: 0, y: companyIconView.qmui_bottom, width: kScreenW/3, height: topView.qmui_height-companyIconView.qmui_bottom))
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    private lazy var centerLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: kScreenW/3, y: companyIconView.qmui_bottom, width: kScreenW/3, height: topView.qmui_height-companyIconView.qmui_bottom))
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    private lazy var rightLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: kScreenW*2/3, y: companyIconView.qmui_bottom, width: kScreenW/3, height: topView.qmui_height-companyIconView.qmui_bottom))
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    
    private lazy var iconsBaseView: UIView = {
        let base = UIImageView(frame: CGRect(x: 14, y: topView.qmui_bottom, width: kScreenW-28, height: 56))
        base.cornerRadius(radius: 4)
        base.backgroundColor = UIColor.hexColor(hex: willBlackLight)
        return base
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Defaults.show_rungroup_tost == false || Defaults.show_rungroup_tost == nil   {
         
            let viewTemp = TeamGudanceSecond()
            GetAppdelegate.tabbar.view.addSubview(viewTemp)
                                      viewTemp.snp.makeConstraints { (make) in
                                          make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                                      }
                                   viewTemp.btSend.addTapBlock {
                                     openWebVC(urlStr: URLUSEBOOK, vc: GetAppdelegate.nav_Tabbar)
                                    DispatchAfter(after: 1) {
                                         viewTemp.removeSelf()
                                    }
                                   }
             Defaults.show_rungroup_tost = true
            
        }
       
        headerLoadData()
       
    }
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
          
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//              if #available(iOS 11.0, *) {
//              self.tableView.contentInsetAdjustmentBehavior = .never
//          } else {
//              self.automaticallyAdjustsScrollViewInsets = false
//          }
        
          
         fd_prefersNavigationBarHidden = true
        style = .grouped
        fd_interactivePopDisabled = true
        tableView.tableHeaderView = topBaseView
        configTopView()
        view.addSubview(tableView)
        tableView.register(ActivityCell.self, forCellReuseIdentifier: "ActivityCell.ID123")
        tableView.register(RunGroupHomeRankTableViewCell.self, forCellReuseIdentifier: RunGroupHomeRankTableViewCell.ID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mj_header = MJDIYHeader(refreshingTarget: self, refreshingAction: #selector(headerLoadData))
    
        NotificationCenter.default.addObserver(self, selector: #selector(loadRankData), name: NSNotification.Name(rawValue: "refresh_rank"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadCompanyInfo), name: NSNotification.Name(rawValue: "loadCompanyInfo"), object: nil)
        CompanyEnv.shared.getCompanyInfo()
        CompanyEnv.shared.getAllRegion()
        tableView.snp.makeConstraints { (make) in
            if ISIPHONEX()
                       {
                        make.top.equalTo(44)
                        make.bottom.equalTo(-84)
                       }
                       else
                       {
                          make.top.equalTo(20)
                        make.bottom.equalTo(-49)
                       }
            make.left.right.equalTo(0 )
        }
    }
    
    @objc func headerLoadData() {
      
        loadCompanyInfo()
        loadActivityData()
        loadRankData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
    }
    
    private func configTopView() {
        topBaseView.addSubview( topView)
        topBaseView.addSubview(iconsBaseView)
        // Top
        topView.addSubview(companyIconView)
        topView.addSubview(companyNameLabel)
        topView.addSubview(areaLabel)
        topView.addSubview(companyStatusBtn)
        topView.addSubview(rightArrow)
        topView.addSubview(leftLabel)
        topView.addSubview(centerLabel)
        topView.addSubview(rightLabel)
        // user icons
        
    }
    
    @objc private func clickAlert() {
        guard let model = self.model, self.model?.audit_status == .status_refuse, self.model?.is_administrator == true else {
            return
        }
        Alert(title: "运动团未认证，请认真填写机构信息后重新认证，如有疑问请联系客服:18500631005", message: "", cancelTitle: "取消", confimTitle: "重新认证", cancel: nil) {
            let vc = EditSportGroupInfoViewController()
            vc.model = model
            GetAppdelegate.nav_Tabbar.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func tapMoreRank() {
        let vc = RunTeamRankMainViewController()
        vc.cid = self.id
        vc.companyName = self.model?.name
        GetAppdelegate.nav_Tabbar.pushViewController(vc, animated: true)
    }
    
    private func tapMoreActivity() {
        let vc = RunGroupActivityTableViewController()
        vc.title = "运动团活动"
        GetAppdelegate.nav_Tabbar.pushViewController(vc, animated: true)
    }
    
    @objc func gotoMemberList() {
        let attention = RunTeamUserViewController()
        GetAppdelegate.nav_Tabbar.pushViewController(attention, animated: true)
    }
    
    @objc func gotoSettingVc() {
        let vc = SportGroupSettingViewController()
        vc.applyModel = self.detailModel
        vc.id = self.id
        vc.pushState = "center"
        GetAppdelegate.nav_Tabbar.pushViewController(vc, animated: true)
    }
    
    @objc func loadRankData() {

        var param = [String: Any]()
        param["start_at"] = Date().zeroDate()?.dateToString(dateFormat: "yyyy-MM-dd")
        param["period_type"] = "daily"
        param["sport_type"] = "sport_walk"
        param["page"] = 1
        param["count"] = 10
        _ = NetworkManager.request(ContestTarget.run_group_rank(dic: param))
            .mapModel(PageUserModel.self)
            .subscribe(onNext: { (model) in
                self.me = model.user_rank
                if let me = self.me {
                    self.userArr = [me]
                    self.userArr.append(contentsOf: model.data)
                } else {
                    self.userArr = model.data
                }
    
                self.tableView.mj_header?.endRefreshing()
            }, onError: { (error) in
                self.tableView.mj_header?.endRefreshing()
            })
    }
    
    private func loadActivityData() {
        _ = NetworkManager.request(ContestTarget.company_activity(page: 1))
            .mapModel(ActivityModel.self).subscribe(onNext: { (model) in
                if let arr = model.data {
                    self.activityArr = arr
                }
                self.loadCustomActivityData()
            }, onError: { (error) in
                
            })
    }
    
    private func loadCustomActivityData() {
        _ = NetworkManager.request(ContestTarget.new_Lists(token: UserInfo.shared.loginkey!, page: 1, count: 10))
            .mapArray(QualifyData.self).subscribe(onNext: { (arr) in
                self.activityArr.append(contentsOf: arr)
                self.tableView.reloadData()
            }, onError: { (error) in
                self.tableView.reloadData()
            })
    }
    
    @objc private func loadCompanyInfo() {
        guard let id = self.id ?? self.detailModel?.id else {
            return
        }
        _ = NetworkManager.request(DiscoverTarget.getCompanyInfo(id: id))
            .mapModel(CompanyInfoModel.self)
            .subscribe(onNext: { (model) in
                self.model = model
            }, onError: { (error) in
            })
    }
}

 class ActivityCell: UITableViewCell {
    
    static let ID = "ActivityCell"
    
    override var frame: CGRect{
        didSet {
            var newFrame = frame
            newFrame.size.width = kScreenW - 28
            newFrame.origin.x = 14
            super.frame = newFrame
        }
    }
    
    var model: QualifyData? {
        didSet {
            guard let mm = model else {
                return
            }
            if mm.image_url != nil {
                baseView.nk_setImage(urlString: mm.image_url, placeholderImage: nil)
                statusLable.backgroundColor = .clear
                statusLable.text = ""
                timeLabel.text = ""
                titleLabel.text = ""
                departmentLabel.text = ""
                return
            }
            if mm.jumpurl != "" {
                         baseView.nk_setImage(urlString: mm.url!, placeholderImage: nil)
                           statusLable.backgroundColor = .clear
                                       statusLable.text = ""
                                       titleLabel.text = ""
                                       timeLabel.text = ""
                                        departmentLabel.text = ""
                         return
             }
            statusLable.textColor = mm.status?.color
            statusLable.backgroundColor = mm.status?.bg_color
            statusLable.text = mm.status?.string
            titleLabel.text = mm.name
            if let start = mm.start_at, let end = mm.end_at, let start_str = Date.timeStringToDate(start)?.dateToString(dateFormat: "M月d日"), let end_str = Date.timeStringToDate(end)?.dateToString(dateFormat: "M月d日") {
                timeLabel.text = "活动时间：\(start_str)-\(end_str)"
            }
            if let type = mm.bg_style {
                baseView.nk_setImage(urlString: ACTIVITY_BG + "banner\(type).png", placeholderImage: nil)
            }
            if let type = mm.qualifying_type?.string, let memberType = mm.user_type?.string {
                departmentLabel.text = type + " · " + memberType
            }
        }
    }
    
    lazy var baseView: UIImageView = {
       let base = UIImageView(frame: CGRect(x: 14, y: 0, width: kScreenW - 56, height: 118))
        base.contentMode = .scaleToFill
        base.cornerRadius(radius: 6)
        return base
    }()
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: 18, y: 16, width: baseView.qmui_width-18, height: 25))
        l.textAlignment = .left
        l.font = UIFont.mediumFont(size: 18)
        l.textColor = .white
        return l
    }()
    
    private lazy var timeLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: 18, y: titleLabel.qmui_bottom + 6, width: baseView.qmui_width-18, height: 17))
        l.textAlignment = .left
        l.font = UIFont.regularFont(size: 12)
        l.textColor = .hexColor(hex: 0xFEFFFF)
        return l
    }()
    
    private lazy var departmentLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: 18, y: timeLabel.qmui_bottom + 23, width: baseView.qmui_width-18, height: 18))
        l.textAlignment = .left
        l.font = UIFont.mediumFont(size: 13)
        l.textColor = .hexColor(hex: 0xFEFFFF)
        return l
    }()
    
    private lazy var statusLable: UILabel = {
        let l = UILabel(frame: CGRect(x: baseView.qmui_width-52, y: 0, width: 52, height: 21))
        l.font = UIFont.regularFont(size: 12)
        l.textAlignment = .center
        l.backgroundColor = .clear
        l.roundCorners([.bottomLeft], radius: 6)
       return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubview(baseView)
        backgroundColor = UIColor.hexColor(hex: willBlackLight)
        baseView.addSubview(titleLabel)
        baseView.addSubview(timeLabel)
        baseView.addSubview(departmentLabel)
        baseView.addSubview(statusLable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SportGroupViewController: UITableViewDelegate, UITableViewDataSource {
        
    @objc func sectionClick(_ sender: UIButton) {
        if sender.tag == 0 {
            if self.activityArr.count > 0 {
                tapMoreActivity()
            }
        } else {
            tapMoreRank()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.activityArr.count > 3 {
                return 3
            }
            else
            {
                return self.activityArr.count
               
            }
      
        
        }
       
        return self.userArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58 + 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 2 {
//            let base = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 58 + 12))
//            base.backgroundColor = UIColor.hexColor(hex: willBlackDark)
//            return base
//        }
        let base = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 58 + 12))
        let baseBgView = UIView(frame: CGRect(x: 14, y: 12, width: kScreenW-28, height: 58))
        baseBgView.backgroundColor = UIColor.hexColor(hex: willBlackLight)
        baseBgView.roundCorners([.topLeft, .topRight], radius: 4)
        let l = UILabel(frame: CGRect(x: 14, y: 18, width: kScreenW/2, height: 22))
        l.textAlignment = .left
        l.textColor = .white
        l.font = UIFont.mediumFont(size: 16)
        baseBgView.addSubview(l)
        let more = UILabel(frame: CGRect(x: baseBgView.qmui_width/2, y: 20, width: baseBgView.qmui_width/2-26, height: 18))
        more.textAlignment = .right
        more.textColor = UIColor.hexColor(hex: willGray9)
        more.font = UIFont.regularFont(size: 13)
        baseBgView.addSubview(more)
        let img = UIImageView(frame: CGRect(x: baseBgView.qmui_width-20, y: 22, width: 6, height: 12))
        img.image = #imageLiteral(resourceName: "ic_right_arrow")
        baseBgView.addSubview(img)
        if section == 0 {
            l.text = "运动团活动"
            if self.activityArr.count >= 3 {
                more.text = "查看更多"
            } else {
                more.text = ""
                img.image = nil
            }
        } else {
            l.text = "每日步数排行榜"
            more.text = "更多榜单排行"
        }
        let btn = UIButton(type: .custom)
        btn.frame = baseBgView.bounds
        base.addSubview(baseBgView)
        baseBgView.addSubview(btn)
        btn.tag = section
        btn.addTarget(self, action: #selector(sectionClick(_:)), for: .touchUpInside)
        return base
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 && self.userArr.count >= 11 {
            return 57
        }
        if section == 0 && self.activityArr.count == 0 {
            return 50
        }
        if section == 1 && self.userArr.count == 0 {
            return 50
        }
        if section == 2
        {
            return 0
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let bottom = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 4))
        let bg = UIView(frame: CGRect(x: 14, y: 0, width: kScreenW - 28, height: 4))
        bg.backgroundColor = UIColor.hexColor(hex: willBlackLight)
        bottom.addSubview(bg)
        if section == 1 && self.userArr.count >= 11 {
            bg.frame = CGRect(x: 14, y: 0, width: kScreenW-28, height: 57)
            let btn = UIButton(type: .custom)
            btn.setTitle("查看更多 >>", for: .normal)
            btn.addTarget(self, action: #selector(tapMoreRank), for: .touchUpInside)
            btn.frame = bg.bounds
            btn.setTitleColor(UIColor.hexColor(hex: willGray9), for: .normal)
            btn.titleLabel?.font = UIFont.regularFont(size: 12)
            bg.addSubview(btn)
        } else if (section == 0 && self.activityArr.count == 0) || (section == 1 && self.userArr.count == 0) {
            bg.frame = CGRect(x: 14, y: 0, width: kScreenW-28, height: 50)
            let l = UILabel(frame: CGRect(x: 0, y: 10, width: bg.bounds.width, height: 17))
            l.textAlignment = .center
            l.textColor = UIColor.hexColor(hex: 0x939399)
            l.font = UIFont.regularFont(size: 12)
            if section == 0 {
                l.text = "- 暂无活动 -"
            } else {
                l.text = "- 暂无数据 -"
            }
            bg.addSubview(l)
        } else {
            bg.frame = CGRect(x: 14, y: 0, width: kScreenW - 28, height: 4)
        }
        bg.roundCorners([.bottomLeft, .bottomRight], radius: 4)
        return bottom
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//            if scrollView == tableView
//            {
//                  let sectionHeaderHeight = CGFloat(70.0)//headerView的高度
//                      if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
//                      {
//
//                          scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0);
//
//                      }
//                      else if (scrollView.contentOffset.y >= sectionHeaderHeight)
//                      {
//
//                          scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0);
//                      }
//      
//      }
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 118 + 12
        }
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell.ID123") as! ActivityCell
            cell.model = self.activityArr[indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: RunGroupHomeRankTableViewCell.ID) as! RunGroupHomeRankTableViewCell
        cell.likeEnabled = true
        if self.me != nil {
            if indexPath.row == 0 {
                if self.userArr.count > 0 {
                    self.userArr[indexPath.row].index = self.userArr[indexPath.row].rank
                }
                cell.likeEnabled = false
            } else {
                self.userArr[indexPath.row].index = indexPath.row
            }
        } else {
            self.userArr[indexPath.row].index = indexPath.row + 1
        }
        cell.model = self.userArr[indexPath.row]
        
        if indexPath.row == 0 && self.me != nil {
            if self.userArr.count > 1 {
                cell.line.isHidden = false
            }
        } else {
            cell.line.isHidden = true
        }
        cell.likeSuccess = { id in
            if id == self.me?.uid, self.me != nil, let count = self.me?.like_count, self.userArr.count > 0 {
                self.me?.like_count = count + 1
                self.userArr[0].like_count = count + 1
                self.tableView.reloadData()
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row < self.activityArr.count, indexPath.section == 0, let url = self.activityArr[indexPath.row].url {
                if self.activityArr[indexPath.row].jumpurl != "" && self.activityArr[indexPath.row].jumpurl != nil
                           {
                               let web = WebViewController(url: self.activityArr[indexPath.row].jumpurl!)
                               GetAppdelegate.nav_Tabbar.pushViewController(web, animated: true)
                           }
                           else
                           {
                               let web = WebViewController(url: url)
                               GetAppdelegate.nav_Tabbar.pushViewController(web, animated: true)
                           }
            }
        }
    }
}
