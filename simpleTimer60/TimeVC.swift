//
//  timeVC.swift
//  sipleTimer60
//
//  Created by 장은석 on 2021/08/04.
//

import UIKit

class TimeVC: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func clickDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
