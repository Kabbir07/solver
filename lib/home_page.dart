import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solver/SqliteDatabaseHelper.dart';
import 'package:solver/models/msgModel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  SqliteDatabaseHelper helper = Get.put(SqliteDatabaseHelper());

  @override
  void initState() {
    super.initState();
    helper.getAllmsgs();
  }

  @override
  Widget build(BuildContext context) {
    SqliteDatabaseHelper helper = Get.put(SqliteDatabaseHelper());
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Solver",
            style: TextStyle(
                fontFamily: "Kalam", fontSize: 25, fontWeight: FontWeight.bold),
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() => helper.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      reverse: true,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        primary: false,
                        itemCount: helper.msgList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: helper.msgList[index].isSender == 0
                                ? const EdgeInsets.only(right: 40)
                                : const EdgeInsets.only(left: 40),
                            width: double.maxFinite,
                            alignment: helper.msgList[index].isSender == 0
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Card(
                              color: helper.msgList[index].isSender == 0
                                  ? const Color.fromARGB(255, 50, 54, 83)
                                  : const Color.fromARGB(255, 211, 219, 248),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  Message(
                                          message:
                                              helper.msgList[index].message)
                                      .message!,
                                  style: TextStyle(
                                      color: helper.msgList[index].isSender == 1
                                          ? Colors.black
                                          : Colors.white),
                                  // textAlign: TextAlign.end,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )),
            ),
            Obx(() => helper.isResponse.value
                ? const Text("Your answer is loading...")
                : const SizedBox()),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: "Ask your problem?"),
                )),
                IconButton(
                    onPressed: () {
                      helper.chatGPTAPI(controller.text.trim().toString());
                      controller.clear();
                    },
                    icon: const Icon(Icons.send))
              ],
            )
          ],
        ),
      ),
    );
  }
}
