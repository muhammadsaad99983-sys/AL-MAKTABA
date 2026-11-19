import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'ui_book.dart';
import 'ui_category.dart';
import 'ui_post.dart';

void openBook(BuildContext context, Book b) {
  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => BookDetail(bookId: b.id)));
}

void openPost(BuildContext context, Post p) {
  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => PostDetail(postId: p.id)));
}

void openCategory(BuildContext context, Category c) {
  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => CategoryScreen(categoryId: c.id)));
}

Widget bookTile(BuildContext context, Book b) => BookTile(book: b, onTap: () => openBook(context, b));

Widget postTile(BuildContext context, Post p) => PostTile(post: p, onTap: () => openPost(context, p));
