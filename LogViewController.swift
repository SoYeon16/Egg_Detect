//
//  LogViewController.swift
//  TextDetect
//
//  Created by 이소연 on 07/03/2019.
//  Copyright © 2019 Assignment. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class EggData: Object{
    @objc dynamic var fullID = ""
    @objc dynamic var expDate = ""
}

protocol SendDataDelegate {
    func sendData(data: String)
}

class LogViewController: UITableViewController{
    
    var eggData : Results<EggData>!
    let realm = try? Realm()
    var delegate: SendDataDelegate?
    var eggId: String? = "vv4r6"
    
    @IBOutlet weak var tableV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tableV.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //가져온 데이터를 리스트형태로 배치합니다. User Name 이름을 오른차순으로 정렬합니다.
        eggData = realm?.objects(EggData.self).sorted(byKeyPath: "fullID", ascending: false)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "삭제") { (action, index) in
            do{
                try self.realm?.write{
                    self.realm?.delete(self.eggData![indexPath.row])
                    self.tableView.reloadData()
                }
            } catch{
                print("\(error)")
            }
        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
    //MARK: 셀 갯수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = eggData?.count {
            return count
        }else {
            return 1
        }
    }
    
    //MARK: 셀 정보 입력
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        if let db = eggData?[indexPath.row]{
            cell.id.text = db.fullID
            cell.exp.text = db.expDate
        }
        
        return cell
    }

    
    @objc func tapped (_ sender: UITapGestureRecognizer) {
        let tappedLocation: CGPoint = sender.location(in: tableV)
        let indexPath = tableV.indexPathForRow(at: tappedLocation)
        
        if let db = eggData?[indexPath!.row]{
            eggId = db.fullID
            delegate?.sendData(data: eggId!)
            performSegue(withIdentifier: "passLogId", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passLogId" {
            let viewController : ThirdViewController = segue.destination as! ThirdViewController
            viewController.data = eggId!
        }
    }

}
