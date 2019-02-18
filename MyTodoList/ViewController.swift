//
//  ViewController.swift
//  MyTodoList
//
//  ＜自分用メモ＞
//  alertの参考(https://gist.github.com/AppleEducate/61644b890890ffc08852c2d3805e2f87#file-uialertcontroller-swift-L84)

import UIKit

// UITableViewDataSource, UITableViewDelegateのプロトコルを実装する宣言
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
//        アラートダイアログの生成
        let alertController = UIAlertController(title: "ToDo追加", message: "ToDoを入力してください", preferredStyle: UIAlertController.Style.alert)
        
//        テキストエリアの追加
        alertController.addTextField(configurationHandler: nil)
//        OKボタン追加
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action: UIAlertAction) in
//            OKボタンタップ時の処理
            if let textField = alertController.textFields?.first {
//                textFieldsから最初の文字列を取得（今回は一つしかないが・・・）
//                ToDoの配列に入力値を挿入。先頭に挿入する
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at: 0)
//                行が追加されたことをテーブルに通知する
//                ->テーブルの再描画が実行される
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.right)
                
//                ToDoの保存処理
                let userDefaults = UserDefaults.standard
//                Data型にシリアライズ
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: self.todoList, requiringSecureCoding: true)
                    userDefaults.set(data, forKey: "todoList")
                    userDefaults.synchronize()
                } catch {
//                    今回エラー処理はスキップ
                }
            }
        }
//        OKボタンがタップされたときの動作
        alertController.addAction(okAction)
//        CANCELボタンがタップされたときの動作
        let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertAction.Style.cancel, handler: nil)
//        CANCELボタンを追加
        alertController.addAction(cancelButton)
//        アラートダイアログの表示
        present(alertController, animated: true, completion: nil)
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
