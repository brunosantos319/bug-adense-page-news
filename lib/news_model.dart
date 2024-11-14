import 'package:intl/intl.dart';

class NewsModel {
  final String title;
  final String description;
  final String imageUrl;
  final String dateBegin;
  final String slug;

  NewsModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.dateBegin,
    required this.slug,
  });

  factory NewsModel.fromJson(Map<String, dynamic>? json) {
    return NewsModel(
      title: json?['title'] ?? '',
      description: json?['excerpt'] ?? '',
      imageUrl: json?['featuredmedia'] ?? '',
      dateBegin: json?['date'] ?? '',
      slug: json?['slug'] ?? '',
    );
  }
}

String formatDate(String? date) {
  try {
    final dateTime = DateTime.parse(date!);

    final formattedDate =
        // ignore: unnecessary_string_escapes
        DateFormat("dd/MM/yyyy \'às\' HH:mm", 'pt_BR').format(dateTime);

    return formattedDate;
  } catch (e) {
    return '';
  }
}
