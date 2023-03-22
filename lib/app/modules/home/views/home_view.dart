import 'dart:ui';

import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:chat_app/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black38),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Chats",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.red[500],
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          Get.toNamed(Routes.PROFILE);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.chatStream(authC.user.value.email!),
                builder: (context, snapshot1) {
                  if (snapshot1.connectionState == ConnectionState.active) {
                    var listDocsChats = snapshot1.data!.docs;
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: listDocsChats.length,
                      itemBuilder: (context, index) {
                        return StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          stream: controller
                              .friendStream(listDocsChats[index]["connection"]),
                          builder: (context, snapshot2) {
                            if (snapshot2.connectionState ==
                                ConnectionState.active) {
                              var friendData = snapshot2.data!.data();
                              return friendData!["status"] == ""
                                  ? ListTile(
                                      onTap: () {
                                        controller.goToChatRoom(
                                            listDocsChats[index].id,
                                            authC.user.value.email!,
                                            listDocsChats[index]["connection"]);
                                      },
                                      leading: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.black26,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(70),
                                            child: friendData["status"] ==
                                                    "noimage"
                                                ? Image.asset(
                                                    "assets/logo/noimage.png",
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    friendData["photoURL"],
                                                    fit: BoxFit.cover,
                                                  ),
                                          )),
                                      title: Text(
                                        "${friendData["name"]} ",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      trailing: listDocsChats[index]
                                                  ["total_unread"] ==
                                              0
                                          ? SizedBox()
                                          : Chip(
                                              label: Text(
                                                  "${listDocsChats[index]["total_unread"]}")),
                                    )
                                  : ListTile(
                                      onTap: () {
                                        controller.goToChatRoom(
                                            listDocsChats[index].id,
                                            authC.user.value.email!,
                                            listDocsChats[index]["connection"]);
                                      },
                                      leading: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.black26,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(70),
                                            child: friendData["status"] ==
                                                    "noimage"
                                                ? Image.asset(
                                                    "assets/logo/noimage.png",
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    friendData["photoURL"],
                                                    fit: BoxFit.cover,
                                                  ),
                                          )),
                                      title: Text(
                                        "${friendData["name"]} ",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        "${friendData["status"]}",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      trailing: listDocsChats[index]
                                                  ["total_unread"] ==
                                              0
                                          ? SizedBox()
                                          : Chip(
                                              backgroundColor: Colors.red[800],
                                              label: Text(
                                                "${listDocsChats[index]["total_unread"]}",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                    );
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.SEARCH);
        },
        child: Icon(
          Icons.search,
        ),
        backgroundColor: Colors.red[500],
      ),
    );
  }
}
