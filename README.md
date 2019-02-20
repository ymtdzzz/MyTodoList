# MyTodoList
## 参考：本気ではじめるiPhoneアプリ作り

基本的には書籍を参考にして作成しましたが、追加でiOS標準スケジュールアプリに自動的に予定が追加できるようにしました。EventKitを用いて実装しています。
以下の記事を参考にしました。

[iOSのデフォルトカレンダーにイベントを追加する方法](https://creator.blitzgate.co.jp/515/)
[[iOS 10] 各種ユーザーデータへアクセスする目的を記述することが必須になるようです](https://dev.classmethod.jp/smartphone/iphone/ios10-privacy-data-purpose-description/)
[EKEventEditViewController Add and Cancel buttons not responding
](https://stackoverflow.com/questions/47182610/ekeventeditviewcontroller-add-and-cancel-buttons-not-responding)

★学べたこと★
- Swiftの基本文法（の一部）
- Storyboardを用いたレイアウトと、プログラムへの結びつけ
- UserDefaultsを用いたデータの永続化と、シリアライズ／デシリアライズ処理の実装
- ユーザーデータへアクセスする際の注意（Cocoa Keysへの目的明記）
- EventKitの使い方
