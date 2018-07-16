//
//  TestViewController.swift
//  QRReader
//
//  Created by mac on 28/10/1439 AH.
//  Copyright © 1439 MAGNUMIUM. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, QRScannerDelegate {
    // MARK: ~ Delegate Methods
    func setPreviewView() -> UIView {
        return self.view
    }
    
    func drawBoundingSquares(codeStringValue: String) -> (label: String?, labelPosition: SquareLabelPositions, labelColor: UIColor?, color: CGColor?) {
        return ("Valid", .Bottom,  UIColor.white, UIColor.cyan.cgColor)
    }
    
    func getCodeStringValue(_ codeStringValue: String) {
        print(codeStringValue)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let vc = QRScannerViewController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)

    
    }
    
    

}
