import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:chat_app/app/modules/change_profile/controllers/change_profile_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/change_profile_controller.dart';

class ChangeProfileView extends GetView<ChangeProfileController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    controller.emailC.text = authC.user.value.email!;
    controller.nameC.text = authC.user.value.name!;
    controller.statusC.text = authC.user.value.status!;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          title: const Text('UpdateStatusView'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  authC.changeProfile(
                      controller.nameC.text, controller.statusC.text);
                },
                icon: Icon(Icons.save))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              AvatarGlow(
                endRadius: 75,
                duration: Duration(seconds: 2),
                glowColor: Colors.black,
                child: Container(
                  margin: EdgeInsets.all(15),
                  width: 125,
                  height: 125,
                  child: Obx(
                    () => ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: authC.user.value.photoURL == "noImage"
                          ? Image.asset(
                              "assets/logo/noimage.png",
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              authC.user.value.photoURL!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: controller.emailC,
                textInputAction: TextInputAction.next,
                readOnly: true,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: Colors.red)),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: controller.nameC,
                textInputAction: TextInputAction.next,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Nama",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: Colors.red)),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: controller.statusC,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  authC.changeProfile(
                      controller.nameC.text, controller.statusC.text);
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Status",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(color: Colors.red)),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("No Image"),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          "chosen",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: Get.width,
                child: ElevatedButton(
                  onPressed: () {
                    authC.changeProfile(
                        controller.nameC.text, controller.statusC.text);
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      )),
                ),
              )
            ],
          ),
        ));
  }
}
