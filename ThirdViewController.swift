//
//  ThirdViewController.swift
//  TextDetect
//
//  Created by ㅇ on 15/03/2019.
//  Copyright © 2019 Assignment. All rights reserved.
//

import UIKit
import AWSCore
import AWSDynamoDB
import AWSMobileClient


class ThirdViewController: UIViewController{
    @IBOutlet weak var eggId: UITextField!
    @IBOutlet weak var eggDate: UITextView!
    @IBOutlet weak var eggFarmName: UITextView!
    @IBOutlet weak var eggFarmAdress: UITextView!
    @IBOutlet weak var eggEnvironment: UITextView!
    @IBOutlet weak var eggwarningDate: UITextView!
    @IBOutlet weak var warningMessage: UITextView!
    @IBOutlet weak var warningAI: UITextView!
    
    var data: String = ""
    var id: String = ""
    var delegate: SendDataDelegate?
    let locationInfo = ["전라남도 보성군", "경상북도 김천시", "경상북도 예천군"] //AI 발생 시 배열 고쳐야 하는 부분!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eggId.text = data
        let newData = data.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if((newData.count) >= 10){
            let month = newData.prefix(2)
            var start = newData.index(newData.startIndex, offsetBy: 2)
            var end = newData.index(newData.endIndex, offsetBy: -6)
            var range = start..<end
            let day = newData[range]
            eggDate.text = "\(month)월 \(day)일"
            date_calculation(eggmonth: month, eggday: day)
            
            start = newData.index(newData.startIndex, offsetBy: 4)
            end = newData.index(newData.endIndex, offsetBy: -1)
            range = start..<end
            id = String(newData[range])
        }
        else {
            eggDate.text = "표기 되어있지 않습니다."
            id = String(newData.prefix(5))
        }
        readEgg(id: id)
        let environment = newData.suffix(1)
        eggEnvironment.text = readEnvironment(environment: String(environment))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                    self.eggFarmName.text = objectModel?.dictionaryValue["_name"] as? String
                    self.eggFarmAdress.text = objectModel?.dictionaryValue["_address"] as? String
                    
                    let line = "\(self.eggFarmAdress.text!)"
                    
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
    
    func date_calculation(eggmonth: String.SubSequence, eggday: Substring){
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
        
        let eggdate:Date = dateFormatter.date(from: egg)!
        let interval = date.timeIntervalSince(eggdate)
        let days = Int(interval / 86400)
        let consumedate:Date = Calendar.current.date(byAdding: .day, value: 45, to: eggdate)!
        var warningday:Int = 0
        let eggWarningDay = dateFormatter.string(from: consumedate)
        
        if days <= 40 {
            self.eggwarningDate.textColor = UIColor.green
            self.eggwarningDate.text = "\(String(describing: eggWarningDay))\n드셔도 좋아요~^^"
        }
        else if days > 40 && days <= 45 {
            warningday = 45 - days
            self.eggwarningDate.textColor = UIColor.orange
            self.eggwarningDate.text = "\(String(describing: eggWarningDay))\n\(warningday)일 남았어요!"
        }
        else {
            warningday = days - 45
            self.eggwarningDate.textColor = UIColor.red
            self.eggwarningDate.text = "\(String(describing: eggWarningDay))\n\(warningday)일 지났어요!!!"
        }
        self.warningMessage.textColor = UIColor.gray
        self.warningMessage.text = "단, 달걀을 찬물에 담궜을 때 물에 뜨거나 흔들었을 때 소리가 난다면 섭취 불가"
    }
    
}
