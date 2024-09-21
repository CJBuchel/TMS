class Permissions {
  final bool admin;
  final bool referee;
  final bool headReferee;
  final bool judge;
  final bool judgeAdvisor;
  final bool scorekeeper;
  final bool emcee;
  final bool av;

  const Permissions({
    this.admin = false,
    this.referee = false,
    this.headReferee = false,
    this.judge = false,
    this.judgeAdvisor = false,
    this.scorekeeper = false,
    this.emcee = false,
    this.av = false,
  });

  bool hasAccess(List<String> roles) {
    // admin has access to all
    if (roles.contains('admin')) {
      return true;
    }

    // setup accessors
    bool access = false;

    // referee
    if (referee) {
      if (roles.contains('referee') || roles.contains('head_referee')) {
        access = true;
      }
    }

    // head referee
    if (headReferee) {
      if (roles.contains('head_referee')) {
        access = true;
      }
    }

    // judge
    if (judge) {
      if (roles.contains('judge') || roles.contains('judge_advisor')) {
        access = true;
      }
    }

    // judge advisor
    if (judgeAdvisor) {
      if (roles.contains('judge_advisor')) {
        access = true;
      }
    }

    // scorekeeper
    if (scorekeeper) {
      if (roles.contains('scorekeeper')) {
        access = true;
      }
    }

    // emcee
    if (emcee) {
      if (roles.contains('emcee') || roles.contains('head_referee')) {
        access = true;
      }
    }

    // av
    if (av) {
      if (roles.contains('av')) {
        access = true;
      }
    }

    return access;
  }
}
