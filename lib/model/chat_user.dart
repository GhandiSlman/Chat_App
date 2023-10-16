class ChatUser {
 late String image;
 late String name;
 late String about;
 late String createdAt;
 late bool isOnline;
 late String lastActive;
 late String id;
 late String pushToken;
 late String email;

  ChatUser(
      {
      required this.image,
      required this.name,
      required this.about,
      required this.createdAt,
      required this.isOnline,
      required this.lastActive,
      required this.id,
      required this.pushToken,
      required this.email});

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last_active'] ?? '';
    id = json['id'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['name'] = this.name;
    data['about'] = this.about;
    data['created_at'] = this.createdAt;
    data['is_online'] = this.isOnline;
    data['last_active'] = this.lastActive;
    data['id'] = this.id;
    data['push_token'] = this.pushToken;
    data['email'] = this.email;
    return data;
  }
}