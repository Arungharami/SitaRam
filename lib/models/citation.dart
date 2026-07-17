class Citation {
  final String documentId;
  final String kanda;
  final int sarga;
  final String edition;
  final String translator;
  final String contentType;
  final String quotedText;

  Citation({
    required this.documentId,
    required this.kanda,
    required this.sarga,
    required this.edition,
    required this.translator,
    required this.contentType,
    required this.quotedText,
  });

  factory Citation.fromJson(Map<String, dynamic> json) {
    return Citation(
      documentId: json['documentId'] ?? '',
      kanda: json['kanda'] ?? '',
      sarga: json['sarga'] ?? 0,
      edition: json['edition'] ?? '',
      translator: json['translator'] ?? '',
      contentType: json['contentType'] ?? '',
      quotedText: json['quotedText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'kanda': kanda,
      'sarga': sarga,
      'edition': edition,
      'translator': translator,
      'contentType': contentType,
      'quotedText': quotedText,
    };
  }
}
