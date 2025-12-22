import 'package:tms_client/generated/common/common.pbenum.dart';

/// RoleGraph represents the inheritance graph of roles
class RoleGraph {
  final Map<Role, Set<Role>> _inheritance = {};

  RoleGraph();

  /// Add a role with no inheritance
  void addRole(Role role) {
    _inheritance.putIfAbsent(role, () => {});
  }

  /// Add a role with inheritance
  void addRoleWithInheritance(Role role, List<Role> inheritedRoles) {
    final entry = _inheritance.putIfAbsent(role, () => {});
    for (final parent in inheritedRoles) {
      entry.add(parent);
    }
  }

  /// Check if role has the required permissions, including inheritance
  bool hasPermission(Role role, Role required) {
    // If the role is admin, bypass all checks
    if (role == Role.ADMIN) {
      return true;
    }

    // Direct match
    if (role == required) {
      return true;
    }

    // BFS to check for inheritance
    final queue = <Role>[role];
    final visited = <Role>{role};

    while (queue.isNotEmpty) {
      final currentRole = queue.removeLast();

      // Check direct inheritance
      final inheritance = _inheritance[currentRole];
      if (inheritance != null) {
        for (final parent in inheritance) {
          if (parent == required) {
            return true;
          }

          if (visited.add(parent)) {
            queue.add(parent);
          }
        }
      }
    }

    return false;
  }
}

/// Global role graph instance
final roleGraph = _initializeRoleGraph();

RoleGraph _initializeRoleGraph() {
  final graph = RoleGraph();

  //
  // Define roles that have parent roles
  // (we don't care about dangling roles as they get checked 1:1)
  //

  // Referee roles
  graph.addRoleWithInheritance(Role.REFEREE, []);
  graph.addRoleWithInheritance(Role.HEAD_REFEREE, [Role.REFEREE]);

  // Judge roles
  graph.addRoleWithInheritance(Role.JUDGE, []);
  graph.addRoleWithInheritance(Role.JUDGE_ADVISOR, [Role.JUDGE]);

  return graph;
}

/// Extension on Role to provide permission checking
extension RolePermissions on Role {
  /// Check if this role has the required permission
  bool hasPermission(Role required) {
    return roleGraph.hasPermission(this, required);
  }
}
