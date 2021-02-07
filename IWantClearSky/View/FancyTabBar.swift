//
//  FancyTabBar.swift
//  IWantClearSky
//
//  Created by Anton Novoselov on 07.02.2021.
//

import UIKit

class FancyTabBar: UITabBar {
    
    private var middleButton = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupMiddleButton()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let from = point
        let to = middleButton.center
        
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    }
    
    func setupMiddleButton() {
        middleButton.setImage(UIImage(named: "plus"), for: .normal)
        middleButton.tintColor = .white
        middleButton.frame.size = CGSize(width: 70, height: 70)
        middleButton.backgroundColor = #colorLiteral(red: 0.9302070737, green: 0.7469735742, blue: 0, alpha: 1)
        middleButton.layer.cornerRadius = 35
        middleButton.layer.masksToBounds = false
        
        middleButton.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).cgColor
        middleButton.layer.shadowRadius = 4
        middleButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        middleButton.layer.shadowOpacity = 0.8
        
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        middleButton.addTarget(self, action: #selector(showCitySearchAlert), for: .touchUpInside)
        addSubview(middleButton)
    }
    
    @objc func showCitySearchAlert() {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if let tabBarController = keyWindow?.rootViewController as? UITabBarController,
           let mainVc = tabBarController.viewControllers?.first as? MainViewController {
            mainVc.presentSearchAndGetCurrentWeather()
        }
    }
}
