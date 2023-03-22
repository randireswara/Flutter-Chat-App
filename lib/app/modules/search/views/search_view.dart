import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../routes/app_pages.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            child: AppBar(
              title: const Text('Search'),
              centerTitle: true,
              backgroundColor: Colors.red[900],
              flexibleSpace: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TextField(
                    onChanged: (value) =>
                        controller.searchFriend(value, authC.user.value.email!),
                    controller: controller.searchC,
                    cursorColor: Colors.red[900],
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        hintText: "Searh new friend here ...",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        suffixIcon: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {},
                            child: Icon(
                              Icons.search,
                              color: Colors.red[900],
                            ))),
                  ),
                ),
              ),
            ),
            preferredSize: Size.fromHeight(150)),
        body: Obx(
          () => controller.tempSearch.length == 0
              ? Center(
                  child: Container(
                    width: Get.width * 0.7,
                    height: Get.width * 0.7,
                    child: Column(
                      children: [
                        Lottie.asset("assets/lottie/empty.json"),
                        Text(
                          "Data Empty",
                          style: TextStyle(fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: controller.tempSearch.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black26,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: controller.tempSearch[index]["photoURL"] ==
                                "noImage"
                            ? Image.asset(
                                "assets/logo/noimage.png",
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                controller.tempSearch[index]["photoURL"],
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    title: Text(
                      "${controller.tempSearch[index]["name"]}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "${controller.tempSearch[index]["name"]}",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    trailing: GestureDetector(
                        onTap: () => authC.addNewConnection(
                            controller.tempSearch[index]['email']),
                        child: Chip(label: Text("message"))),
                  ),
                ),
        ));
  }
}
