class PlacePrediction {
  List<Prediction> predictions;
  String status;

  PlacePrediction({
    required this.predictions,
    required this.status,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    var predictionsList = json['predictions'] as List;
    List<Prediction> predictions = predictionsList.map((i) => Prediction.fromJson(i)).toList();

    return PlacePrediction(
      predictions: predictions,
      status: json['status'],
    );
  }
}

class Prediction {
  String description;
  List<MatchedSubstring> matchedSubstrings;
  String placeId;
  String reference;
  StructuredFormatting structuredFormatting;
  List<Term> terms;
  List<String> types;
  double lat;
  double lng;

  Prediction({
    required this.description,
    required this.matchedSubstrings,
    required this.placeId,
    required this.reference,
    required this.structuredFormatting,
    required this.terms,
    required this.types,
    this.lat = 0.0,
    this.lng = 0.0,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'],
      matchedSubstrings: (json['matched_substrings'] as List)
          .map((item) => MatchedSubstring.fromJson(item))
          .toList(),
      placeId: json['place_id'],
      reference: json['reference'],
      structuredFormatting:
      StructuredFormatting.fromJson(json['structured_formatting']),
      terms: (json['terms'] as List).map((item) => Term.fromJson(item)).toList(),
      types: List<String>.from(json['types']),
    );
  }
}

class MatchedSubstring {
  int length;
  int offset;

  MatchedSubstring({
    required this.length,
    required this.offset,
  });

  factory MatchedSubstring.fromJson(Map<String, dynamic> json) {
    return MatchedSubstring(
      length: json['length'],
      offset: json['offset'],
    );
  }
}

class StructuredFormatting {
  String mainText;
  List<MatchedSubstring> mainTextMatchedSubstrings;
  String secondaryText;

  StructuredFormatting({
    required this.mainText,
    required this.mainTextMatchedSubstrings,
    required this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'],
      mainTextMatchedSubstrings: (json['main_text_matched_substrings'] as List)
          .map((item) => MatchedSubstring.fromJson(item))
          .toList(),
      secondaryText: json['secondary_text'],
    );
  }
}

class Term {
  int offset;
  String value;

  Term({
    required this.offset,
    required this.value,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      offset: json['offset'],
      value: json['value'],
    );
  }
}
