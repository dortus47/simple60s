//
//  ViewController.swift
//  sipleTimer60
//
//  Created by 장은석 on 2021/07/13.
//

import UIKit
import SwiftProgressView
import AudioToolbox

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var circle: ProgressRingView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var mainIcon: UIButton!
    @IBOutlet weak var txtField: UITextField!

    let pickerList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    let hisDAO = historyDAO() // SQLite 처리를 담당할 DAO 객체

    // timer
    var mTimer: Timer?
    var number: CGFloat = 0.0 // 퍼센테이지 숫자
    var tick: Int = 0 // 60초
    var mode: Bool = false // false: start, true: close

    let userNotiCenter = UNUserNotificationCenter.current() // 로컬 푸시
    var plusNum: CGFloat = 0.0 // 1초에 몇 퍼센트씩 올라야 하는지
    var totalSec: Int = 0 // 몇초를 세려야 하는지

    override func viewDidLoad() {
        let picker = UIPickerView()

        // 1. 피커 뷰의 델리게이트 객체 지정
        picker.delegate = self
        // 2. 텍스트 필드 입력 방식을 가상 키보드 대신 피커 뷰로 설정
        self.txtField.inputView = picker

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

        super.viewDidLoad()

        // requestSendNoti(seconds: 3)

    }

    override func viewWillAppear(_ animated: Bool) {
        let plist = UserDefaults.standard
        self.txtField.text = String(plist.integer(forKey: "minute")) + " min"
        requestAuthNoti()
        if plist.bool(forKey: "pushnotice") {
            requestSendNotiCalendar()
        }
        circle.setProgress(0, animated: true)
    }

    /* 이미지 변경, 모드 변경  */
    func changeBtn() {
        // 타이머가 재생 버튼 일 때
        if mode {
            btnStart.setImage(UIImage(named: "play.png"), for: .normal)
        } else {
            btnStart.setImage(UIImage(named: "close.png"), for: .normal)
        }
        mode = !mode
    }

    /* 타이머 클릭 */
    @IBAction func onTimerStart (_ sender: Any) {
        // 시작버튼
        setMin()
        changeBtn()
        if mode {
            let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
            if plist.bool(forKey: "vibration") {
                AudioServicesPlaySystemSound(4095)
            }
            if plist.bool(forKey: "alarmsound") {
                AudioServicesPlaySystemSound(1254)
            }
            if let timer = mTimer {
                // timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
                if !timer.isValid {
                    /** 1초마다 timerCallback함수를 호출하는 타이머 */
                    mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                }
            } else {
                // timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
                /** 1초마다 timerCallback함수를 호출하는 타이머 */
                mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        } else {
            setStop()
        }
    }

    func setStop() {
        if let timer = mTimer {
            if timer.isValid {
                timer.invalidate()
            }
        }
        lblNumber.textColor = .gray
        lblNumber.text = "00:00"
        tick = 0
        number = 0
        circle.setProgress(0, animated: true)
    }

    /* 현재시간 저장 메소드 */
    func saveHistory() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let current_date_string = formatter.string(from: Date())
        print(current_date_string)
        hisDAO.create(date: current_date_string)
    }

    /* 타이머가 호출하는 콜백메소드 */
    @objc func timerCallback() {
        if number >= 1 {
            if let timer = mTimer {
                if timer.isValid {
                    timer.invalidate()
                }
            }
            let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
            if plist.bool(forKey: "vibration") {
                AudioServicesPlaySystemSound(4095)
            }
            if plist.bool(forKey: "alarmsound") {
                AudioServicesPlaySystemSound(1254)
            }
            // 알림창 출력
            let alert = UIAlertController(title: nil, message: "Your \(totalSec/60) minute has passed :D", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                if plist.bool(forKey: "autohistory") {
                    self.saveHistory()
                }
                self.setStop()
                self.changeBtn()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }

        lblNumber.textColor = UIColor(red: 253/256, green: 156/256, blue: 156/256, alpha: 1.0)
        tick += 1
        lblNumber.text = calSceToMin(tick)
        // number += plusNum
        if totalSec == tick {
            number = 1
        } else {
            number += plusNum
        }
        print(tick, number)
        circle.setProgress(number, animated: true)
    }

    // 현재 저장된 분을 기준으로 1초에 몇 퍼센트가 상승해야 하는지를 계산, 저장
    func setMin() {
        let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
        let min = plist.integer(forKey: "minute")
        let mSec = 60 * min
        totalSec = mSec
        let tick1percentage: CGFloat = 1.0 / CGFloat(mSec)
        let roundedNum = round(tick1percentage * 1000000) / 1000000
        self.plusNum = roundedNum
        print("setMin ", roundedNum)
    }

    // 화면에 출력해줄 시간 계산
    func calSceToMin (_ second: Int) -> String {
        let min = second / 60
        let sec = second % 60
        return sec < 10 ? (min == 10 ? "\(min):0\(sec)" : "0\(min):0\(sec)") : "0\(min):\(sec)"
    }

    override func touchesEnded (_ touches: Set<UITouch>, with event: UIEvent?) {
        let tabBar = self.tabBarController?.tabBar

        UIView.animate(withDuration: TimeInterval(0.3)) {
            // alpha 값이 0이면 1로, 1이면 0으로 바꿔 준다.
            // 호출될 때마다 점점 투명해졌다가 점점 진해질 것이다.
            tabBar?.alpha = (tabBar?.alpha == 0 ? 1: 0)
        }
    }

    // MARK: - Push func

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
        var str = plist.string(forKey: "noticetime")
        var arr = str!.components(separatedBy: ":")
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

    func requestSendNoti(seconds: Double) {
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "알림 title"
        notiContent.body = "알림 body"
        notiContent.userInfo = ["targetScene": "splash"] // 푸시 받을때 오는 데이터

        // 알림이 trigger되는 시간 설정
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notiContent,
            trigger: trigger
        )

        userNotiCenter.add(request) { (error) in
            print(#function, error)
        }
    }

    // 생성할 컴포넌트의 개수를 정의합니다.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // 지정된 컴포넌트가 가질 목록의 길이를 정의합니다.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerList.count
    }

    // 지정될 컴포넌트의 목록 각 행에 출력될 내용을 정의합니다.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(self.pickerList[row]) + " min"
    }

    // 지정된 컴포넌트의 목록 각 행을 사용자가 선택했을 때 실행할 액션을 정의합니다.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 1. 선택된 시간을 텍스트 필드에 입력
        let time = String(self.pickerList[row]) + " min" // 선택된 시간
        let plist = UserDefaults.standard // 기본 저장소 객체를 가져온다.
        plist.set(self.pickerList[row], forKey: "minute")
        plist.synchronize() // 동기화 처리
        self.txtField.text = time
    }

    @objc func pickerDone(_ sender: Any) {
        self.view.endEditing(true)
    }
}
