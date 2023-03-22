import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatRoomController extends GetxController {
  //TODO: Implement ChatRoomController
  var isShowEmoji = false.obs;
  int total_unread = 0;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late FocusNode focusNode;

  late TextEditingController chatC;

  late ScrollController scrollC;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamChats(String chat_id) {
    CollectionReference chats = firestore.collection("chats");

    return chats.doc(chat_id).collection("chat").orderBy("time").snapshots();
  }

  Stream<DocumentSnapshot<Object?>> streamFriendData(String friendEmail) {
    CollectionReference users = firestore.collection("users");
    return users.doc(friendEmail).snapshots();
  }

  void addEmojiToChat(Emoji emoji) {
    chatC.text = chatC.text + emoji.emoji;
  }

  void deleteEmoji() {
    chatC.text = chatC.text.substring(0, chatC.text.length - 2);
  }

  void newChat(String email, Map<String, dynamic> argument, String chat) async {
    if (chat != 0) {
      CollectionReference chats = firestore.collection("chats");
      CollectionReference users = firestore.collection("users");
      String date = DateTime.now().toIso8601String();

      await chats.doc(argument["chat_id"]).collection("chat").add({
        "pengirim": email,
        "penerima": argument["friendEmail"],
        "msg": chat,
        "time": date,
        "isRead": false,
        "groupTime": DateFormat.yMMMd('en_US').format(DateTime.parse(date)),
      });

      Timer(Duration.zero,
          () => scrollC.jumpTo(scrollC.position.maxScrollExtent));
      // for friend database

      chatC.clear();

      await users
          .doc(email)
          .collection("chats")
          .doc(argument["chat_id"])
          .update({
        "last_time": date,
      });

      final checkChatsFriend = await users
          .doc(argument["friendEmail"])
          .collection("chats")
          .doc(argument["chat_id"])
          .get();

      if (checkChatsFriend.exists) {
        // there is a data chat in our friend
        // first check
        final checkTotalUnread = await chats
            .doc(argument["chat_id"])
            .collection("chat")
            .where("isRead", isEqualTo: false)
            .where("pengirim", isEqualTo: email)
            .get();

        // total unread for friend
        total_unread = checkTotalUnread.docs.length;

        await users
            .doc(argument["friendEmail"])
            .collection("chats")
            .doc(argument["chat_id"])
            .update({
          "last_time": date,
          "total_unread": total_unread,
        });
      } else {
        // not exist in friend database
        await users
            .doc(argument["friendEmail"])
            .collection("chats")
            .doc(argument["chat_id"])
            .set({
          "connection": email,
          "last_time": date,
          "total_unread": total_unread + 1
        });
      }
    }
  }

  @override
  void onInit() {
    chatC = TextEditingController();
    focusNode = FocusNode();
    scrollC = ScrollController();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isShowEmoji.value = false;
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    chatC.dispose();
    focusNode.dispose();
    scrollC.dispose();
    super.onClose();
  }
}
