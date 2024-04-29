//
//  ViewController.swift
//  ToDoList
//
//  Created by Yanina Kovrakh on 25.04.2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            print("bundle version: \(text)")
        }
    }

}
