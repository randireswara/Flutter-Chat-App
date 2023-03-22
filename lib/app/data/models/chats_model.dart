class TestChats {
  List<String>? connection;

  List<Chat>? chat;

  TestChats({
    this.connection,
    this.chat,
  });

  TestChats.fromJson(Map<String, dynamic> json) {
    connection = json['connection'].cast<String>();

    if (json['chat'] != null) {
      chat = <Chat>[];
      json['chat'].forEach((v) {
        chat?.add(Chat.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['connection'] = connection;

    if (chat != null) {
      data['chat'] = chat?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chat {
  String? pengirim;
  String? penerima;
  String? pesan;
  String? time;
  bool? isRead;

  Chat({this.pengirim, this.penerima, this.pesan, this.time, this.isRead});

  Chat.fromJson(Map<String, dynamic> json) {
    pengirim = json['pengirim'];
    penerima = json['penerima'];
    pesan = json['pesan'];
    time = json['time'];
    isRead = json['isRead'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pengirim'] = pengirim;
    data['penerima'] = penerima;
    data['pesan'] = pesan;
    data['time'] = time;
    data['isRead'] = isRead;
    return data;
  }
}
