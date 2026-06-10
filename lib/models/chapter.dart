class SourceMetadata {
  final String sourceTitle;
  final String authorTranslator;
  final int? publicationYear;
  final String copyrightStatus;
  final String sourceUrl;
  final String notes;
  final String? reviewerName;
  final String? approvalDate;

  SourceMetadata({
    required this.sourceTitle,
    required this.authorTranslator,
    this.publicationYear,
    required this.copyrightStatus,
    required this.sourceUrl,
    required this.notes,
    this.reviewerName,
    this.approvalDate,
  });

  factory SourceMetadata.fromJson(Map<String, dynamic> json) {
    return SourceMetadata(
      sourceTitle: json['source_title'] ?? '',
      authorTranslator: json['author_translator'] ?? '',
      publicationYear: json['publication_year'],
      copyrightStatus: json['copyright_status'] ?? '',
      sourceUrl: json['source_url'] ?? '',
      notes: json['notes'] ?? '',
      reviewerName: json['reviewer_name'],
      approvalDate: json['approval_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source_title': sourceTitle,
      'author_translator': authorTranslator,
      'publication_year': publicationYear,
      'copyright_status': copyrightStatus,
      'source_url': sourceUrl,
      'notes': notes,
      'reviewer_name': reviewerName,
      'approval_date': approvalDate,
    };
  }
}

class AudiobookDetail {
  final String chapterId;
  final String language;
  final String voiceType;
  final String audioFile;
  final double? duration;
  final String status;

  AudiobookDetail({
    required this.chapterId,
    required this.language,
    required this.voiceType,
    required this.audioFile,
    this.duration,
    required this.status,
  });

  factory AudiobookDetail.fromJson(Map<String, dynamic> json) {
    return AudiobookDetail(
      chapterId: json['chapter_id'] ?? '',
      language: json['language'] ?? '',
      voiceType: json['voice_type'] ?? '',
      audioFile: json['audio_file'] ?? '',
      duration: json['duration'] != null ? (json['duration'] as num).toDouble() : null,
      status: json['status'] ?? 'placeholder',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'language': language,
      'voice_type': voiceType,
      'audio_file': audioFile,
      'duration': duration,
      'status': status,
    };
  }
}

class Chapter {
  final String id;
  final String kandaId;
  final String kanda;
  final int chapterNumber;
  
  final String chapterTitleEnglish;
  final String chapterTitleBangla;
  
  final String englishText;
  final String banglaText;
  
  final String shortSummaryEnglish;
  final String shortSummaryBangla;
  
  final String moralLessonEnglish;
  final String moralLessonBangla;
  
  final List<String> characters;
  final List<String> themes;
  
  final String sourceTitle;
  final String sourceStatus;
  final String reviewStatus;
  
  final AudiobookDetail audioEnglish;
  final AudiobookDetail audioBangla;
  
  final SourceMetadata sourceMetadata;

  Chapter({
    required this.id,
    required this.kandaId,
    required this.kanda,
    required this.chapterNumber,
    required this.chapterTitleEnglish,
    required this.chapterTitleBangla,
    required this.englishText,
    required this.banglaText,
    required this.shortSummaryEnglish,
    required this.shortSummaryBangla,
    required this.moralLessonEnglish,
    required this.moralLessonBangla,
    required this.characters,
    required this.themes,
    required this.sourceTitle,
    required this.sourceStatus,
    required this.reviewStatus,
    required this.audioEnglish,
    required this.audioBangla,
    required this.sourceMetadata,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? '',
      kandaId: json['kandaId'] ?? '',
      kanda: json['kanda'] ?? '',
      chapterNumber: json['chapterNumber'] ?? 0,
      chapterTitleEnglish: json['chapterTitleEnglish'] ?? '',
      chapterTitleBangla: json['chapterTitleBangla'] ?? '',
      englishText: json['englishText'] ?? '',
      banglaText: json['banglaText'] ?? '',
      shortSummaryEnglish: json['shortSummaryEnglish'] ?? '',
      shortSummaryBangla: json['shortSummaryBangla'] ?? '',
      moralLessonEnglish: json['moralLessonEnglish'] ?? '',
      moralLessonBangla: json['moralLessonBangla'] ?? '',
      characters: List<String>.from(json['characters'] ?? []),
      themes: List<String>.from(json['themes'] ?? []),
      sourceTitle: json['sourceTitle'] ?? '',
      sourceStatus: json['sourceStatus'] ?? '',
      reviewStatus: json['reviewStatus'] ?? '',
      audioEnglish: AudiobookDetail.fromJson(json['audioEnglish'] ?? {}),
      audioBangla: AudiobookDetail.fromJson(json['audioBangla'] ?? {}),
      sourceMetadata: SourceMetadata.fromJson(json['source_metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kandaId': kandaId,
      'kanda': kanda,
      'chapterNumber': chapterNumber,
      'chapterTitleEnglish': chapterTitleEnglish,
      'chapterTitleBangla': chapterTitleBangla,
      'englishText': englishText,
      'banglaText': banglaText,
      'shortSummaryEnglish': shortSummaryEnglish,
      'shortSummaryBangla': shortSummaryBangla,
      'moralLessonEnglish': moralLessonEnglish,
      'moralLessonBangla': moralLessonBangla,
      'characters': characters,
      'themes': themes,
      'sourceTitle': sourceTitle,
      'sourceStatus': sourceStatus,
      'reviewStatus': reviewStatus,
      'audioEnglish': audioEnglish.toJson(),
      'audioBangla': audioBangla.toJson(),
      'source_metadata': sourceMetadata.toJson(),
    };
  }
}
