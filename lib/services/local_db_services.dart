import 'package:Mini_Bill/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class LocalDbServices {
  Database? db;

  Future<void> init() async {
    db = await openDatabase(
      path.join(await getDatabasesPath(), "login_app.db"),
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE users(userid INTEGER , code INTEGER, email TEXT, password TEXT, username TEXT, actype TEXT, cmpcd TEXT, description TEXT)",
        );
      },
    );
  }

  Future<List<User>> getUsers() async {
    final List<Map<Object?, Object?>> users = await db!.query("users");
    return users.map((e) => User.fromMap(e)).toList();
  }

  Future<void> saveUsers(List<User> users) async {
    // empty the table
    print(users);
    await db!.delete("users");
    for (var user in users) {
      await db!.insert("users", user.toMap());
    }
    final List<Map<Object?, Object?>> users1 = await db!.query("users");
    print(users1);
  }

  Future<User?> queryUser(String username, String password) async {
    final List<Map<String, Object?>> users = await db!.query(
      "users",
      where: '"username" = ? AND "password" = ?',
      whereArgs: [username, password],
    );
    print(users);
    if (users.isEmpty) {
      return null;
    }
    return users.map((e) => User.fromMap(e)).first;
  }
}
