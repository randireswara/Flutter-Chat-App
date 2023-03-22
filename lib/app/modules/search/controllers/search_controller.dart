import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  late TextEditingController searchC;

  var queryAwal = [].obs;
  var tempSearch = [].obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void searchFriend(String data, String email) async {
    if (data.length == 0) {
      queryAwal.value = [];
      tempSearch.value = [];
    } else {
      var capitalize = data.substring(0, 1).toUpperCase() + data.substring(1);
      print(capitalize);

      if (queryAwal.length == 0 && data.length == 1) {
        CollectionReference users = await firestore.collection("users");
        final keyNamedResult = await users
            .where("keyName", isEqualTo: data.substring(0, 1).toUpperCase())
            .where("email", isNotEqualTo: email)
            .get();

        print("TOTAL DATA : ${keyNamedResult.docs.length}");
        if (keyNamedResult.docs.length > 0) {
          for (int i = 0; i < keyNamedResult.docs.length; i++) {
            queryAwal
                .add(keyNamedResult.docs[i].data() as Map<String, dynamic>);
          }
          print("query results :");
          print(queryAwal);
        } else {
          print("tidak ada data");
        }
      }

      if (queryAwal.length != 0) {
        tempSearch.value = [];
        queryAwal.forEach((element) {
          if (element["name"].startsWith(capitalize)) {
            tempSearch.add(element);
          }
        });
      }
    }
    queryAwal.refresh();
    tempSearch.refresh();
  }

  @override
  void onInit() {
    searchC = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}
