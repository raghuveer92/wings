class UserData{
  final String uid;
  final String name;
  final String email;
  final String password;
  final String imageUrl;
  UserData({this.uid, this.name,this.email, this.password, this.imageUrl});
  Map<String, dynamic> toMap(){
    return {
      "uid":uid,
      "name":name,
    };
  }
}