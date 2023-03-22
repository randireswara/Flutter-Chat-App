class UsersModel {
  String? uid;
  String? email;
  String? name;
  String? keyName;
  String? photoURL;
  String? status;
  String? lastSignIn;
  String? createdAt;
  String? updateTime;
  List<ChatsUser>? chats;

  UsersModel(
      {this.uid,
      this.email,
      this.name,
      this.keyName,
      this.photoURL,
      this.status,
      this.lastSignIn,
      this.createdAt,
      this.updateTime,
      this.chats});

  UsersModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    email = json['email'];
    name = json['name'];
    keyName = json['keyName'];
    photoURL = json['photoURL'];
    status = json['status'];
    lastSignIn = json['lastSignIn'];
    createdAt = json['createdAt'];
    updateTime = json['updateTime'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['email'] = email;
    data['name'] = name;
    data['keyName'] = keyName;
    data['photoURL'] = photoURL;
    data['status'] = status;
    data['lastSignIn'] = lastSignIn;
    data['createdAt'] = createdAt;
    data['updateTime'] = updateTime;

    return data;
  }
}

class ChatsUser {
  String? connection;
  String? chatId;
  String? lastTime;
  int? total_unread;

  ChatsUser({this.connection, this.chatId, this.lastTime, this.total_unread});

  ChatsUser.fromJson(Map<String, dynamic> json) {
    connection = json['connection'];
    chatId = json['chat_id'];
    lastTime = json['lastTime'];
    total_unread = json['total_unread'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['connection'] = connection;
    data['chat_id'] = chatId;
    data['lastTime'] = lastTime;
    data['total_unread'] = total_unread;
    return data;
  }
}
