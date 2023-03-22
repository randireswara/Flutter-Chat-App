import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> chatStream(String email) {
    return firestore
        .collection('users')
        .doc(email)
        .collection("chats")
        .orderBy("last_time", descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> friendStream(String email) {
    return firestore.collection('users').doc(email).snapshots();
  }

  void goToChatRoom(String chat_id, String email, String friendEmail) async {
    CollectionReference chats = firestore.collection("chats");
    CollectionReference user = firestore.collection("users");
    final updateStatus = await chats
        .doc(chat_id)
        .collection("chat")
        .where("isRead", isEqualTo: false)
        .where("penerima", isEqualTo: email)
        .get();

    updateStatus.docs.forEach((element) async {
      await chats.doc(chat_id).collection("chat").doc(element.id).update({
        "isRead": true,
      });
    });

    await user.doc(email).collection("chats").doc(chat_id).update({
      "total_unread": 0,
    });

    Get.toNamed(Routes.CHAT_ROOM, arguments: {
      "chat_id": chat_id,
      "friendEmail": friendEmail,
    });
  }
}
