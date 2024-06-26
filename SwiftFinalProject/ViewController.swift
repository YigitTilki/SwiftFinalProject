import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalPriceLabel: UILabel!

    @IBAction func payButton(_ sender: Any) {
        DataManager.shared.clearSelection()
        tableView.reloadData()
        totalPriceLabel.text = "Toplam Fiyat: 0.0 TL"
        let alertController = UIAlertController(title: "Ödeme Yapıldı", message: "Ödemeniz başarıyla gerçekleştirildi.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isSupportedDevice() {
            let alertController = UIAlertController(title: "Desteklenmeyen Cihaz", message: "Bu uygulama sadece 7 inç ve üzeri ekran boyutuna sahip iPad'lerde çalışır.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Tamam", style: .default, handler: { _ in
                exit(0)
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        totalPriceLabel.text = "Toplam Fiyat: 0.0 TL"
    }
    
    func updateTotalPriceLabel() {
        let totalPrice = DataManager.shared.updateTotalPrice()
        totalPriceLabel.text = "Toplam Fiyat: \(totalPrice) TL"
    }
    
    func isSupportedDevice() -> Bool {
        let screenSize = UIScreen.main.bounds.size
        let screenScale = UIScreen.main.scale
        let screenWidth = screenSize.width * screenScale
        let screenHeight = screenSize.height * screenScale
        
        let ppi: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            ppi = 264
        case .phone:
            ppi = 326
        default:
            ppi = 163
        }
        
        let widthInInches = screenWidth / ppi
        let heightInInches = screenHeight / ppi
        let diagonalInInches = sqrt(pow(widthInInches, 2) + pow(heightInInches, 2))
        
        return UIDevice.current.userInterfaceIdiom == .pad && diagonalInInches >= 7.0
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.shared.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.cornerRadius = 25
        
        let imageName = DataManager.shared.images[indexPath.row]
        cell.TitleLabel.text = imageName
        cell.imageView.image = UIImage(named: imageName)
        
        if let price = DataManager.shared.labels[imageName] {
            cell.priceLabel.text = price
        } else {
            cell.priceLabel.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 10) / 4
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItemName = DataManager.shared.images[indexPath.item]
        if let selectedItemPrice = DataManager.shared.labels[selectedItemName] {
            if var item = DataManager.shared.selectedItems[selectedItemName] {
                item.count += 1
                DataManager.shared.selectedItems[selectedItemName] = item
            } else {
                DataManager.shared.selectedItems[selectedItemName] = (price: selectedItemPrice, count: 1)
            }
            tableView.reloadData()
            updateTotalPriceLabel()
            print("Seçilen öğeler: \(DataManager.shared.selectedItems)")
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.selectedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SelectedItemCell
        let selectedItemName = Array(DataManager.shared.selectedItems.keys)[indexPath.row]
        if let selectedItem = DataManager.shared.selectedItems[selectedItemName] {
            cell.itemLabel.text = "\(selectedItemName) - \(selectedItem.price) - Adet: \(selectedItem.count)"
            cell.onDelete = {
                if selectedItem.count > 1 {
                    DataManager.shared.selectedItems[selectedItemName]?.count -= 1
                } else {
                    DataManager.shared.selectedItems.removeValue(forKey: selectedItemName)
                }
                self.tableView.reloadData()
                self.updateTotalPriceLabel()
            }
        }
        return cell
    }
}

extension ViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let selectedItemName = Array(DataManager.shared.selectedItems.keys)[indexPath.row]
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: selectedItemName as NSString))
        dragItem.localObject = selectedItemName
        return [dragItem]
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: DataManager.shared.selectedItems.count - 1, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                tableView.performBatchUpdates {
                    let selectedItemName = Array(DataManager.shared.selectedItems.keys)[sourceIndexPath.row]
                    if var selectedItem = DataManager.shared.selectedItems[selectedItemName] {
                        selectedItem.count += 1
                        DataManager.shared.selectedItems[selectedItemName] = selectedItem
                        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                    }
                }
                coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
            }
        }
        updateTotalPriceLabel()
    }
}
