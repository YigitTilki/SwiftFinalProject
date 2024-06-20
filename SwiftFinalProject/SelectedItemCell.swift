//
//  SelectedItemCell.swift
//  SwiftFinalProject
//
//  Created by Yiğit Tilki on 20.06.2024.
//

import UIKit

class SelectedItemCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var itemLabel: UILabel!
    
    var onDelete: (() -> Void)?
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        onDelete?()
    }
    
}
