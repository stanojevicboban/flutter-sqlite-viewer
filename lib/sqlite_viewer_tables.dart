import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import './sqlite_viewer_values.dart';

class TableList extends StatefulWidget {
  final String databasePath;
  final String databasePass;

  TableList({@required this.databasePath, this.databasePass});

  @override
  _TableListState createState() => _TableListState(databasePath: databasePath,
          databasePass: databasePass);
}

class _TableListState extends State<TableList> {
  final String databasePath;
  final String databasePass;

  Future<List> _tables;

  _TableListState({
    @required this.databasePath,
    this.databasePass
  });

  @override
  void initState() {
    super.initState();

    _tables = _getTables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(basename(databasePath))),
        body: _getWidget(context));
  }

  Future<List> _getTables() async {
    final db = await openDatabase(databasePath, password: databasePass);
    final tables = await db.rawQuery(
        'SELECT name FROM sqlite_master WHERE type = "table" and name != "sqlite_sequence"');
    if (tables.length > 0) {
      return tables;
    }
    return null;
  }

  FutureBuilder<List> _getWidget(BuildContext context) {
    return FutureBuilder<List>(
        future: _tables,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    child: Container(
                        child: ListTile(
                          leading: Icon(Icons.folder),
                          title: Text(snapshot.data[index]["name"]),
                        ),
                        decoration: new BoxDecoration(
                            border: new Border(bottom: new BorderSide()))),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DataList(
                                  databasePath: databasePath,
                                  tableName: snapshot.data[index]["name"],
                                  databasePass: databasePass)));
                    },
                  );
                });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return Text("");
        });
  }
}
