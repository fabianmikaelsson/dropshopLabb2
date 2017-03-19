//
//  MarketPlace.swift
//  Drop Shop
//
//  Created by Fabian Mikaelsson on 2017-02-21.
//  Copyright © 2017 Fabian Mikaelsson. All rights reserved.
//

import Foundation
import UIKit

enum ProductSelection: String {
    case tshirt007
    case tshirtOverslept
    case tshirtAmerican
    case tshirtKing
    case tshirtLife
    case tshirtScreenshot
    case tshirtSilence
    case tshirtTheDayAfter
    
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return #imageLiteral(resourceName: "default")
        }
    }
}

protocol ShopItem {
    var price: Double { get }
    var quantity: Int { get set }
}

protocol Shop {
    var selection: [ProductSelection] { get }
    var inventory: [ProductSelection: ShopItem] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [ProductSelection: ShopItem])
    func choice(selection: ProductSelection, quantity: Int) throws
    func deposit(_ amount: Double)
    func item(forSelection selection: ProductSelection) -> ShopItem?
}

struct Item: ShopItem {
    let price: Double
    var quantity: Int
}

enum InventoryErrod: Error {
    case invalidResource
    case conversionFailure
    case invalidSelection
}

class PlistCoverter {
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw InventoryErrod.invalidResource
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            throw InventoryErrod.conversionFailure
        }
        
        return dictionary
    }
}

class InventoryUnarchiver {
    //vending inventory
    static func products(fromDictionary dictionary: [String: AnyObject]) throws -> [ProductSelection: ShopItem] {
        var inventory: [ProductSelection: ShopItem] = [:]
        
        for (key, value) in dictionary {
            if let itemDictionary = value as? [String: Any],
                let price = itemDictionary["price"] as? Double,
                let quantity = itemDictionary["quantity"] as? Int {
                
                let item = Item(price: price, quantity: quantity)
                
                guard let selection = ProductSelection(rawValue: key) else {
                    throw InventoryErrod.invalidSelection
                }
                
                inventory.updateValue(item, forKey: selection)
            }
        }
        
        return inventory
    }
}

enum SelectProductError: Error {
    case invalidSelection
    case outOfStock
}

class TShirtProducts: Shop {
    let selection: [ProductSelection] =
        [.tshirt007, .tshirtOverslept, .tshirtAmerican, .tshirtKing, .tshirtLife, .tshirtScreenshot, .tshirtSilence, .tshirtTheDayAfter]
    
    var inventory: [ProductSelection : ShopItem]
    var amountDeposited: Double = 10.0
    
    required init(inventory: [ProductSelection : ShopItem])  {
        self.inventory = inventory
    }
    
    func choice(selection: ProductSelection, quantity: Int) throws {
        guard var item = inventory[selection] else {
            throw SelectProductError.invalidSelection
        }
        
        guard item.quantity >= quantity else {
            throw SelectProductError.outOfStock
        }
        
        let totalPrice = item.price * Double(quantity)
        
        //Ta bort if statement??
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
            
            item.quantity -= quantity
            
            inventory.updateValue(item, forKey: selection)
        }
    }
    
    func deposit(_ amount: Double) {
    }
    
    func item(forSelection selection: ProductSelection) -> ShopItem? {
        return inventory[selection]
    }
    
}
