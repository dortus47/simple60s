//
//  historyTVC.swift
//  sipleTimer60
//
//  Created by 장은석 on 2021/07/19.
//

import UIKit

class historyTVC: UITableViewController {

    var historyList: [(counting: Int, date: String)]! // 데이터 소스용 멤버 변수
    let hisDAO = historyDAO() // SQLite 처리를 담당할 DAO 객체

    override func viewDidLoad() {
        self.historyList = self.hisDAO.find() // 기존 저장된 부서 정보를 가져온다.
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.historyList = self.hisDAO.find() // 기존 저장된 부서 정보를 가져온다.
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.historyList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // indexPath 매개변수가 가리키는 행에 대한 데이터를 읽어온다.
        let rowData = self.historyList[indexPath.row]

        // 셀 객체를 생성하고 데이터를 배치한다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "HISTORY_CELL")
        cell?.textLabel?.text = rowData.date
        return cell!
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // 목록 편집 형식을 결정하는 함수(삭제 / 수정)
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 1. 삭제할 행의 departCd를 구한다.
        let counting = self.historyList[indexPath.row].counting

        // 2. DB에서, 데이터 소스에서, 그리고 테이블 뷰에서 차례대로 삭제한다.
        if hisDAO.remove(counting: counting) {
            self.historyList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
