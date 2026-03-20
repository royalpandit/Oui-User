import 'dart:convert';

import 'package:equatable/equatable.dart';

class HomeQuoteModel extends Equatable {
  final int id;
  final String text;
  final String? author;
  final int status; // 1 = active, 0 = inactive

  const HomeQuoteModel({
    required this.id,
    required this.text,
    this.author,
    this.status = 1,
  });

  factory HomeQuoteModel.fromMap(Map<String, dynamic> map) {
    return HomeQuoteModel(
      id: map['id'] ?? 0,
      text: map['text'] ?? '',
      author: map['author'],
      status: map['status'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'status': status,
    };
  }

  factory HomeQuoteModel.fromJson(String source) =>
      HomeQuoteModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  /// Default fallback quotes when API has no data
  static const List<HomeQuoteModel> defaults = [
    HomeQuoteModel(
      id: 0,
      text: 'Style is a way to say who you are\nwithout having to speak.',
    ),
    HomeQuoteModel(
      id: 0,
      text: 'Elegance is the only beauty\nthat never fades.',
    ),
    HomeQuoteModel(
      id: 0,
      text: 'In a world full of trends,\nremain a classic.',
    ),
    HomeQuoteModel(
      id: 0,
      text: 'Simplicity is the ultimate\nsophistication.',
    ),
    HomeQuoteModel(
      id: 0,
      text: 'Fashion fades, only style\nremains the same.',
    ),
  ];

  @override
  List<Object?> get props => [id, text, author, status];
}
