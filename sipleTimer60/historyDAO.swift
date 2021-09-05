//
//  historyDAO.swift
//  sipleTimer60
//
//  Created by 장은석 on 2021/07/18.
//

import Foundation
import FMDB

class historyDAO {
    typealias historyRecord = (Int, String)

    // SQLite 연결 및 초기화
    lazy var fmdb: FMDatabase! = {
        // 1. 파일 매니저 객체를 생성
        let fileMgr = FileManager.default

        // 2. 샌드박스 내 문서 디렉터리에서 데이터베이스 파일 경로를 확인
        let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        let dbPath = docPath!.appendingPathComponent("history.sqlite").path

        // 3. 샌드박스 경로에 파일이 없다면 메인 번들에 만들어 둔 history.sqlite를 가져와 복사
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: "history", ofType: "sqlite")
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }

        // 4. 준비된 데이터베이스 파일을 바탕으로 FMDatabase 객체를 생성
        let db = FMDatabase(path: dbPath)
        return db
    }()

    init() {
        self.fmdb.open()
    }

    deinit {
        self.fmdb.close()
    }

    func find() -> [historyRecord] {
        // 반환할 데이터를 담을 [historyRecord] 타입의 객체 정의
        var historyList = [historyRecord]()

        do {
            // 1. 로그 정보 목록을 가져올 SQL 작성 및 쿼리 실행
            let sql = """
                SELECT counting, date
                FROM log
                ORDER BY counting DESC
            """

            let rs = try self.fmdb.executeQuery(sql, values: nil)

            // 2. 결과 집합 추출
            while rs.next() {
                let counting = rs.int(forColumn: "counting")
                let date = rs.string(forColumn: "date")

                // append 메소드 호출 시 아래 튜플을 괄호 없이 사용하지 않도록 주의
                historyList.append(( Int(counting), date! ))
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        return historyList
    }

    func get(counting: Int) -> historyRecord? {
        // 1. 질의 실행
        let sql = """
            SELECT counting, date
            FROM log
            WHERE  couting = ?
        """

        let rs = self.fmdb.executeQuery(sql, withArgumentsIn: [counting])

        // 결과 집합 처리
        if let _rs = rs { // 결과 집합이 옵셔널 타입으로 반환되므로, 이를 일반 상수에 바인딩하여 해제한다.
            _rs.next()

            let _counting = _rs.int(forColumn: "counting")
            let _date = _rs.string(forColumn: "date")

            return (Int(_counting), _date!)
        } else { // 결과 집합이 없을 경우 nil을 반환한다.
            return nil
        }
    }

    func create(date: String!) -> Bool {
        do {
            let sql = """
                INSERT INTO log (date)
                VALUES ( ? )
            """
            try self.fmdb.executeUpdate(sql, values: [date!])
            return true
        } catch let error as NSError {
            print("Insert Error: \(error.localizedDescription)")
            return false
        }
    }

    func remove(counting: Int) -> Bool {
        do {
            let sql = "DELETE FROM log WHERE counting= ?"
            try self.fmdb.executeUpdate(sql, values: [counting])
            return true
        } catch let error as NSError {
            print("DELETE Error : \(error.localizedDescription)")
            return false
        }
    }

}
