//
//  BankCardVC.swift
//  wp
//
//  Created by sum on 2017/1/11.
//  Copyright © 2017年 com.yundian. All rights reserved.
//
class SelectBankVC: BaseListTableViewController {
    var selectNumber = Int()
    
    var dataArry : [BankListModel] = []
    
    
    override func viewDidLoad() {
        selectNumber = 100000
        self.title = "我的银行卡"
        super.viewDidLoad()
        
        
        initUI()
        
        
    }
    func initUI(){
    
        
        // 设置 提现记录按钮
        let btn : UIButton = UIButton.init(frame: CGRect.init(x: 20, y: 0, width: 70, height: 30))
        
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        btn.setTitle("完成", for:  UIControlState.normal)
        
        btn.addTarget(self, action: #selector(finish), for: UIControlEvents.touchUpInside)
        
        let barItem :UIBarButtonItem = UIBarButtonItem.init(customView: btn as UIView)
        self.navigationItem.rightBarButtonItem = barItem
    }
    func finish(){
        
        if selectNumber != 100000 {
            let  Model : BankListModel = self.dataArry[selectNumber]
            
            ShareModel.share().selectBank  =  Model
            
            self.navigationController?.popViewController(animated: true)
        }
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        self.didRequest()
    }
    override func didRequest() {
        AppAPIHelper.user().bankcardList(complete: { [weak self](result) -> ()? in
            
            if let object = result {
                
                let Model : BankModel = object as! BankModel
                self?.didRequestComplete(Model.cardlist as AnyObject)
                self?.dataArry = Model.cardlist!
                
                self?.tableView.reloadData()
                
            }else {
                
                self?.didRequestComplete(nil)
            }
            
            return nil
            }, error: errorBlockFunc())
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return dataArry.count
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        
        return 15
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell : BindingBankVCCell = tableView.dequeueReusableCell(withIdentifier: "BankCardVCCell") as! BindingBankVCCell
        
        
        let  Model : BankListModel = self.dataArry[indexPath.section]
        
        cell.update(Model.self)
        cell.accessoryType =  UITableViewCellAccessoryType .none
        
        if indexPath.section == selectNumber {
            cell.accessoryType =  UITableViewCellAccessoryType .checkmark
        }
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        selectNumber = indexPath.section
        
       
        tableView.reloadData()
        
        
    }
    
    
    
}