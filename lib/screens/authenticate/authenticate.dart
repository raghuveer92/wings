
import 'package:flutter/material.dart';
import 'package:wings/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Authenticate();
}
class _Authenticate extends State<Authenticate>{
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SignIn(),
    );
  }
}
