//
//  LoginVC.swift
//  wp
//
//  Created by 木柳 on 2016/12/17.
//  Copyright © 2016年 com.yundian. All rights reserved.
//

import UIKit
import SVProgressHUD
import DKNightVersion
class LoginVC: BaseTableViewController {
    
    @IBOutlet weak var qqBtn: UIButton!
    @IBOutlet weak var wechatBtn: UIButton!
    @IBOutlet weak var sinaBtn: UIButton!
    
    @IBOutlet weak var pwdView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    //MARK: --LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initUI()
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: Notification.Name(rawValue:AppConst.NotifyDefine.UpdateUserInfo), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: --DATA
    func initData() {
        NotificationCenter.default.addObserver(self, selector: #selector(errorCode(_:)), name: NSNotification.Name(rawValue: AppConst.WechatKey.ErrorCode), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkUpdateVC), name: NSNotification.Name(rawValue: AppConst.NoticeKey.updateSoftware.rawValue), object: nil)
    }
    //MARK: --UI
    func initUI() {
        phoneView.layer.borderWidth = 0.5
        phoneView.layer.borderColor = UIColor.init(rgbHex: 0xcccccc).cgColor
        pwdView.layer.borderWidth = 0.5
        pwdView.layer.borderColor = UIColor.init(rgbHex: 0xcccccc).cgColor
        
        loginBtn.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        qqBtn.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        wechatBtn.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        sinaBtn.dk_backgroundColorPicker = DKColorTable.shared().picker(withKey: AppConst.Color.main)
        if let phone = UserDefaults.standard.value(forKey: SocketConst.Key.phone) as? String{
            phoneText.text = phone
        }
        
    }
    //MARK: --手机号登录
    @IBAction func closeOrOpenEyes(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        pwdText.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        
        if checkTextFieldEmpty([phoneText,pwdText]){
            if isTelNumber(num: phoneText.text!) == false{
                SVProgressHUD.showErrorMessage(ErrorMessage: "手机号格式错误", ForDuration: 1, completion: nil)
                return
            }
            //登录
            let password = ((pwdText.text! + AppConst.sha256Key).sha256()+phoneText.text!).sha256()
            SVProgressHUD.showProgressMessage(ProgressMessage: "登录中...")
            let param = LoginParam()
            param.pwd = password
            param.phone = phoneText.text!
            AppAPIHelper.login().login(param: param, complete: { [weak self]( result) -> ()? in
                SVProgressHUD.dismiss()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConst.NotifyDefine.RequestPrice), object: nil)
                //存储用户信息
                if result != nil{
                    UserDefaults.standard.set(self?.phoneText.text!, forKey: SocketConst.Key.phone)
                    UserModel.share().upateUserInfo(userObject: result!)
                }else{
                    SVProgressHUD.showErrorMessage(ErrorMessage: "登录失败，请稍后再试", ForDuration: 1, completion: nil)
                }
                return nil
            }, error: errorBlockFunc())
        }
        
    }
    
    func loginSuccess() {
        dismissController()
    }
    
    //MARK: --微信登录
    @IBAction func wechatBtnTapped(_ sender: UIButton) {
        let req = SendAuthReq.init()
        req.scope = AppConst.WechatKey.Scope
        req.state = AppConst.WechatKey.State
        WXApi.send(req)
    }
    func errorCode(_ notice: NSNotification) {
        let param = WechatLoginParam()
        param.openId = UserModel.share().wechatUserInfo[SocketConst.Key.openid]!
        //微信登录
        AppAPIHelper.login().login(param: param, complete: { ( result) -> ()? in
            SVProgressHUD.dismiss()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConst.NotifyDefine.RequestPrice), object: nil)
            //存储用户信息
            if result != nil{
                UserModel.share().upateUserInfo(userObject: result!)
            }else{
                SVProgressHUD.showErrorMessage(ErrorMessage: "登录失败，请稍后再试", ForDuration: 1, completion: nil)
            }
            return nil
        }, error: { [weak self](error) -> ()?in
            UserModel.share().registerType = .wechatPass
            //第三方登录成功
            self?.performSegue(withIdentifier: RegisterVC.className(), sender: nil)
            return nil
        })

        
    }
    
    //MARK: --忘记密码
    @IBAction func forgetPwdBtnTapped(_ sender: UIButton) {
        UserModel.share().registerType = .forgetPass
    }
    //MARK: --快速注册
    @IBAction func registerBtnTapped(_ sender: UIButton) {
        UserModel.share().registerType = .loginPass
    }
    //MARK: --新浪登录
    @IBAction func sinaBtnTapped(_ sender: UIButton) {
        
    }
    //取消登录
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismissController()
    }
}
