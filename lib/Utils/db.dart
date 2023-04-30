import 'package:Mini_Bill/Area%20&%20Sector/Sector.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../Area & Sector/Area.dart';
import '../Customer/Customer.dart';
import '../Customer/Customer.g.dart';
import '../Products/Product.dart';

mainDB()async{
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'my_database.db');
  String sql = await rootBundle.loadString("assets/db/products.sql");
  List<String> queries = sql.split(";");

  Database database = await openDatabase(path, version: 1,
    onCreate: (Database db, int version) async {
      Batch batch = db.batch();
      for (String query in queries) {
        if (query.trim().isNotEmpty) {
          batch.execute(query);
        }
      }
      await batch.commit();
    },);
  database.close();
}
getPath(databasesPath){
  return join(databasesPath, 'my_database.db');
}
sync() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'my_database.db');
  String sql = await rootBundle.loadString("assets/db/products.sql");
  List<String> queries = sql.split(";");

  Database database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    Batch batch = db.batch();
    for (String query in queries) {
      if (query.trim().isNotEmpty) {
        batch.execute(query);
      }
    }
    await batch.commit();
  },);
  await clearTable('Product', database);

  return true;
}

fetchSector() async {
  List<Sector> fetched = [];

  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('sector').get();

  if (snapshot.value != null) {
    Map<Object?, dynamic> data = snapshot.value as Map<Object?, dynamic>;
    print(data.length);
    data.forEach((key, value) {
      fetched.add(Sector(
          value['sectorcode'], value['sectorcode'], value['sectorname']));
    });
  }
  return fetched;
}

fetchArea() async {
  List<Area> areas = [];
  final Database database = await openDatabase('my_database.db');

  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('area').get();

  if (snapshot.value != null) {
    Map<Object?, dynamic> data = snapshot.value as Map<Object?, dynamic>;
    data.forEach((key, value) {
      areas.add(Area(value['areacode'], value['areacode'], value['areaname'],
          value['sectorcode']));
    });
  }
  return areas;
}

getAll() async {
  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('product').get();
  List<Product> allData = [];
  if (snapshot.value != null) {
    Map<Object?, dynamic> data = snapshot.value as Map<Object?, dynamic>;
    data.forEach((key, value) {
      Product p = Product(
          value['code'],
          value['name'],
          double.parse(value['rate']),
          1,
          0,
          "$key",
          int.parse(value['balance']));
      allData.add(p);
    });
  }
  return allData;
}

getAllCustomer() async {
  final areaRef = FirebaseDatabase.instance.ref();
  final snapshot = await areaRef.child('parties').get();
  List<Customer> allData = [];
  if (snapshot.value != null) {
    for (var element in snapshot.children) {
      allData.add(Customer(
          "${element.child("name").value}",
          "${element.child("address").value}",
          '',
          '',
          '${element.child('code').value}',
          "${element.child("areacode").value}"));
    }
  }
  return allData;
}





Future<void> clearTable(String tableName, database) async {
  final Database db = await database;
  await db.delete(tableName);
  await insert(await getAll(), database);
  print("Product Cleared");
}
Future<void> clearCTable(String tableName, database) async {
  final Database db = await database;
  await db.delete(tableName);
  await insertCustomer(await getAllCustomer(), database);
  print("Customer Cleared");

}

Future<void> clearSTable(String tableName, database) async {
  final Database db = await database;
  await db.delete(tableName);
  await insertSector(await fetchSector(), database);
  print("Sector Cleared");

}

Future<void> clearATable(String tableName, database) async {
  final Database db = await database;
  await db.delete(tableName);
  await insertArea(await fetchArea(), database);
  print("Area Cleared");

}


Future<void> insert(List<Product> users, database) async {
  final Database db = await database;
  for (final user in users) {
    try {
      await db.insert(
        'Product',
        user.toSqlMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print(e);
    }
  }
  print("Area Added");
 await clearCTable('Parties', database);
}

Future<void> insertCustomer(List<Customer> users, database) async {
  final Database db = await database;
  for (final user in users) {
    await db.insert(
      'Parties',
      user.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  print("Customer Added");
  await clearSTable('Sector', database);
}

Future<void> insertSector(List<Sector> users, database) async {
  final Database db = await database;
  for (final user in users) {
    await db.insert(
      'Sector',
      user.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  print("Sector Added");

  await clearATable('Area', database);
}

Future<void> insertArea(List<Area> users, database) async {
  final Database db = await database;
  for (final user in users) {
    await db.insert(
      'Area',
      user.toSqlMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  print("Area Added");

  db.close();
}

void saveCustomer(String boxName, List<Map<String, dynamic>> customers) async {
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CustomerAdapter());
  }
  var box = await Hive.openBox<Customer>(boxName);
  for (var customer in customers) {
    if (box.containsKey(customer['_id'])) {
      box.delete(customer['_id']);
    }
    box.put(
        customer['_id'],
        Customer(
            customer['dsc'],
            "${customer['Address']}",
            "${customer['Phone']}",
            "",
            "${customer['_id']}",
            "${customer['AreaCd']}"));
  }
}

void openHiveBox(String boxName, List<Map<String, dynamic>> products) async {
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProductAdapter());
  }
  var box = await Hive.openBox<Product>(boxName);
  for (var product in products) {
    if (kDebugMode) {
      print(product['balance']);
    }
    if (box.containsKey(product['_id'])) {
      box.delete(product['_id']);
    }
    box.put(
        product['_id'],
        Product(
            product['pcode'] ?? "",
            product['name1'],
            double.parse("${product['rate']}"),
            1,
            0,
            "${product['_id']}",
            int.parse("${product['balance']}")));
  }
  /*SharedPreferences prefs = await SharedPreferences.getInstance();
  final dbAdded = prefs.setBool("DB_ADDED",true);
  prefs.commit();*/
}
