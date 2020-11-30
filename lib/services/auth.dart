import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:wings/utils/app_constants.dart';
import 'package:wings/utils/preferences.dart';

class AppResponse<T,D>{
  final T responseType;
  final D data;

  AppResponse(this.responseType, this.data);
}
enum ResponseType{
  SUCCESS,
  ERROR
}
class AuthService{
  Future loginAnon() async{
    Preferences.saveString(PrefKeys.NAME, "GUEST");
    Preferences.saveString(PrefKeys.EMAIL, "guest***@wings.com");
    Preferences.saveString(PrefKeys.ROLE, "GUEST");
    Preferences.saveBool(PrefKeys.LOGGED_IN, true);
    var backendlessUser = await Backendless.userService.loginAsGuest(true);
    Preferences.saveString(PrefKeys.USER_ID, backendlessUser.getUserId());
  }

  Future getLoggedUser() async{
    return await Backendless.userService.currentUser();
  }
}