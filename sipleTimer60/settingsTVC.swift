//
//  settingsTVC.swift
//  sipleTimer60
//
//  Created by 장은석 on 2021/07/16.
//

import UIKit

class settingsTVC: UITableViewController {

    @IBOutlet weak var switchAutoHistory: UISwitch!
    @IBOutlet weak var switchVibration: UISwitch!
    @IBOutlet weak var switchAlarmSound: UISwitch!
    @IBOutlet weak var switchPushNotice: UISwitch!

    @IBOutlet weak var txtField: UITextField!

    let userNotiCenter = UNUserNotificationCenter.current() // 로컬 푸시

    override func viewDidLoad() {
        super.viewDidLoad()

        let datePicker = UIDatePicker()
            datePicker.datePickerMode = .time
            datePicker.locale = .current
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
                datePicker.sizeToFit()
                }
        self.txtField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)

        // 툴 바 객체 정의
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolbar.barTintColor = .lightGray

        // 액세사리 뷰 영역에 툴 바를 표시
        self.txtField.inputAccessoryView = toolbar

        // 툴 바에 들어갈 닫기 버튼
        let done = UIBarButtonItem()
        done.title = "Done"
        done.target = self
        done.action = #selector(pickerDone)

        // 가변 폭 버튼 정의
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // 버튼을 툴 바에 추가
        toolbar.setItems([flexSpace, done], animated: true)
    }

    @objc func handleDatePicker(_ datePicker: UIDatePicker) {
        txtField.text = datePicker.date.formatted
    }

    // 시간 선택 완료
    @objc func pickerDone(_ sender: Any) {
        let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
        plist.set(txtField.text, forKey: "noticetime")
        plist.synchronize() // 동기화 처리
        requestAuthNoti()
        if plist.bool(forKey: "pushnotice") {
            requestSendNotiCalendar()
        }
        self.view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setSwitchState()
        let plist = UserDefaults.standard
        requestAuthNoti()
        if plist.bool(forKey: "pushnotice") {
            requestSendNotiCalendar()
        }
    }

    func setSwitchState() {
        let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
        switchAutoHistory.isOn = plist.bool(forKey: "autohistory")
        switchVibration.isOn = plist.bool(forKey: "vibration")
        switchAlarmSound.isOn = plist.bool(forKey: "alarmsound")
        switchPushNotice.isOn = plist.bool(forKey: "pushnotice")
        txtField.text = plist.string(forKey: "noticetime")
        print("settings", plist.bool(forKey: "autohistory"), plist.bool(forKey: "vibration"), plist.bool(forKey: "alarmsound"), plist.bool(forKey: "pushnotice"), plist.string(forKey: "noticetime")!)
        plist.synchronize()
    }

    @IBAction func changeAutoHistory(_ sender: Any) {
        let value = (sender as AnyObject).isOn // true면 저장, false면 저장안함
        let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
        plist.set(value, forKey: "autohistory")
        plist.synchronize() // 동기화 처리
        print("touch1", plist.bool(forKey: "autohistory"), plist.bool(forKey: "vibration"), plist.bool(forKey: "alarmsound"))
    }

    @IBAction func changeVibration(_ sender: Any) {
        let value = (sender as AnyObject).isOn // true면 저장, false면 저장안함
        let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
        plist.set(value, forKey: "vibration")
        plist.synchronize() // 동기화 처리
        print("touch2", plist.bool(forKey: "autohistory"), plist.bool(forKey: "vibration"), plist.bool(forKey: "alarmsound"))
    }

    @IBAction func changeAlarmSound(_ sender: Any) {
        let value = (sender as AnyObject).isOn // true면 저장, false면 저장안함
        let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
        plist.set(value, forKey: "alarmsound")
        plist.synchronize() // 동기화 처리
        print("touch3", plist.bool(forKey: "autohistory"), plist.bool(forKey: "vibration"), plist.bool(forKey: "alarmsound"))
    }

    @IBAction func changePushNotice(_ sender: Any) {
        let value = (sender as AnyObject).isOn // true면 저장, false면 저장안함
        let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
        plist.set(value, forKey: "pushnotice")
        plist.synchronize() // 동기화 처리
        print("touch3", plist.bool(forKey: "autohistory"), plist.bool(forKey: "vibration"), plist.bool(forKey: "alarmsound"))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // 사용자에게 알림 권한 요청
    func requestAuthNoti() {
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        userNotiCenter.requestAuthorization(options: notiAuthOptions) { (_, error) in
            if let error = error {
                print(#function, error)
            }
        }
    }

    // 알림 전송
    /*
     기본적으로 오늘 날짜가 걸리고 시간은 오전 1 시로 설정됩니다. 사용 : UNCalendarNotificationTrigger(dateMatching:  오늘 오전 1시에 트리거하도록 알림에 지시 한 후 매일 같은 시간에 반복합니다.
    */
    func requestSendNotiCalendar() {
        let plist = UserDefaults.standard
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "Hello there~"
        notiContent.body = "Why don't we pause what we're doing and take a breath back?"
        notiContent.userInfo = ["targetScene": "splash"] // 푸시 받을때 오는 데이터

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        let str = plist.string(forKey: "noticetime")
        let arr = str!.components(separatedBy: ":")
        dateComponents.hour = Int(arr[0])
        dateComponents.minute = Int(arr[1])
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notiContent,
            trigger: trigger
        )

        userNotiCenter.add(request) { (error) in
            print(#function, error)
        }
    }
}

extension Date {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    var formatted: String {
        return Date.formatter.string(from: self)
    }
}
