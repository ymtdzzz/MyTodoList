//
//  ViewController.swift
//  MyTodoList
//
//  ＜自分用メモ＞
//  alertの参考(https://gist.github.com/AppleEducate/61644b890890ffc08852c2d3805e2f87#file-uialertcontroller-swift-L84)

import UIKit
import EventKit
import EventKitUI

// UITableViewDataSource, UITableViewDelegateのプロトコルを実装する宣言
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EKEventEditViewDelegate, UINavigationControllerDelegate {
    private let eventStore: EKEventStore = EKEventStore()
    
//    テーブルの行数を返却するメソッドの実装
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        ToDoの配列の長さを返却する
        return todoList.count
    }
    
//    テーブルの行ごとのセルを返却するメソッドの実装
    func tableView(_ tableView:  UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        stroyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
//        行番号に合ったToDoの情報を習得
        let myTodo = todoList[indexPath.row]
//       セルのラベルにToDoのタイトルをセット
        cell.textLabel?.text = myTodo.todoTitle
//        セルのチェックマーク状態をセット
        if myTodo.todoDone {
//            チェックあり
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
//            チェックなり
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        return cell
    }
    
//    セルが編集可能かどうか返却する
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    セルを削除した時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        削除可能かどうか
        if editingStyle == UITableViewCell.EditingStyle.delete {
//            ToDoリストから削除
            todoList.remove(at: indexPath.row)
        }
//        セルを削除
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
//        データ保存。Data型にシリアライズする
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
//            UserDefaultsに保存
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        } catch {
            
        }
    }
    
//    セルをタップしたときの処理
//    セルのタップ時は、tableView:didSelectRowatメソッドが呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        選択された行のタスク情報を格納
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone {
//            完了済みなら未完了にする
            myTodo.todoDone = false
        } else {
//            未完了なら完了済みにする
            myTodo.todoDone = true
        }
//        セルの状態を変更する
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
//        データを保存する。Data型にシリアライズする
        do {
            let data: Data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
//            UserDefaultsに保存
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        } catch {
//            エラー処理省略
        }
    }
    
//    ToDoを格納する配列
    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        保存しているToDoの読み込み処理
        let userDefaults = UserDefaults.standard
//        userDefaultsからシリアライズされたデータを持ってくる
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data {
//            デシリアライズを行う
            do {
                if let unarchiveTodoList = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MyTodo.self], from: storedTodoList) as? [MyTodo] {
//                    Mytodo型にデコードできたので、それを配列に入れる
                    todoList.append(contentsOf: unarchiveTodoList)
                }
            } catch {
//                エラー処理は実装しない
            }
        }
    }
    
//    ＋ボタンタップ時の動作
//    alertダイアログ生成、テキストエリアの追加、OK/CENCEL時の動作
    @IBAction func tapAddButton(_ sender: Any) {
//        EventKit用変数
        let title: String = "ToDo"
        let location: String = "場所"
        let startDate: Date = Date()
        let endDate: Date = startDate.addingTimeInterval(3600 * 3)
        let memo: String = "詳細内容"
        let timeZone: TimeZone = TimeZone(identifier: "Asia/Tokyo")!
        
        self.showCalendarView(title: title, location: location, startDate: startDate, endDate: endDate, memo: memo, timeZone: timeZone)
    }
    
    // イベントへのアクセス権限で振り分け
    func showCalendarView(title: String, location: String?, startDate: Date, endDate: Date, memo: String?, timeZone: TimeZone) {
        
        //  権限チェック
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch authStatus {
        case .authorized:
            self.openCalendarView(title: title, location: location, startDate: startDate, endDate: endDate, memo: memo, timeZone: timeZone)
        case .restricted: break
        case .notDetermined:
            self.eventStore.requestAccess(to: .event, completion: { (result: Bool, error: Error?) in
                if result {
                    self.openCalendarView(title: title, location: location, startDate: startDate, endDate: endDate, memo: memo, timeZone: timeZone)
                } else {
                    //                使用不可
                }
            })
        case .denied: break
        }
    }
    
    //  イベント作成画面表示
    func openCalendarView(title: String, location: String?, startDate: Date, endDate: Date, memo: String?, timeZone: TimeZone) {
        let event: EKEvent = EKEvent(eventStore: self.eventStore)
        event.title = title
        event.location = location
        event.startDate = startDate
        event.endDate = endDate
        event.notes = memo
        event.timeZone = timeZone
        event.calendar = self.eventStore.defaultCalendarForNewEvents
        
        
        let eventController: EKEventEditViewController = EKEventEditViewController()
        eventController.delegate = self
        eventController.event = event
        eventController.editViewDelegate = self
        eventController.eventStore = self.eventStore
        
        self.present(eventController, animated: true, completion: nil)
    }

//    イベント画面用デリゲート
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        var result = -1
        
//        ここでもうToDoに入れちゃう？
        let myTodo = MyTodo()
        myTodo.todoTitle = controller.event?.title
        self.todoList.insert(myTodo, at: 0)
//        メインスレッドで、行が追加されたことをテーブルに通知する
//        ->テーブルの再描画が実行される
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.right)
        }
//                ToDoの保存処理
        let userDefaults = UserDefaults.standard
//                Data型にシリアライズ
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: todoList, requiringSecureCoding: true)
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        } catch {
//                    今回エラー処理はスキップ
        }
        
        switch action {
        case .canceled: break
        case .saved:
            do {
                try controller.eventStore.save(controller.event!, span: .thisEvent)
                
//                正常終了
                result = 1
            } catch {
//                失敗
                result = 9
            }
        case .deleted: break
        }
        
        controller.dismiss(animated: true) {
            var message = ""
            if result != -1 {
                if result == 1{
                    message = "イベント追加　完了"
                } else if result == 9 {
                    message = "イベント追加　失敗"
                }
                
//                結果の表示
                let alert = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// 独自クラスをシリアライズする際には、NSObjectを継承し、
// NSSecureCodingプロトコルに準拠する必要がある
class MyTodo : NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }
    
//    ToDoのタイトル
    var todoTitle: String?
//    完了フラグ
    var todoDone: Bool = false
//     コンストラクタ
    override init() {
    }
    
//    NSCodingプロトコルのデシリアライズ処理。
    required init?(coder aDecoder: NSCoder) {
        todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
    }
//    NSCodingプロトコルのシリアライズ処理
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "tododone")
    }
}
