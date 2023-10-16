import 'package:get/get_connect/http/src/utils/utils.dart';

class Message {
  String? msg;
  String? toId;
  String? read;
  String? type;
  String? fromId;
  String? sent;
  //Type? type;

  Message({this.msg, this.toId, this.read, this.type, this.fromId, this.sent});

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'].toString();
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['toId'] = this.toId;
    data['read'] = this.read;
    data['type'] = this.type;
    data['fromId'] = this.fromId;
    data['sent'] = this.sent;
    return data;
  }
}
//enum Type {text,image}