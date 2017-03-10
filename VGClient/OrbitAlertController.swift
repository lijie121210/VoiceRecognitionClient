//
//  OrbitAlertController.swift
//  VGClient
//
//  Created by jie on 2017/3/9.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class OrbitAlertController: UIViewController {

    @IBOutlet weak var orbitContainer: RectCornerView!
    @IBOutlet weak var orbit: OrbitView!
    @IBOutlet weak var orbitPrompt: UILabel!
    
    var initPrompt: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orbitPrompt.text = initPrompt
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        disablesAutomaticKeyboardDismissal = true
        
        orbit.launchOrbit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let index = OrbitAlertController.instances.index(of: self) else {
            return
        }
        OrbitAlertController.instances.remove(at: index)
    }
    
    static var instances: [OrbitAlertController] = []
    
    @discardableResult
    class func show(with prompt: String, on controller: UIViewController) -> OrbitAlertController? {
        guard let c = UIStoryboard(name: "Orbit", bundle: nil).instantiateInitialViewController() as? OrbitAlertController else {
            return nil
        }
        
        c.initPrompt = prompt
        
        instances.append(c)
        
        controller.present(c, animated: true, completion: nil)
        
        return c
    }
    
    class func dismiss() {
        instances.forEach {
            $0.dismiss(animated: true, completion: nil)
        }
    }
    
    func update(prompt: String) {
        guard let orbitPrompt = self.orbitPrompt else {
            return
        }
        orbitPrompt.text = prompt
    }
}
