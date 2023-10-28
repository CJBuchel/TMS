import 'package:flutter/foundation.dart';
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

class PermissionController extends ValueNotifier<Permissions> {
  PermissionController(Permissions initial) : super(initial);

  set perms(Permissions value) {
    super.value = value;
  }

  void setAdmin(bool value) {
    Permissions permissions = super.value;
    permissions.admin = value;
    super.value = permissions;
  }

  void setHeadReferee(bool value) {
    Permissions permissions = super.value;
    permissions.headReferee = value;
    super.value = permissions;
  }

  void setReferee(bool value) {
    Permissions permissions = super.value;
    permissions.referee = value;
    super.value = permissions;
  }

  void setJudgeAdvisor(bool value) {
    Permissions permissions = super.value;
    permissions.judgeAdvisor = value;
    super.value = permissions;
  }

  void setJudge(bool value) {
    Permissions permissions = super.value;
    permissions.judge = value;
    super.value = permissions;
  }
}
