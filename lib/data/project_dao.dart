import 'package:floor/floor.dart';

import 'model/project.dart';

@dao
abstract class ProjectDAO {
  @insert
  Future<List<int>> insertProject(List<Project> projects);

  @Query('SELECT * FROM Project')
  Future<List<Project>> getProjects();
}
