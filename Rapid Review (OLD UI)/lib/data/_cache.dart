import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rapid_review/pages/home_page.dart';
import 'package:random_string/random_string.dart';
import 'package:rapid_review/data/_http.dart';
import 'package:rapid_review/data/_user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Map _storage = {
  "form-codes": {},
  "pending-requests": {},
  "settings": {"blocked": [], "linked": []}
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Cache {
  static Map fetch(String collection) => _storage[collection];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Database {
  // Update firestore database
  static Future<void> update(
      {required String collection, required String field, Map? data}) async {
    String? user = CurrentUser.get();
    data ??= _storage[collection];

    FirebaseFirestore.instance
        .collection(collection)
        .doc(user)
        .set({field: data}, SetOptions(merge: false));
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Forms {
  static String currentCode = "";

  // Add / Remove questions to/from a form code
  static Future<void> addQuestion({String? code, String? question}) async =>
      _storage["form-codes"][code].add(question);

  static Future<void> removeQuestion({String? code, String? question}) async =>
      _storage["form-codes"][code].remove(question);

  static Future<void> editQuestion(
          {String? code, int? index, String? question}) async =>
      _storage["form-codes"][code][index] = question;

  // Delete a code
  static Future<void> deleteCode(int index) async {
    String code = Cache.fetch('form-codes').keys.toList()[index];
    Recents.addAction("Deleted " + code, code);

    _storage["form-codes"].removeWhere((key, value) => key == code);
    await Database.update(collection: "form-codes", field: "codes");
  }

  // Cache the form codes
  static Future<void> launch() async {
    String? _user = CurrentUser.get();
    var collection = FirebaseFirestore.instance.collection("form-codes");
    var documents = await collection.doc(_user).get();

    if (documents.exists) {
      HomePage.setState(() {
        _storage["form-codes"] = documents.data()!["codes"];
      });
    } else {
      FirebaseFirestore.instance
          .collection("form-codes")
          .doc(_user)
          .set({'codes': {}});
    }
  }

  // Create a new form code
  static Future<String> create() async {
    String _code = randomAlpha(5);

    while (_storage["form-codes"].containsKey(_code)) {
      _code = randomAlpha(5);
    }
    // Create new code if user has under 5 codes
    if (_storage["form-codes"].length < CurrentUser.maxForms) {
      _storage["form-codes"][_code] = [];
      Recents.addAction("Created " + _code, _code);

      FirebaseFirestore.instance
          .collection("form-codes")
          .doc(CurrentUser.get())
          .set({'codes': _storage["form-codes"]});
    }
    return _code;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Requests {
  static List users() => _storage["pending-requests"].keys.toList();
  static Map fetch(String user) => _storage["pending-requests"][user];
  static void update(Map data) => _storage["pending-requests"] = data;

  // Delete a pending request
  static Future<void> delete(String user) async {
    _storage["pending-requests"].removeWhere((key, value) => key == user);
    await Database.update(collection: "pending-requests", field: "requests");
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Confirmations {
  static Map hex_list = {
    "1": 19,
    "2": 12,
    "3": 44,
    "4": 24,
    "5": 12,
    "6": 35,
    "7": 85,
    "8": 12,
    "0": 54,
    "a": 9,
    "b": 48,
    "c": 64,
    "d": 99,
    "e": 11,
    "f": 45,
    "g": 63,
    "h": 47,
    "i": 35,
    "j": 38,
    "k": 10,
    "l": 97,
    "m": 36,
    "n": 26,
    "o": 53,
    "p": 8,
    "q": 39,
    "r": 77,
    "s": 59,
    "t": 36,
    "u": 31,
    "v": 47,
    "w": 95,
    "x": 36,
    "y": 35,
    "z": 93,
    "9": 40,
  };

  static num newCode() {
    String _time =
        ((DateTime.now().millisecondsSinceEpoch) ~/ 60000).toString();
    String _hash =
        (sha1.convert(utf8.encode(CurrentUser.get()! + _time))).toString();

    num code = 0;
    for (int i = 0; i < _hash.length; i++) {
      code += hex_list[_hash[i]] * hex_list[_hash[0]];
    }
    return code;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Recents {
  static Map _recentActions = {};
  static List getActions() => List.from(_recentActions.keys.toList().reversed);

  // Cache the recent actions from storage
  static Future<void> launch() async {
    String? _user = CurrentUser.get();
    String? _data = await FlutterSecureStorage().read(key: _user!);

    // Update the recent actions map with data
    _recentActions = {};
    _data == null ? update(data: {}) : {_recentActions = json.decode(_data)};
  }

  // Update the storage
  static Future<void> update({required Map data}) async {
    String? _user = CurrentUser.get();
    await FlutterSecureStorage().write(key: _user!, value: json.encode(data));
    _recentActions = data;
  }

  // Add a new recent action
  static Future<void> addAction(String action, [var value]) async {
    HomePage.setState(() {
      if (_recentActions.length > CurrentUser.maxRecents) {
        _recentActions.removeWhere(
            (key, value) => key == _recentActions.keys.toList()[0]);
      }
      // Determine which option
      if (action.contains(RegExp(r'delete', caseSensitive: false))) {
        _recentActions[action] = _storage["form-codes"][value];
      } else if (action.contains(RegExp(r'decline', caseSensitive: false))) {
        _recentActions[action] = value;
      } else if (action.contains(RegExp(r'accept', caseSensitive: false))) {
        _recentActions[action] = value;
      } else if (action.contains(RegExp(r'create', caseSensitive: false))) {
        _recentActions[action] = 0;
      } else if (action.contains(RegExp(r'unblock', caseSensitive: false))) {
        _recentActions[action] = 0;
      } else if (action.contains(RegExp(r'block', caseSensitive: false))) {
        _recentActions[action] = 0;
      }
      update(data: _recentActions);
    });
  }

  // Undo a recent action
  static Future<void> undoAction(String action) async {
    // Undo a deleted form
    if (action.contains(RegExp(r'delete', caseSensitive: false))) {
      String code = action.split(" ")[1];
      _storage["form-codes"][code] = _recentActions[action];
      await Database.update(collection: "form-codes", field: "codes");

      // Update the recent actions
      HomePage.setState(() {
        _recentActions.removeWhere((key, value) => key == action);
        _recentActions["Undo $action"] = 0;
      });
    }

    // Undo a decline drequest
    else if (action.contains(RegExp(r'decline', caseSensitive: false))) {
      // Undo the action
      String user = action.split(" ")[1].replaceAll(new RegExp(r"'s"), "");
      _storage["pending-requests"][user] = _recentActions[action];
      await Database.update(collection: "pending-requests", field: "requests");

      // Update the recent actions
      HomePage.setState(() {
        _recentActions.removeWhere((key, value) => key == action);
        _recentActions["Undo $action"] = 0;
      });
    }

    // Undo an accepted request
    else if (action.contains(RegExp(r'accept', caseSensitive: false))) {
      bool result = await DiscordApi.send(
          option: "remove",
          guildId: _recentActions[action]["data"]["guild_id"],
          userId: _recentActions[action]["data"]["user_id"],
          roleId: _recentActions[action]["data"]["role_id"]);

      if (result) {
        String user = action.split(" ")[1].replaceAll(new RegExp(r"'s"), "");
        _storage["pending-requests"][user] = _recentActions[action];
        await Database.update(
            collection: "pending-requests", field: "requests");

        // Update the recent actions
        HomePage.setState(() {
          _recentActions.removeWhere((key, value) => key == action);
          _recentActions["Undo $action"] = 0;
        });
      }
    }
    await update(data: _recentActions);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Settings {
  static List fetch(String key) => _storage["settings"][key];

  static Future<List> loadLinkedAccounts() async {
    _storage["linked"] = await Accounts.getLinkedAccounts();
    return _storage["linked"];
  }

  static Future<List> loadBlockedAccounts() async {
    _storage["blocked"] = await Blocked.getBlockedUsers();
    return _storage["blocked"];
  }
}
