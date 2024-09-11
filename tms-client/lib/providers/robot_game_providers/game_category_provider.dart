import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/category.dart';

class GameCategoryProvider extends EchoTreeProvider<String, TmsCategory> {
  GameCategoryProvider()
      : super(
          tree: ":robot_game:categories",
          fromJsonString: (json) => TmsCategory.fromJsonString(json: json),
        );

  List<TmsCategory> get categories {
    return this.items.values.toList()..sort((a, b) => a.category.compareTo(b.category));
  }
}
