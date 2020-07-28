//
//  SecondViewController.swift
//  TextDetect
//
//  Created by 이소연 on 20/02/2019.
//  Copyright © 2019 Assignment. All rights reserved.
//

//import Foundation
import UIKit
import AWSCore
import AWSDynamoDB
import AWSMobileClient
import RealmSwift

protocol sendBackDelegate {
    func dataReceived(data: String)
}

typealias TimeInterval = Double

class SecondViewController: UIViewController {
    @IBOutlet weak var receivedText: UITextField!
    @IBOutlet weak var spawningDate: UITextView!
    @IBOutlet weak var information: UITextView!
    @IBOutlet weak var information2: UITextView!
    @IBOutlet weak var breedingEnvironment: UITextView!
    @IBOutlet weak var warningDate: UITextView!
    @IBOutlet weak var warningMessage: UITextView!
    @IBOutlet weak var warningAI: UITextView!
    
    var delegate : sendBackDelegate?
    var data:String = ""
    var id: String = ""
    var eggWarningDate: String! = " "
    var farmname: String = " "
    var farmaddress: String = " "
    let locationInfo = ["전라남도 보성군", "경상북도 김천시", "경상북도 예천군"] //AI 발생 시 배열 고쳐야 하는 부분!
    
    var eggData : EggData?
    let realm = try? Realm()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveData(){
        if eggData == nil{
            addEggData()
        }else{
            updateEggData()
        }
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Person Data 을 Realm에 추가합니다.
    func addEggData(){
        eggData = EggData()
        eggData = inputDataToEggData(db: eggData!)
        //input Realm
        try? realm?.write {
            realm?.add((eggData)!)
        }
    }
    
    //MARK: Person Data Update
    // Realm의 데이터 수정, 삭제가 있을 경우 1) Realm.Write()  2) Realm 에서 가져온 데이터의 값을 변경합니다.
    func updateEggData(){
        try? realm?.write {
            eggData = inputDataToEggData(db: eggData!)
        }
    }
    
    //MARK: Person Data에 Data을 저장하고, Realm에 저장합니다.
    func inputDataToEggData(db :EggData) -> EggData{
        if let ID = receivedText.text {
            db.fullID = ID
        }
        
        if let exp = eggWarningDate{
            db.expDate = exp
        }
        return db
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        data = data.uppercased()
        receivedText.text = data

        let newData = data.trimmingCharacters(in: .whitespacesAndNewlines)

        if((newData.count) >= 10){
            let month = newData.prefix(2)
            var start = newData.index(newData.startIndex, offsetBy: 2)
            var end = newData.index(newData.endIndex, offsetBy: -6)
            var range = start..<end
            let day = newData[range]
            spawningDate.text = "\(month)월 \(day)일"
            
            eggWarningDate = date_calculation(eggmonth: month, eggday: day)
            start = newData.index(newData.startIndex, offsetBy: 4)
            end = newData.index(newData.endIndex, offsetBy: -1)
            range = start..<end
            id = String(newData[range])
        }
        else {
            spawningDate.text = "표기 되어있지 않습니다."
            id = String(newData.prefix(5))
        }
        
        readEgg(id: id)
        let environment = newData.suffix(1)
        breedingEnvironment.text = readEnvironment(environment: String(environment))
        
        saveData()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func readEgg(id: String){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        dynamoDbObjectMapper.load(
            NewEggy.self,
            hashKey: id,
            rangeKey: nil,
            completionHandler: {
                (objectModel: AWSDynamoDBObjectModel?, error: Error?) -> Void in
                if let error = error {
                    print("Amazon DynamoDB Read Error: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.information.text = objectModel?.dictionaryValue["_name"] as? String
                    self.information2.text = objectModel?.dictionaryValue["_address"] as? String
                    
                    let line = "\(self.information2.text!)"
                    
                    for i in 0..<self.locationInfo.count{
                        if (line.hasPrefix(self.locationInfo[i])){
                            self.warningAI.text = "\(self.locationInfo[i])\n위 지역은 조류 인플루엔자 발생지역이므로\n섭취에 주의하십시오."
                        }
                    }
                 }
        })
        
    }
    
    func readEnvironment(environment: String) -> String {
        if(environment == "1"){
            return "방사사육"
        }
        else if(environment == "2"){
            return "축사내 평사"
        }
        else if(environment == "3"){
            return "개선된 케이지"
        }
        else if (environment == "4"){
            return "기존 케이지"
        }
        else {
            return ""
        }
    }
    
    func date_calculation(eggmonth: String.SubSequence, eggday: Substring) -> String{
        let date = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var egg: String = ""
        var eggyear: Int = 0
        
        if eggmonth == "12" && components.month == 1 {
            eggyear = components.year! - 1
            egg = "\(eggyear)-\(eggmonth)-\(eggday)"
        }
        else {
            eggyear = components.year!
            egg = "\(eggyear)-\(eggmonth)-\(eggday)"
        }
        
        let eggdate: Date = dateFormatter.date(from: egg)!
        let interval = date.timeIntervalSince(eggdate)
        let days = Int(interval / 86400)
        let consumedate: Date = Calendar.current.date(byAdding: .day, value: 45, to: eggdate)!
        var warningday: Int = 0
        let eggWarningDay = dateFormatter.string(from: consumedate)
        
         if days <= 40 {
         self.warningDate.textColor = UIColor.green
            self.warningDate.text = "\(String(describing: eggWarningDay))\n드셔도 좋아요~^^"
         }
         else if days > 40 && days <= 45 {
         warningday = 45 - days
         self.warningDate.textColor = UIColor.orange
            self.warningDate.text = "\(String(describing: eggWarningDay))\n\(warningday)일 남았어요!"
         }
         else {
         warningday = days - 45
         self.warningDate.textColor = UIColor.red
            self.warningDate.text = "\(String(describing: eggWarningDay))\n\(warningday)일 지났어요!!!"
         }
         self.warningMessage.textColor = UIColor.gray
         self.warningMessage.text = "단, 달걀을 찬물에 담궜을 때 물에 뜨거나 흔들었을 때 소리가 난다면 섭취 불가"
        
        return eggWarningDay
    }
    
}
