import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'settings.dart';
import 'common.dart';
import 'models.dart';
import 'ui_book.dart';
import 'ui_category.dart';
import 'ui_post.dart';
import 'userdata.dart';

void openBook(BuildContext context, Book b) {
  ud.touchBook(b.id);
  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => BookDetail(bookId: b.id)));
}

void openPost(BuildContext context, Post p) {
  ud.touchPost(p.id);
  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => PostDetail(postId: p.id)));
}

void openCategory(BuildContext context, LibCategory c) {
  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => CategoryScreen(categoryId: c.id)));
}

Widget bookTile(BuildContext context, Book b) => BookTile(book: b, onTap: () => openBook(context, b));

Widget postTile(BuildContext context, Post p) => PostTile(post: p, onTap: () => openPost(context, p));
