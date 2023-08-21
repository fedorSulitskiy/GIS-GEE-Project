import 'package:intl/intl.dart';

final formatter = DateFormat("dd MMM yyyy");

/// A class that represents the data of an algorithm. 
class AlgoData {
  AlgoData({
    required this.id,
    required this.title,
    required this.upVotes,
    required this.downVotes,
    required this.datePosted,
    required this.image,
    required this.description,
    required this.isBookmarked,
    required this.api,
    required this.code,
    required this.userCreator,
    required this.creatorName,
    required this.creatorSurname,
    required this.creatorImageURL,
    required this.tags,
    required this.userVote,
  });

  final int id;
  final String title;
  int upVotes;
  int downVotes;
  final String datePosted;
  final String image;
  final String description;
  bool isBookmarked;
  final int api;
  final String code;
  final String userCreator;
  final String creatorName;
  final String creatorSurname;
  final String creatorImageURL;
  final List<dynamic> tags;
  int? userVote;

  /// Getter returning the net votes of the algorithm, subtracting negative from
  /// the negative votes.
  int get netVotes {
    return upVotes - downVotes;
  }

  /// Getter returning the formatted date as a [String] in the format of 
  /// "dd MMM yyyy", equivalent to "01 Jan 2021".
  String get formattedDate {
    DateTime dateTime = DateTime.parse(datePosted);
    return formatter.format(dateTime);
  }

  
}
