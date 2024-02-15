import 'dart:convert';
import 'package:get/get.dart';
import 'package:solver/models/msgModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class SqliteDatabaseHelper extends GetxController {
  final String _tableName = "msgs";

  var isLoading = false.obs;
  var isResponse = false.obs;
  List<Message> msgList = <Message>[].obs;

  Future<Database> getDataBase() async {
    return openDatabase(
      join(await getDatabasesPath(), "msgsDatabase.db"),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, message TEXT, isSender INTEGER)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertMsg(Message msg) async {
    int userId = 0;
    Database db = await getDataBase();
    await db.insert(_tableName, msg.toMap()).then((value) {
      userId = value;
      getAllmsgs();
    });
    return userId;
  }

  Future<List<Message>> getAllmsgs() async {
    isLoading(true);
    Database db = await getDataBase();
    List<Map<String, dynamic>> msgsMaps = await db.query(_tableName);
    isLoading(false);
    return msgList = List.generate(msgsMaps.length, (index) {
      return Message(
        id: msgsMaps[index]["id"],
        message: msgsMaps[index]["message"],
        isSender: msgsMaps[index]["isSender"],
      );
    });
  }

  final List<Map<String, String>> messages = [];
  String OpenAiKey = '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';

  Future<String> chatGPTAPI(String prompt) async {
    isResponse(true);
    update();
    insertMsg(Message(message: prompt, isSender: 1));
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OpenAiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        isResponse(false);
        update();
        insertMsg(Message(message: content, isSender: 0));
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
