import UIKit

class DataManager {
    static let shared = DataManager()

    var images: [String] = ["Çilek","Domates","Elma","Havuç","Mango","Portakal","Ananas","Armut","Avokado","Ayva","Patlıcan","Sarımsak","Soğan","Salatalık","Üzüm","Mandalina","Nar","Muz","Kayısı","Karpuz"]

    var labels: [String: String] = ["Çilek": "10 TL","Domates": "8 TL","Elma": "5 TL","Havuç": "4 TL","Mango": "12 TL","Portakal": "6 TL","Ananas": "15 TL","Armut": "7 TL","Avokado": "14 TL","Ayva": "9 TL","Patlıcan": "5 TL","Sarımsak": "20 TL","Soğan": "3 TL","Salatalık": "4 TL","Üzüm": "10 TL","Mandalina": "7 TL","Nar": "8 TL","Muz": "10 TL","Kayısı": "12 TL","Karpuz": "25 TL"]

    var selectedItems: [String: (price: String, count: Int)] = [:]
    var totalPrice: Double = 0.0

    private init() {}

    func updateTotalPrice() -> Double {
        totalPrice = selectedItems.reduce(0.0) { (result, item) -> Double in
            let priceString = item.value.price.replacingOccurrences(of: " TL", with: "")
            let price = Double(priceString) ?? 0.0
            return result + (price * Double(item.value.count))
        }
        return totalPrice
    }

    func clearSelection() {
        selectedItems.removeAll()
        totalPrice = 0.0
    }
}
