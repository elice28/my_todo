import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

//① Main: Flutterアプリもmain()からコードが実行される
// void main() => runApp(MyApp()); でも意味は同じ
void main() {
  return runApp(MyApp());
}

//② アプリの基盤：アプリのテーマやスタイル設定。その上のページを設定していく。
class MyApp extends StatelessWidget {
  //const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MaterialAppという形式のアプリを作成
    return MaterialApp(
      //title: 'Flutter Demo',
      theme: ThemeData(), //アプリのテーマカラーなどの詳細を入力
      home: MyHomePage(), //メインページを作成
    );
  }
}

/*
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu Bar"),
      ),
      body: Center(
        child: ListView(
          children: [
            /*
            // 1枚
            Card(
              margin: EdgeInsets.all(10), //
              child: Container(
                padding: EdgeInsets.all(10), //
                child: Row(
                  children: [
                    Checkbox(onChanged: null, value: false),
                    Text("TODO 1"),
                  ],
                ),
              ),
            ),
            */
            TodoCardWidget(label: "TODO 1"),
            TodoCardWidget(label: "TODO 2"),
            TodoCardWidget(label: "TODO 3"),
            TodoCardWidget(label: "TODO 4"),
          ]
        ),
      ),
    );
  }
}
*/

//⑦ MyHomePage本体
class MyHomePage extends StatefulWidget {
  //List<Widget> cards = [];

  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//⑧ MyHomePageの状態
class _MyHomePageState extends State<MyHomePage> {
  //任意の値の取得
  //String? label = ""; //

  @override
  void initState() {
    super.initState();

    /*
    // SharedPreferencesのインスタンスを取得し、
    // SharedPreferencesに保存されているリストを取得
    SharedPreferences.getInstance().then((prefs) {
      var todo = prefs.getStringList("todo") ?? [];
      for (var v in todo) {
        setState(() {
          widget.cards.add(TodoCardWidget(label: v));
        });
      }
    });
    */
  }

  // 非同期にカードリストを生成する関数
  Future<List<dynamic>> getCards() async {
    var prefs = await SharedPreferences.getInstance();
    List<Widget> cards = [];
    var todo = prefs.getStringList("todo") ?? [];
    for (var jsonStr in todo) {
      // JSON形式の文字列から辞書形式のオブジェクトに変換し、各要素を取り出す
      var mapObj = jsonDecode(jsonStr);
      var title = mapObj['title'];
      var state = mapObj['state'];
      cards.add(TodoCardWidget(label: title, state: state));
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My TODO"),
        actions: [
          //ナビゲーションバーの右上にゴミ箱ボタンを設置
          IconButton(
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) async {
                await prefs.setStringList("todo", []);
                setState(() {
                  //widget.cards = [];
                });
              });
            },
            icon: const Icon(Icons.delete)
          )
        ],
      ),
      body: Center(
        // 非同期にカードリストを更新するには、FutureBuilderを用いる
        child: FutureBuilder<List>(
          future: getCards(), //getCards()メソッドの実行状態をモニタリングする
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text('Waiting to start');
              case ConnectionState.waiting:
                return const Text('Loading...');
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ListView.builder(
                    // リストの中身は、snapshot.dataの中に保存されているので、取り出して活用する
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return snapshot.data![index];
                    }
                  );
                }
            }
          },
        ),

        /*
        // ListViewのchildrenをwidget.cardsに変更
        child: ListView.builder(
            itemCount: widget.cards.length,
            itemBuilder: (BuildContext context, int index) {
              return widget.cards[index];
            },
        ), */
        //child: Text(label ?? ""),
      ),

      //画面右下にボタンを追加
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var label = await _showTextInputDialog(context);

          if (label != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var todo = prefs.getStringList("todo") ?? [];

            //辞書型オブジェクトを生成し、JSON形式の文字列に変換して保存
            var mapObj = {"title": label, "state": false};
            var jsonStr = jsonEncode(mapObj);
            todo.add(jsonStr);
            await prefs.setStringList("todo", todo);

            setState(() {});
            /*
            setState(() {
              widget.cards.add(TodoCardWidget(label: label));
            });

            // SharedPreferencesのインスタンスを取得し、追加
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var todo = prefs.getStringList("todo") ?? [];
            todo.add(label);
            await prefs.setStringList("todo", todo);
            */
          }
        },
        /*
        onPressed: () {
          //add your onPressed code here!
          setState(() {
            // ボタンが押された時、TodoCardWidgetをcardsに追加
            widget.cards.add(TodoCardWidget(label: "a"));
          });
        },*/
        child: const Icon(Icons.add),
      ),
    );
  }

  //
  final _textFieldController = TextEditingController();

  Future<String?> _showTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('TODO'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter a task"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context, _textFieldController.text),
            ),
          ],
        );
    }
    );
  }
}


/*
//④ TodoCardのWidget - StatelessWidget
class TodoCardWidget extends StatelessWidget {
  final String label;

  TodoCardWidget({Key? key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10), //
      child: Container(
        padding: EdgeInsets.all(10), //
        child: Row(
          children: [
            Checkbox(onChanged: null, value: false),
            Text(this.label),
          ],
        ),
      ),
    );
  }
}
*/

// ⑤ StatefulWidget本体
class TodoCardWidget extends StatefulWidget {
  final String label;
  //boolen型のstateを外部からアクセスできるように修正
  var state = false;

  TodoCardWidget({
    Key? key,
    required this.label,
    required this.state, //追加　6回目
  }) : super(key: key);

  @override
  _TodoCardWidgetState createState() => _TodoCardWidgetState();
}

// ⑥ TodoCardWidgetの状態
class _TodoCardWidgetState extends State<TodoCardWidget> {
  void _changeState(value) async { //async追加
    setState(() {
      widget.state = value ?? false;
    });

    // ボタンが押されたタイミング状態を更新し保存
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var todo = prefs.getStringList("todo") ?? [];

    for (int i=0; i<todo.length; i++) {
      var mapObj = jsonDecode(todo[i]);
      if (mapObj["title"] == widget.label) {
        mapObj["state"] = widget.state;
        todo[i] = jsonEncode(mapObj);
      }
    }
    prefs.setStringList("todo", todo);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10), //
      child: Container(
        padding: EdgeInsets.all(10), //
        child: Row(
          children: [
            Checkbox(onChanged: _changeState, value: widget.state),
            Text(widget.label),
          ],
        ),
      ),
    );
  }
}


