import '../models/post_model.dart';

class PostService {
  static List<PostModel> getPosts(String filter) {
    final all = <PostModel>[];

    return filter == 'all'
        ? all
        : all.where((p) => p.status == filter).toList();
  }
}
