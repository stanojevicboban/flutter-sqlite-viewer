import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DataList extends StatefulWidget {
  final String databasePath;
  final String tableName;
  final String databasePass;

  DataList({@required this.databasePath, @required this.tableName, this.databasePass});

  @override
  _DataListState createState() =>
      _DataListState(databasePath: databasePath, tableName: tableName, databasePass: databasePass);
}

class _DataListState extends State<DataList> {
  final String databasePath;
  final String tableName;
  final String databasePass;

  Future<List> _values;

  _DataListState({@required this.databasePath, @required this.tableName, this.databasePass});

  @override
  void initState() {
    super.initState();

    _values = _getValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(tableName)),
        body: Container(
            padding: EdgeInsets.all(20.0), child: _getWidget(context)));
  }

  Future<List> _getValues() async {
    final db = await openDatabase(databasePath, password: databasePass);
    final values = await db.rawQuery('SELECT * FROM $tableName');
    if (values.length > 0) {
      return values;
    }
    return null;
  }

  FutureBuilder<List> _getWidget(BuildContext context) {
    return FutureBuilder<List>(
        future: _values,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return JsonTable(snapshot.data, showColumnToggle: false,
                tableHeaderBuilder: (String header) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.5), color: Colors.grey[300]),
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.display1.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                      color: Colors.black87),
                ),
              );
            }, tableCellBuilder: (value) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 0.5, color: Colors.grey.withOpacity(0.5))),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .display1
                      .copyWith(fontSize: 14.0, color: Colors.grey[900]),
                ),
              );
            },
                allowRowHighlight: true,
                rowHighlightColor: Colors.yellow[500].withOpacity(0.7),
                paginationRowCount: snapshot.data.length);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return Text("");
        });
  }
}
