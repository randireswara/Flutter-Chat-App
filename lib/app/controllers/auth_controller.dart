import 'package:chat_app/app/data/models/users_model.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  var isSkipIntro = false.obs;
  var isAuth = false.obs;

  // buat fungsi untuk login dengan google
  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? userCredential;

  var user = UsersModel().obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> firstInitialized() async {
    // kita akan mengubah isAuth => true
    await autoLogin().then((value) {
      if (value) {
        isAuth.value = true;
      }
    });

    await skipIntro().then(
      (value) {
        if (value) {
          isSkipIntro.value = true;
        }
      },
    );

    // kita akan mengubah isSkipIntro menjadi => true
  }

  Future<bool> skipIntro() async {
    final box = GetStorage();
    if (box.read('skipIntro') != null || box.read('skipIntro') == true) {
      return true;
    }
    return false;
  }

  // auto login

  Future<bool> autoLogin() async {
    // kira aka
    try {
      final isSignIn = await _googleSignIn.isSignedIn();
      if (isSignIn) {
        await _googleSignIn
            .signInSilently()
            .then((value) => _currentUser = value);
        final googleAuth = await _currentUser!.authentication;

        print("CURRENT USER");
        print(_currentUser);
        print("Google Auth");
        print(googleAuth);

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        print("----------------");
        print("User Credential");
        print(userCredential);

        CollectionReference users = firestore.collection("users");

        await users.doc(_currentUser!.email).update({
          "lastSignIn":
              userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
          "updateTime": DateTime.now().toIso8601String(),
        });

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));

        user.refresh();

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatsUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatsUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat["total_unread"]));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }
        user.refresh();

        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  // login

  Future<void> Login() async {
    try {
      // ini untuk handle kebocoran data
      await _googleSignIn.signOut();

      // ini digunakan untuk mendapatkan google account
      await _googleSignIn.signIn().then((value) => _currentUser = value);

      // ini untuk mengecek status login user
      final isSignIn = await _googleSignIn.isSignedIn();

      if (isSignIn) {
        print("sudah berhasil login dengan akun : ");
        print(_currentUser);

        final googleAuth = await _currentUser!.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        print("----------------");
        print("User Credential");
        print(userCredential);

        // simpan status user bahwa sudah pernah login & tidak akan menampilkan introduction kembali
        final box = GetStorage();
        if (box.read('skipIntro') != null) {
          box.remove('skipIntro');
        }

        box.write('skipIntro', true);

        CollectionReference users = firestore.collection("users");

        final checkUser = await users.doc(_currentUser!.email).get();

        if (checkUser.data() == null) {
          await users.doc(_currentUser!.email).set({
            "uid": userCredential!.user!.uid,
            "name": _currentUser!.displayName,
            "keyName": _currentUser!.displayName!.substring(0, 1).toUpperCase(),
            "email": _currentUser!.email,
            "photoURL": _currentUser!.photoUrl ?? "noImage",
            "status": "",
            "createdAt":
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignIn": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updateTime": DateTime.now().toIso8601String(),
          });

          await users.doc(_currentUser!.email).collection("chats");
        } else {
          await users.doc(_currentUser!.email).update({
            "lastSignIn": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
          });
        }

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        // shortcut
        user(UsersModel.fromJson(currUserData));
        // user(UsersModel(
        //   createdAt: currUserData["createdAt"],
        //   name: currUserData["name"],
        //   email: currUserData["email"],
        //   keyName: currUserData["keyName"],
        //   photoURL: currUserData["photoURL"],
        //   status: currUserData["status"],
        //   uid: currUserData["uid"],
        //   updateTime: currUserData["updateTime"],
        // ));

        user.refresh();

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatsUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatsUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat["total_unread"]));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });

          user.refresh();
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        isAuth.value = true;
        Get.offAllNamed(Routes.HOME);
      } else {
        print("tidak berhasil login");
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> Logout() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  // change profile

  void changeProfile(String name, String status) async {
    String date = DateTime.now().toIso8601String();
    CollectionReference users = firestore.collection('users');

    await users.doc(_currentUser!.email).update({
      "name": name,
      "keyName": name.substring(0, 1).toUpperCase(),
      "status": status,
      "lastSignIn":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updateTime": date,
    });

    // update model
    user.update((user) {
      user?.name = name;
      user?.keyName = name.substring(0, 1).toUpperCase();
      user?.status = status;
      user?.lastSignIn =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user?.updateTime = date;
    });

    user.refresh();
    Get.defaultDialog(
      title: "berhasil",
      middleText: "Berhasil mengubah profile",
      onConfirm: () {
        Get.back();
        Get.back();
      },
      buttonColor: Colors.red[900],
      textConfirm: "okayy",
    );
  }
  // update status

  void updateStatus(String status) {
    String date = DateTime.now().toIso8601String();
    CollectionReference users = firestore.collection('users');

    users.doc(_currentUser!.email).update({
      "status": status,
      "lastSignIn":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      "updateTime": date,
    });

    // update model
    user.update((user) {
      user?.status = status;
      user?.lastSignIn =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      user?.updateTime = date;
    });

    user.refresh();
    Get.defaultDialog(
      title: "berhasil",
      middleText: "Berhasil mengupdate status",
      onConfirm: () {
        Get.back();
      },
      buttonColor: Colors.red[900],
      textConfirm: "okayy",
    );
  }

  // search

  void addNewConnection(String friendEmail) async {
    bool flagNewConnection = false;
    String date = DateTime.now().toIso8601String();
    var chat_id;
    CollectionReference chat = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");

    final docChats =
        await users.doc(_currentUser!.email).collection("chats").get();

    if (docChats.docs.length != 0) {
      // user sudah pernah chat dengan siapapun
      final checkConnection = await users
          .doc(_currentUser!.email)
          .collection("chats")
          .where("connection", isEqualTo: friendEmail)
          .get();

      if (checkConnection.docs.length != 0) {
        // sudah pernah buat koneksi dengan => friendEmail
        flagNewConnection = false;

        //chat_id from chats collection
        chat_id = checkConnection.docs[0].id;
      } else {
        // belum pernah buat koneksi dengan => friendEmail
        flagNewConnection = true;
      }
    } else {
      // belum pernah chat dengan siapapun
      // buat koneksi ...
      flagNewConnection = true;
    }

    // Fixing

    if (flagNewConnection) {
      // cek dari chats collection => connection mereka berdua

      final chatDoc = await chat.where(
        "connection",
        whereIn: [
          [
            _currentUser!.email,
            friendEmail,
          ],
          [
            friendEmail,
            _currentUser!.email,
          ]
        ],
      ).get();

      if (chatDoc.docs.length != 0) {
        // terdapat data chats (sudah ada koneksi antara mereka berdua)
        final chatDataId = chatDoc.docs[0].id;
        final chatsData = chatDoc.docs[0].data() as Map<String, dynamic>;

        // PR disini => data yang lama jangan dihapus

        await users
            .doc(_currentUser!.email)
            .collection("chats")
            .doc(chatDataId)
            .set(
          {
            "connection": friendEmail,
            "last_time": date,
            "total_unread": 0,
          },
        );

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatsUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatsUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat["total_unread"]));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        chat_id = chatDataId;

        user.refresh();
      } else {
        // built baru
        final newChatDoc = await chat.add({
          "connection": [_currentUser!.email, friendEmail],
        });

        await chat.doc(newChatDoc.id).collection("chat");

        await users
            .doc(_currentUser!.email)
            .collection("chats")
            .doc(newChatDoc.id)
            .set(
          {
            "connection": friendEmail,
            "last_time": date,
            "total_unread": 0,
          },
        );

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatsUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatsUser(
                chatId: dataDocChatId,
                connection: dataDocChat["connection"],
                lastTime: dataDocChat["lastTime"],
                total_unread: dataDocChat["total_unread"]));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        chat_id = newChatDoc.id;
        user.refresh();
      }
    }

    print(chat_id);

    final updateStatus = await chat
        .doc(chat_id)
        .collection("chat")
        .where("isRead", isEqualTo: false)
        .where("penerima", isEqualTo: _currentUser!.email)
        .get();

    updateStatus.docs.forEach((element) async {
      await chat.doc(chat_id).collection("chat").doc(element.id).update({
        "isRead": true,
      });
    });

    await users
        .doc(_currentUser!.email)
        .collection("chats")
        .doc(chat_id)
        .update({
      "total_unread": 0,
    });

    Get.toNamed(Routes.CHAT_ROOM, arguments: {
      "chat_id": "$chat_id",
      "friendEmail": friendEmail,
    });
  }
}
