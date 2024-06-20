//
//  ViewController.swift
//  SwiftFinalProject
//
//  Created by Yiğit Tilki on 20.06.2024.
//

import UIKit

class ViewController: UIViewController {
    
    var images: [String] = ["çilek","domates","elma","havuç","mango","portakal","ananas","armut","avakado","ayva","patlıcan","sarımsak","soğan","salatalık","üzüm","mandalina","nar","muz","kayısı","karpuz"]

    var labels: [String] = ["çilek","domates","elma","havuç","mango","portakal","ananas","armut","avakado","ayva","patlıcan","sarımsak","soğan","salatalık","üzüm","mandalina","nar","muz","kayısı","karpuz"]
    var selectedItems: [String] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        tableView.dataSource = self
        tableView.delegate = self
    }
    


}

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.cornerRadius = 25
        
        cell.TitleLabel.text = images[indexPath.row]
        cell.imageView.image = UIImage(named: images[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 10)/4
        return CGSize(width: size, height: size)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedItem = labels[indexPath.item]
            selectedItems.append(selectedItem)
            tableView.reloadData()
            print("Seçilen öğeler: \(selectedItems)")
        }
    
    
    
}
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = selectedItems[indexPath.row]
        return cell
    }}
