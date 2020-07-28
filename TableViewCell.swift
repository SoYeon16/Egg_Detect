//
//  TableViewCell.swift
//  TextDetect
//
//  Created by ㅇ on 10/03/2019.
//  Copyright © 2019 Assignment. All rights reserved.
//
import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var exp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
