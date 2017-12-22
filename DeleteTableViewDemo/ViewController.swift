//
//  ViewController.swift
//  DeleteTableViewDemo
//
//  Created by mac on 2017/12/22.
//  Copyright © 2017年 mac. All rights reserved.
//

import UIKit

let kTableViewCell = "tableViewCell"

class ViewController: UIViewController {

    // MARK: - Property
    var cellDataArray : [cellData]!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        initTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Init Data
    func initData() {
        cellDataArray = [cellData]()
        
        var data = cellData.init()
        for i in 0...10 {
            data.dataString = "第\(i)行"
            cellDataArray.append(data)
        }
    }

    // MARK: - Init View
    func initTableView() {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height == 812 ? 44 : 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        tableView.backgroundColor = .lightGray
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
}

// MARK: - UITableView Delegate && DataSource
extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kTableViewCell)
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: kTableViewCell)
        }
        
        cell?.textLabel?.text = cellDataArray[indexPath.row].dataString
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        //重置该属性，防止已点击删除后，再次进入点击删除直接删除
        cellDataArray[indexPath.row].isPrepareDelete = false

        let isReadAction = UITableViewRowAction.init(style: .normal, title: "标为未读") { (rowAction, index) in

//            tableView.setEditing(false, animated: true)
        }

        let deleteAction = UITableViewRowAction.init(style: .destructive, title: "删除") { (rowAction, index) in
            //action 为确认删除时直接删除该 cell
            if self.cellDataArray[index.row].isPrepareDelete {
                self.cellDataArray.remove(at: index.row)
                tableView.deleteRows(at: [index], with: .automatic)
                return
            }

            if #available(iOS 11.0, *) {
//                //仍需改进
//                var swipeActionView : UIView?
//                for subView in tableView.subviews {
//                        if subView.classForCoder.debugDescription() == "UISwipeActionPullView" {
//                        swipeActionView = subView
//                        break
//                    }
//                }
//
//                var outCount : UInt32 = 0
//                let propertys = class_copyIvarList(swipeActionView?.classForCoder, &outCount)
//                for i in 0...(Int(outCount) - 1) {
//                    print(String.init(utf8String: ivar_getName(propertys![i])!) ?? "")
//                }
//
//                if let swipeView = swipeActionView {
//                    if let buttons = swipeView.value(forKey: "_buttons") as? [UIButton] {
//                        if let firstAction = buttons.first , let lastAction = buttons.last {
//                            firstAction.setTitle("确认删除", for: .normal)
//                            lastAction.setTitle("", for: .normal)
//                        }
//                    }
//                }
                
            }
            var deleteConfirmView : UIView?

            if let subViews = tableView.cellForRow(at: index)?.subviews {
                for subView in subViews {
                    if subView.classForCoder.debugDescription() == "UITableViewCellDeleteConfirmationView" {
                        deleteConfirmView = subView
                        break
                    }
                    
                }
            }
            
            if let confirmView = deleteConfirmView {
                if let actionButtons = confirmView.value(forKey: "_actionButtons") as? [AnyObject] {
                    if let firstAction = actionButtons.first as? UIButton , let lastAction = actionButtons.last as? UIButton {
                        self.cellDataArray[index.row].isPrepareDelete = true
                        UIView.animate(withDuration: 0.35, animations: {
                            firstAction.setTitle("确认删除", for: .normal)
                            firstAction.frame = confirmView.bounds
                            lastAction.setTitle("", for: .normal)
                            lastAction.frame = CGRect.init(x: 0, y: 0, width: 0, height: lastAction.frame.height)
                        })
                    }
                }
            }
        }

        return [deleteAction,isReadAction]
    }
    
}

struct cellData {
    var dataString : String!
    var isPrepareDelete : Bool! = false         //标识 cell 是否在确认删除阶段
}

