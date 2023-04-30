import 'package:Mini_Bill/Invoices/InvoicesList.dart';
import 'package:Mini_Bill/Utils/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds before navigating to the next screen
    // getData();
    sync();
  }

  bool isLoading = false;
  Database? database;
  sync() async {
    final databasesPath = await getDatabasesPath();
    final path = getPath(databasesPath);
    String sql = await rootBundle.loadString("assets/db/products.sql");
    List<String> queries = sql.split(";");

    database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        Batch batch = db.batch();
        for (String query in queries) {
          if (query.trim().isNotEmpty) {
            batch.execute(query);
          }
        }
        await batch.commit();
      },
    );
    await clearTable('Product', database);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => InvoiceList(),
        ),
        (route) => false);
    return true;
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    bool val = await sync();
    if (val == true) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => InvoiceList(),
          ),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Mini Order Book',
                style: TextStyle(fontSize: 32.0),
              ),
            ),
          ),
          Text("Syncing data"),
          SizedBox(
            height: 12,
          ),
          CircularProgressIndicator(),
          SizedBox(
            height: 12,
          ),
          ElevatedButton(
              onPressed: () async {
                database!.close();
                final databasesPath = await getDatabasesPath();
                final path = getPath(databasesPath);
                String sql = await rootBundle.loadString("assets/db/products.sql");
                List<String> queries = sql.split(";");

                database = await openDatabase(
                  path,
                  version: 1,
                  onCreate: (Database db, int version) async {
                    Batch batch = db.batch();
                    for (String query in queries) {
                      if (query.trim().isNotEmpty) {
                        batch.execute(query);
                      }
                    }
                    await batch.commit();
                  },
                );
                database!.close();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoiceList(),
                    ),
                    (route) => false);
              },
              child: Text("Cancel")),
          SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }
}
