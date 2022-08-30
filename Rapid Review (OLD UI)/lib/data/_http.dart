import 'package:url_launcher/url_launcher.dart';
import 'package:rapid_review/data/_user.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Encoder {
  static String encode(var data) =>
      sha256.convert(utf8.encode(data)).toString();

  static String encrypt(String data) {
    String time = ((DateTime.now().millisecondsSinceEpoch) ~/ 1000).toString();
    return encode(encode("username") +
        encode(data + ":" + time) +
        encode("password"));
  }
}

class Blocked {
  // Get a list of blocked users
  static Future<List> getBlockedUsers() async {
    dynamic response = await http.get(Uri.parse(
      "api_endpoint/v1/block?user=${CurrentUser.get()}"));
    return json.decode(response.body)["response"];
  }

  // Unblock an user
  static Future<bool> blockUser(String userToBlock) async {
    dynamic response = await http.put(Uri.parse(
      "api_endpoint/v1/block?user=${CurrentUser.get()}"), 
      headers: {
        "block": userToBlock,
        "auth_token": Encoder.encrypt(CurrentUser.get()! + ":" + userToBlock)
      }
    );
    return response.statusCode == 200;
  }

  // Unblock an user
  static Future<bool> unblockUser(String userToUnblock) async {
    dynamic response = await http.delete(Uri.parse(
      "api_endpoint/v1/block?user=${CurrentUser.get()}"), 
      headers: {"unblock": userToUnblock, "auth_token": Encoder.encrypt(CurrentUser.get()! + ":" + userToUnblock)}
    );
    return response.statusCode == 200;
  }
}

class Accounts {
  // Get a list of linked accounts
  static Future<List> getLinkedAccounts() async {
    Uri url = Uri.parse(
        "api_endpoint/v1/accounts?user=${CurrentUser.get()!}");
    dynamic response = await http.get(url);
    return json.decode(response.body)["response"];
  }

  // Link your discord account
  static Future<bool> linkAccount() async {
    String authToken = Encoder.encrypt(CurrentUser.get()!);

    // Open API Url
    String url = "api_endpoint/v1/accounts?auth_token=${authToken}&user=${CurrentUser.get()!}";
    if (await canLaunch(url)) await launch(url);
    return true;
  }

  // Delete a linked account
  static Future<bool> deleteLinkedAccount(String deleteUser) async {
    dynamic response = await http.delete(Uri.parse(
        "api_endpoint/v1/accounts?user=${CurrentUser.get()!}"), 
      headers: {"delete": deleteUser, "auth_token": Encoder.encrypt(CurrentUser.get()! + ":" + deleteUser)});
    return response.statusCode == 200;
  }
}

class DiscordApi {
  // Send discord api request
  static Future<bool> send(
      {required String option,
      required String guildId,
      required String userId,
      required String roleId}) async {
    // Declaring primary variables
    String _authToken = Encoder.encrypt(CurrentUser.get()!);
    String _userAuthToken =
        Encoder.encrypt(guildId + ":" + roleId + ":" + userId);

    // Creating headers and body
    Map<String, String> headers = {
      "auth_token": _authToken,
      "user_auth_token": _userAuthToken
    };

    dynamic response;
    option == "add" ? 
      response = await http.put(Uri.parse(
        "api_endpoint/v1/edit-role?user=${CurrentUser.get()}&guild_id=${guildId}&user_id=${userId}&role_id=${roleId}"), headers: headers):
        response = await http.delete(Uri.parse(
        "api_endpoint/v1/edit-role?user=${CurrentUser.get()}&guild_id=${guildId}&user_id=${userId}&role_id=${roleId}"), headers: headers);
    return response.statusCode == 200;
  }
}
