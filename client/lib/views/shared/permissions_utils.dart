import 'package:tms/schema/tms_schema.dart';

bool checkPermissions(Permissions perms, User user) {
  if (user.permissions.admin) {
    return true;
  } else {
    if ((user.permissions.headReferee ?? false) && (perms.headReferee ?? false)) {
      return true;
    } else if ((user.permissions.referee ?? false) && (perms.referee ?? false)) {
      return true;
    } else if ((user.permissions.judgeAdvisor ?? false) && (perms.judgeAdvisor ?? false)) {
      return true;
    } else if ((user.permissions.judge ?? false) && (perms.judge ?? false)) {
      return true;
    }
  }

  return false; // if fall through
}
