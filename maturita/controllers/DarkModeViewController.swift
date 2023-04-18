//
//  DarkModeViewController.swift
//  maturita
//
//  Created by grabherr on 30.03.2021.
//

import UIKit

class DarkModeViewController: UIViewController {

    let userDefaults = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //when open app
        DispatchQueue.main.async {
            //if phone theme is dark/light
            if self.traitCollection.userInterfaceStyle == .dark {
                self.userDefaults.setValue(true, forKey: "darkMode")
                self.enableDarkMode()
            } else {
                self.userDefaults.setValue(false, forKey: "darkMode")
                self.disableDarkMode()
            }
            //users settings
            if self.userDefaults.bool(forKey: "darkMode") == true {
                self.enableDarkMode()
            } else {
                self.disableDarkMode()
            }
        }
        //action when switch changes
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkMode), name: Notification.Name("darkModeOn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableDarkMode), name: Notification.Name("darkModeOff"), object: nil)
    }
    @objc func enableDarkMode() {
        navigationController?.overrideUserInterfaceStyle = .dark
        overrideUserInterfaceStyle = .dark
    }
    @objc func disableDarkMode() {
        navigationController?.overrideUserInterfaceStyle = .light
        overrideUserInterfaceStyle = .light
    }
}
