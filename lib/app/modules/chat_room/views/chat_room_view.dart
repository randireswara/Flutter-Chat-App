import 'dart:async';

import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_room_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  final authC = Get.find<AuthController>();
  final String chat_id = (Get.arguments as Map<String, dynamic>)["chat_id"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          leadingWidth: 100,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            borderRadius: BorderRadius.circular(100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.arrow_back),
                SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: StreamBuilder<DocumentSnapshot<Object?>>(
                      stream: controller.streamFriendData((Get.arguments
                          as Map<String, dynamic>)["friendEmail"]),
                      builder: (context, snapfriendUser) {
                        if (snapfriendUser.connectionState ==
                            ConnectionState.active) {
                          var dataFriend = snapfriendUser.data!.data()
                              as Map<String, dynamic>;
                          if (dataFriend["photoURL"] == "noImage") {
                            return CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(
                                        "assets/logo/noimage.png")));
                          } else {
                            return CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  dataFriend["photoURL"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }
                        }

                        return CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset("assets/logo/noimage.png")));
                      }),
                ),
              ],
            ),
          ),
          title: StreamBuilder<DocumentSnapshot<Object?>>(
              stream: controller.streamFriendData(
                  (Get.arguments as Map<String, dynamic>)["friendEmail"]),
              builder: (context, snapfriendUser) {
                if (snapfriendUser.connectionState == ConnectionState.active) {
                  var dataFriend =
                      snapfriendUser.data!.data() as Map<String, dynamic>;
                  if (dataFriend["name"] != 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dataFriend["name"],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          dataFriend["status"],
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        )
                      ],
                    );
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lorem Ipsum",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      "Statusnya lorem",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    )
                  ],
                );
              }),
          centerTitle: false,
        ),
        body: WillPopScope(
          onWillPop: () {
            if (controller.isShowEmoji.isTrue) {
              controller.isShowEmoji.value = false;
            } else {
              Navigator.pop(context);
            }
            return Future.value(false);
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: controller.streamChats(chat_id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        var allData = snapshot.data!.docs;
                        Timer(
                            Duration.zero,
                            () => controller.scrollC.jumpTo(
                                controller.scrollC.position.maxScrollExtent));
                        return ListView.builder(
                            controller: controller.scrollC,
                            itemCount: allData.length,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "${allData[index]["groupTime"]}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    itemChat(
                                      isSender: allData[index]["pengirim"] ==
                                              authC.user.value.email!
                                          ? true
                                          : false,
                                      msg: "${allData[index]["msg"]}",
                                      time: "${allData[index]["time"]}",
                                    ),
                                  ],
                                );
                              } else {
                                if (allData[index]["groupTime"] ==
                                    allData[index - 1]["groupTime"]) {
                                  return itemChat(
                                    isSender: allData[index]["pengirim"] ==
                                            authC.user.value.email!
                                        ? true
                                        : false,
                                    msg: "${allData[index]["msg"]}",
                                    time: "${allData[index]["time"]}",
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("${allData[index]["groupTime"]}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      itemChat(
                                        isSender: allData[index]["pengirim"] ==
                                                authC.user.value.email!
                                            ? true
                                            : false,
                                        msg: "${allData[index]["msg"]}",
                                        time: "${allData[index]["time"]}",
                                      ),
                                    ],
                                  );
                                }
                              }
                            });
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    bottom: controller.isShowEmoji.isFalse
                        ? 1
                        : context.mediaQueryPadding.bottom),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: Get.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: TextField(
                          autocorrect: false,
                          controller: controller.chatC,
                          onEditingComplete: () => controller.newChat(
                              authC.user.value.email!,
                              Get.arguments as Map<String, dynamic>,
                              controller.chatC.text),
                          focusNode: controller.focusNode,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              prefixIcon: IconButton(
                                  onPressed: () {
                                    controller.focusNode.unfocus();
                                    controller.isShowEmoji.toggle();
                                  },
                                  icon: Icon(
                                    Icons.emoji_emotions_outlined,
                                    color: Colors.grey,
                                  )),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100))),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () {
                        controller.newChat(
                            authC.user.value.email!,
                            Get.arguments as Map<String, dynamic>,
                            controller.chatC.text);
                      },
                      child: CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Icons.send,
                          size: 25,
                        ),
                        backgroundColor: Colors.red[900],
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => (controller.isShowEmoji.isTrue)
                  ? Container(
                      height: 280,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          controller.addEmojiToChat(emoji);
                        },
                        onBackspacePressed: () {
                          controller.deleteEmoji();
                          // Do something when the user taps the backspace button (optional)
                          // Set it to null to hide the Backspace-Button
                        },
                        // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                        config: Config(
                          columns: 7,
                          emojiSizeMax: 32,
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          gridPadding: EdgeInsets.zero,
                          initCategory: Category.RECENT,
                          bgColor: Color(0xFFF2F2F2),
                          indicatorColor: Colors.blue,
                          iconColor: Colors.grey,
                          iconColorSelected: Colors.blue,
                          backspaceColor: Colors.blue,
                          skinToneDialogBgColor: Colors.white,
                          skinToneIndicatorColor: Colors.grey,
                          enableSkinTones: true,
                          showRecentsTab: true,
                          recentsLimit: 28,
                          noRecents: const Text(
                            'No Recents',
                            style:
                                TextStyle(fontSize: 20, color: Colors.black26),
                            textAlign: TextAlign.center,
                          ), // Needs to be const Widget
                          loadingIndicator: const SizedBox
                              .shrink(), // Needs to be const Widget
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL,
                        ),
                      ),
                    )
                  : SizedBox()),
            ],
          ),
        ));
  }
}

class itemChat extends StatelessWidget {
  const itemChat(
      {Key? key, required this.isSender, required this.msg, required this.time})
      : super(key: key);

  final bool isSender;
  final String msg;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: isSender ? Colors.red[900] : Colors.red[700],
                borderRadius: isSender
                    ? BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15))
                    : BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
            padding: EdgeInsets.all(15),
            child: Text(
              "$msg",
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(DateFormat.jm().format(DateTime.parse(time))),
        ],
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
