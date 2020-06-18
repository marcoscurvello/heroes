//
//  UIViewController.swift
//  Heroes
//
//  Created by Marcos Curvello on 16/06/20.
//  Copyright © 2020 Marcos Curvello. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlertWithError(message: UserFriendlyError, callback: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: message.title, message: message.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in callback(true) }))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in callback(false) }))
            self.present(alert, animated: true)
        }
    }
    
    func presentAlertWithStateChange(message: StateChangeMessage, callback: @escaping (Bool) -> ()) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: message.title, message: message.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in callback(true) })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in callback(false) }))
            DispatchQueue.main.async { self.present(alert, animated: true) }
        }
    }
    
}
