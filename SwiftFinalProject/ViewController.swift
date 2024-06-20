import UIKit

class ViewController: UIViewController {
    
    var images: [String] = ["Çilek","Domates","Elma","Havuç","Mango","Portakal","Ananas","Armut","Avokado","Ayva","Patlıcan","Sarımsak","Soğan","Salatalık","Üzüm","Mandalina","Nar","Muz","Kayısı","Karpuz"]

    var labels: [String: String] = ["Çilek": "10 TL","Domates": "8 TL","Elma": "5 TL","Havuç": "4 TL","Mango": "12 TL","Portakal": "6 TL","Ananas": "15 TL","Armut": "7 TL","Avokado": "14 TL","Ayva": "9 TL","Patlıcan": "5 TL","Sarımsak": "20 TL","Soğan": "3 TL","Salatalık": "4 TL","Üzüm": "10 TL","Mandalina": "7 TL","Nar": "8 TL","Muz": "10 TL","Kayısı": "12 TL","Karpuz": "25 TL"]

    var selectedItems: [String: (price: String, count: Int)] = [:]
    var totalPrice: Double = 0.0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalPriceLabel: UILabel! // Toplam fiyatı göstermek için bir UILabel ekleyin
  
    @IBAction func payButton(_ sender: Any) {
        totalPrice = 0.0
        selectedItems.removeAll()
        tableView.reloadData()
        totalPriceLabel.text = "Toplam Fiyat: 0.0 TL"
        let alertController = UIAlertController(title: "Ödeme Yapıldı", message: "Ödemeniz başarıyla gerçekleştirildi.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ekran boyutunu kontrol et
        if !isSupportedDevice() {
            let alertController = UIAlertController(title: "Desteklenmeyen Cihaz", message: "Bu uygulama sadece 10 inç ve üzeri cihazlarda çalışır.", preferredStyle: .alert)
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
        totalPriceLabel.text = "Toplam Fiyat: 0.0 TL" // Başlangıç değeri
    }
    
    func updateTotalPrice() {
        totalPrice = selectedItems.reduce(0.0) { (result, item) -> Double in
            let priceString = item.value.price.replacingOccurrences(of: " TL", with: "")
            let price = Double(priceString) ?? 0.0
            return result + (price * Double(item.value.count))
        }
        totalPriceLabel.text = "Toplam Fiyat: \(totalPrice) TL"
    }

    func isSupportedDevice() -> Bool {
        let screenSize = UIScreen.main.bounds.size
        let screenScale = UIScreen.main.scale
        let screenWidth = screenSize.width * screenScale
        let screenHeight = screenSize.height * screenScale
        
        // PPI değerlerini belirleyin (Apple cihazları için)
        let ppi: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            ppi = 264 // Genel iPad PPI değeri
        case .phone:
            ppi = 326 // Genel iPhone PPI değeri
        default:
            ppi = 163 // Varsayılan PPI değeri
        }
        
        let widthInInches = screenWidth / ppi
        let heightInInches = screenHeight / ppi
        let diagonalInInches = sqrt(pow(widthInInches, 2) + pow(heightInInches, 2))
        
        return diagonalInInches >= 7.0
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.cornerRadius = 25
        
        let imageName = images[indexPath.row]
        cell.TitleLabel.text = imageName
        cell.imageView.image = UIImage(named: imageName)
        
        if let price = labels[imageName] {
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
        let selectedItemName = images[indexPath.item]
        if let selectedItemPrice = labels[selectedItemName] {
            if var item = selectedItems[selectedItemName] {
                item.count += 1
                selectedItems[selectedItemName] = item
            } else {
                selectedItems[selectedItemName] = (price: selectedItemPrice, count: 1)
            }
            tableView.reloadData()
            updateTotalPrice() // Toplam fiyatı güncelle
            print("Seçilen öğeler: \(selectedItems)")
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SelectedItemCell
        let selectedItemName = Array(selectedItems.keys)[indexPath.row]
        if let selectedItem = selectedItems[selectedItemName] {
            cell.itemLabel.text = "\(selectedItemName) - \(selectedItem.price) - Adet: \(selectedItem.count)"
            cell.onDelete = {
                if selectedItem.count > 1 {
                    self.selectedItems[selectedItemName]?.count -= 1
                } else {
                    self.selectedItems.removeValue(forKey: selectedItemName)
                }
                self.tableView.reloadData()
                self.updateTotalPrice()
            }
        }
        return cell
    }
}

extension ViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let selectedItemName = Array(selectedItems.keys)[indexPath.row]
        let dragItem = UIDragItem(itemProvider: NSItemProvider(object: selectedItemName as NSString))
        dragItem.localObject = selectedItemName
        return [dragItem]
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: selectedItems.count - 1, section: 0)
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                tableView.performBatchUpdates {
                    let selectedItemName = Array(selectedItems.keys)[sourceIndexPath.row]
                    if var selectedItem = selectedItems[selectedItemName] {
                        selectedItem.count += 1
                        selectedItems[selectedItemName] = selectedItem
                        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                    }
                }
                coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
            }
        }
        updateTotalPrice()
    }
    }

