//
//  ViewController.swift
//  Drop Shop
//
//  Created by Fabian Mikaelsson on 2017-02-21.
//  Copyright © 2017 Fabian Mikaelsson. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "ShopItem"
fileprivate let screenWidth = UIScreen.main.bounds.width

// amount deposited?

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var addToCartAnimation: UIButton!
    @IBOutlet weak var quantityView: UIView!
    
    let shop: Shop
    var currentSelection: ProductSelection?
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let dictionary = try PlistCoverter.dictionary(fromFile: "Products", ofType: "plist")
            let inventory = try InventoryUnarchiver.products(fromDictionary: dictionary)
            self.shop = TShirtProducts(inventory: inventory)
            
        } catch let error {
            fatalError("\(error)")
        }
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViewCells()
        
        updateDisplayWith(totalPrice: 0.0, itemPrice: 0.0, itemQuantity: 1)
        hideButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupCollectionViewCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let padding: CGFloat = 10
        let itemWidth = screenWidth/3 - padding
        let itemHeight = screenWidth/3 - padding
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - SHOP
    
    
    
    @IBAction func addToCart() {
        if let currentSelection = currentSelection {
            do {
                try shop.choice(selection: currentSelection, quantity: Int(quantityStepper.value))
                // Update desplay??
                updateDisplayWith(totalPrice: 0.0, itemPrice: 0, itemQuantity: 1)
                hideButtons()
            } catch SelectProductError.outOfStock {
                showAlert()
                
            } catch {
                //FIXME
            }
            
            if let IndexPath = collectionView.indexPathsForSelectedItems?.first {
                collectionView.deselectItem(at: IndexPath, animated: true)
                updateCell(having: IndexPath, selected: false)
            }
        }
    }
    
    
    func updateDisplayWith(totalPrice: Double? = nil, itemPrice: Double? = nil, itemQuantity: Int? = nil) {
        if let totalValue = totalPrice {
            totalLabel.text = "$\(totalValue)"
        }
        if let priceValue = itemPrice {
            priceLabel.text = "$\(priceValue)"
        }
        if let quantityValue = itemQuantity {
            quantityLabel.text = "\(quantityValue)"
        }
    }
    
    func updateTotalPrice(for item: ShopItem) {
        let totalPrice  = item.price * quantityStepper.value
        updateDisplayWith(totalPrice: totalPrice)
    }
    
    @IBAction func updateQuantity(_ sender: UIStepper) {
        let quantity = Int(quantityStepper.value)
        updateDisplayWith(itemQuantity: quantity)
        
        if let currentSelection = currentSelection, let item = shop.item(forSelection: currentSelection) {
            updateTotalPrice(for: item)
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Out of Stock", message: "This item is unavailable at this time", preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        
        updateDisplayWith(totalPrice: 0.0, itemPrice: 0.0, itemQuantity: 1)
    }
    
    // MARK: - DATASOURCE
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shop.selection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCell else { fatalError() }
        
        let item = shop.selection[indexPath.row]
        cell.productView.image = item.icon()
        
        return cell
    }
    
    // MARK: - DELEGATE
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
        
        showButtons()
        
        quantityStepper.value = 1
        updateDisplayWith(totalPrice: 0.0, itemQuantity: 1)
        
        currentSelection = shop.selection[indexPath.row]
        
        if let currentSelection = currentSelection, let item = shop.item(forSelection: currentSelection) {
            
            let totalPrice = item.price * quantityStepper.value
            
            updateDisplayWith(totalPrice: totalPrice, itemPrice: item.price)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func updateCell(having indexPath: IndexPath, selected: Bool) {
        
        let selectedBackgroundColor = UIColor(red: 41/255.0, green: 211/255.0, blue: 241/255.0, alpha: 1.0)
        let defaultBackgroundColor = UIColor(red: 27/255.0, green: 32/255.0, blue: 36/255.0, alpha: 1.0)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = selected ? selectedBackgroundColor : defaultBackgroundColor
        }
    }
    
    // Mark: -LAYOUT
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (UIScreen.main.bounds.width - 2*10 - 10)/2, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    

    func showButtons() {
        self.addToCartAnimation.isHidden = false
        self.quantityView.isHidden = false
    }
    
    func hideButtons() {
        self.addToCartAnimation.isHidden = true
        self.quantityView.isHidden = true
    }
}

