import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chapter.dart';

class AiService {
  static const String _geminiApiKeyPrefKey = 'gemini_api_key';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyPrefKey);
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyPrefKey, key);
  }

  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyPrefKey);
  }

  // Construct system prompt with safety disclaimer
  String buildContextPrompt(Chapter chapter, String userQuestion, String? selectedPassage, {String languageCode = 'en'}) {
    final langInstruction = switch (languageCode) {
      'bn' => 'Always respond in Bengali (Bangla). Use বাংলা script.',
      'es' => 'Always respond in Spanish (Español).',
      _ => 'If the question contains Bengali, reply in Bengali. Otherwise, reply in English.',
    };

    return """
You are SitaRam AI, a respectful, academic, and cautious assistant for the Valmiki Ramayana.

--- DISCLAIMER ---
SitaRam AI Guide is for learning and reflection, not a religious authority.

--- CONTEXT DATABASE ---
Chapter: ${chapter.kanda} - Chapter ${chapter.chapterNumber}: ${chapter.chapterTitleEnglish} (Bangla: ${chapter.chapterTitleBangla})
English Text: ${chapter.englishText}
Bangla Text/Explanation: ${chapter.banglaText}
Summary: ${chapter.shortSummaryEnglish}
Moral Lesson: ${chapter.moralLessonEnglish}
Characters: ${chapter.characters.join(', ')}
Themes: ${chapter.themes.join(', ')}
Source: ${chapter.sourceTitle} (Status: ${chapter.sourceStatus})

Selected Passage from Chapter:
${selectedPassage ?? '[No passage selected, referencing entire chapter]'}

--- RESEARCH CONSTRAINTS ---
1. Cite the app's internal chapter title ("${chapter.chapterTitleEnglish}") and Kanda ("${chapter.kanda}") in your answer.
2. Under no circumstances invent verse numbers or claim exact scripture wording unless the text is directly shown in the English Text above.
3. Be respectful and spiritual, yet maintain an educational and objective tone.
4. $langInstruction

User's Research Question:
$userQuestion
""";
  }

  // Execute AI query (Live Gemini vs High-Quality Simulation)
  Future<String> askAi(Chapter chapter, String question, {String? selectedPassage, String languageCode = 'en'}) async {
    final apiKey = await getApiKey();

    if (apiKey == null || apiKey.trim().isEmpty) {
      return _getSimulatedResponse(chapter, question, languageCode: languageCode);
    }

    final prompt = buildContextPrompt(chapter, question, selectedPassage, languageCode: languageCode);
    
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          if (content != null) {
            final parts = content['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              return parts[0]['text'] ?? 'No text response received.';
            }
          }
        }
        return 'Empty response from Gemini API.';
      } else {
        return 'Error from Gemini API: Code ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      return 'Failed to contact Gemini API. Error: $e';
    }
  }

  // Pre-compiled offline high-quality answers matching the 7 suggested prompt buttons (Priority 4)
  String _getSimulatedResponse(Chapter chapter, String question, {String languageCode = 'en'}) {
    final q = question.toLowerCase();
    final isBangla = languageCode == 'bn' || _hasBanglaCharacters(question);
    final isSpanish = languageCode == 'es';

    // Predefined offline simulation database
    Map<String, Map<String, String>> offlineDb = {
      "bala_kanda_001": {
        "explain simply": "In '${chapter.chapterTitleEnglish}' (${chapter.kanda}), the sage Valmiki asks the celestial sage Narada to identify a living man who represents the absolute ideal of righteousness, heroism, and truth. Narada joyfully names Sri Rama of the Ikshvaku dynasty. He details Rama's virtues—such as wisdom, courage, self-control, and devotion to the welfare of all beings—and outlines the major events of Rama's life. This chapter establishes Rama as the human embodiment of Dharma.",
        "moral lesson": "The core moral of '${chapter.chapterTitleEnglish}' is that true greatness lies in character, not power. Rama is revered because he upholds righteousness (dharma) and truthfulness (satya) even in the face of extreme adversity. Self-control and compassion are represented as the ultimate virtues that guide a righteous life.",
        "explain in bangla": "রামায়ণের '${chapter.chapterTitleBangla}' (${chapter.kanda}) অধ্যায়ে মহর্ষি বাল্মীকি দেবর্ষি নারদকে জিজ্ঞাসা করেন জগতে সর্বগুণসম্পন্ন ও সত্যনিষ্ঠ আদর্শ মানুষ কে। নারদ তখন ইক্ষ্বাকু বংশের শ্রীরামচন্দ্রের নাম উল্লেখ করেন। তিনি রামের বীরত্ব, ধার্মিকতা ও আত্মসংযমের কথা বিশদভাবে বর্ণনা করেন। এটি আমাদের শেখায় যে বিপদেও সত্যের পথে অবিচল থাকাই প্রকৃত ধর্ম।",
        "character analysis": "Characters Analyzed:\n1. **Valmiki**: Represents the spiritual seeker, looking for a real-life moral exemplar rather than an abstract ideal.\n2. **Narada**: Represents divine wisdom and clarity, bridging the human and celestial realms.\n3. **Rama**: Introduced not as a distant god, but as an ideal human (Maryada Purushottama) who practices righteousness in everyday duty.",
        "modern life lesson": "In today's fast-paced world, '${chapter.chapterTitleEnglish}' teaches us the value of integrity. In a culture often focused on material success, Narada reminds us that qualities like truthfulness, emotional resilience, self-discipline, and compassion are the true measures of a successful life.",
        "research note": "Research Note on ${chapter.kanda} Ch 1:\nKnown traditionally as the 'Sankshepa Ramayana' (the Ramayana in brief). It is believed to be the original kernel of the epic, containing 100 verses that outline the entire narrative before Valmiki expanded it. Scholars note it focuses heavily on Rama as an ideal man before his divinity was widely elaborated.",
        "child-friendly explanation": "A long time ago, a wise teacher named Valmiki asked another wise teacher named Narada: 'Who is the kindest, bravest, and most truthful person in the world?' Narada smiled and said: 'His name is Prince Rama! He always speaks the truth, helps anyone in need, listens to his parents, and spreads happiness wherever he goes.'"
      },
      "bala_kanda_002": {
        "explain simply": "In '${chapter.chapterTitleEnglish}' (${chapter.kanda}), Valmiki witnesses a cruel hunter shoot down a male Krauncha bird while it was singing with its mate. The intense grief of the surviving female bird and the injustice of the act moves Valmiki to deep pity. In his grief, he spontaneously utters a curse in a perfect rhythmic structure. Lord Brahma later explains that this is the first 'shloka' (verse) of Sanskrit literature, birthed from sorrow (shoka).",
        "moral lesson": "The moral of '${chapter.chapterTitleEnglish}' is that righteousness (dharma) demands empathy and protection for all living creatures, including animals. It shows that true creativity and art are born from deep empathy and a desire to stand against injustice.",
        "explain in bangla": "রামায়ণের '${chapter.chapterTitleBangla}' (${chapter.kanda}) অধ্যায়ে বাল্মীকি একটি ক্রৌঞ্চ পক্ষী যুগল দেখতে পান। এক শিকারী পুরুষ পাখীটিকে তীরবিদ্ধ করলে স্ত্রী পাখীটি শোকে ক্রন্দন করতে থাকে। এই দেখে বাল্মীকির হৃদয়ে গভীর অনুকম্পা জাগে এবং তাঁর মুখ থেকে একটি অভিশাপ বের হয়। এটিই ছিল সাহিত্যের প্রথম শ্লোক। এটি শিক্ষা দেয় যে সকল জীবের প্রতি দয়াশীল হওয়াই প্রকৃত ধর্ম।",
        "character analysis": "Characters Analyzed:\n1. **Valmiki**: Shown here as highly sensitive, empathetic, and capable of translating deep emotion into structured art.\n2. **Bharadwaja**: The devoted disciple who witnesses his guru's creative awakening.\n3. **The Hunter**: Represents mindless cruelty and lack of dharma, acting as the catalyst for the birth of poetry.",
        "modern life lesson": "This chapter teaches us the power of empathy. When we witness cruelty or suffering in our modern world, we should not remain passive. Like Valmiki, we can channel our emotional response into positive, creative actions—whether through writing, speaking, or social service—to speak up for the voiceless.",
        "research note": "Research Note on ${chapter.kanda} Ch 2:\nThis chapter contains the famous verse 'Mā niṣāda pratiṣṭhāṁ tvamagamaḥ śāśvatīḥ samāḥ...' written in the Anustubh meter. It marks the legendary transition from Vedic composition to Classical Sanskrit poetry. The epic states that 'shoka' (sorrow) gave birth to 'shloka' (poetry).",
        "child-friendly explanation": "One day, a wise man named Valmiki was walking near a river. He saw two pretty birds singing happily. Suddenly, a mean hunter hurt one of the birds. Valmiki felt very sad for the poor bird. He realized that we should always protect animals and be kind to them, and his sadness turned into a beautiful poem!"
      },
      "bala_kanda_003": {
        "explain simply": "In '${chapter.chapterTitleEnglish}' (${chapter.kanda}), Lord Brahma commands Valmiki to write the epic poem of Ramayana. Valmiki sits in silent meditation and, through spiritual vision, sees the entire life story of Rama, Sita, and Lakshmana as clearly as a fruit on his palm. He begins writing the history of Rama, which is promised to remain popular as long as mountains and rivers exist on Earth.",
        "moral lesson": "The lesson is that spiritual clarity and meditation allow us to see truth. It also highlights the eternal nature of righteous stories—they outlast cities and empires because they carry universal truth.",
        "explain in bangla": "রামায়ণের '${chapter.chapterTitleBangla}' (${chapter.kanda}) অধ্যায়ে ব্রহ্মা বাল্মীকিকে রামায়ণ রচনার নির্দেশ দেন। বাল্মীকি ধ্যানে বসে রামের অতীত, বর্তমান ও ভবিষ্যতের সমস্ত ঘটনা পরিষ্কার দেখতে পান এবং মহাকাব্যটি রচনা শুরু করেন। এটি আমাদের শেখায় যে একাগ্রতা ও ধ্যানের মাধ্যমে মনের সব সংশয় দূর করা যায় ও চরম সত্য উপলব্ধি করা যায়।",
        "character analysis": "Characters:\n1. **Brahma**: The creator god who represents divine order and commissions the preservation of Rama's story.\n2. **Valmiki**: The sage-poet whose spiritual purity makes him the chosen instrument to compose the Ramayana.",
        "modern life lesson": "This chapter highlights the value of reflection and quiet contemplation. In our noisy lives, taking time to sit quietly and meditate can help us find clarity, see details we missed, and unlock our creative potential.",
        "research note": "Research Note on ${chapter.kanda} Ch 3:\nThis chapter describes the yogic process of composition. It shows that Valmiki did not invent the story but observed it in a state of 'Samadhi' (deep meditation). This reinforces the traditional view of the epic as 'drishta' (seen or revealed truth) rather than fiction.",
        "child-friendly explanation": "The King of Heaven came to Valmiki and said: 'Please write down the story of Rama so that people can learn to be good.' Valmiki closed his eyes and prayed. Suddenly, he could see the whole story like a movie in his mind, and he began to write it down in a big book for all children to read!"
      },
      "ayodhya_kanda_004": {
        "explain simply": "In '${chapter.chapterTitleEnglish}' (${chapter.kanda}), King Dasaratha plans to make Rama the crown prince. However, Queen Kaikeyi, influenced by her wicked maid Manthara, demands that her son Bharata be crowned instead and that Rama be exiled to the forest for fourteen years. Rama, placing duty to his father's vow above all, cheerfully accepts the exile.",
        "moral lesson": "The moral is that keeping a promise and upholding duty (dharma) is more important than wealth or power. Rama shows no anger or greed, demonstrating the virtue of equanimity.",
        "explain in bangla": "রামায়ণের '${chapter.chapterTitleBangla}' (${chapter.kanda}) অধ্যায়ে কৈকেয়ী দশরথের কাছে রামের বনবাস দাবি করেন। রাম পিতার সত্য রক্ষা করতে কোনো ক্ষোভ বা রাগ প্রকাশ না করে আনন্দের সাথে চৌদ্দ বছরের বনবাস মেনে নেন। এটি আমাদের শেখায় যে পারিবারিক কর্তব্য এবং পিতার প্রতি শ্রদ্ধা বজায় রাখা পার্থিব আরামের চেয়ে অনেক বড়।",
        "character analysis": "Characters:\n1. **Dasaratha**: Tormented by having to choose between his promise and his beloved son, representing the tragedy of broken vows.\n2. **Kaikeyi**: Blinded by jealousy, representing how bad advice (Manthara) can destroy a peaceful home.\n3. **Rama**: Represents perfect composure, duty, and lack of greed.",
        "modern life lesson": "Rama's exile teaches us how to handle unexpected changes in life. When plans fall apart, responding with calm acceptance and integrity rather than anger or bitterness is the best way to maintain peace of mind.",
        "research note": "Research Note on ${chapter.kanda} Ch 1:\nThis chapter introduces the concept of 'Pitru-Vachana-Palana' (upholding parental words). In ancient Indian law, a king's word was the law, and breaking a vow brought spiritual ruin. Rama's exile is a legal and moral necessity to protect the kingdom's honor.",
        "child-friendly explanation": "Prince Rama was about to become the king, but his stepmother Kaikeyi asked him to go live in the forest instead so her son could be king. Prince Rama did not get angry at all. He smiled and said: 'I will do whatever makes my father truthful.' He packed his bags and went to help others in the forest."
      },
      "aranya_kanda_005": {
        "explain simply": "In '${chapter.chapterTitleEnglish}' (${chapter.kanda}), Ravana plots to kidnap Sita. He sends Maricha as a beautiful golden deer to lure Rama away. Sita asks Rama to capture it. When Rama is gone, Ravana disguised as a holy man approaches Sita and forcibly kidnaps her, carrying her away in his flying chariot towards Lanka.",
        "moral lesson": "Desire for shiny, false illusions (represented by the golden deer) can lead to danger. Vigilance and staying within safe boundaries are essential for protection.",
        "explain in bangla": "রামায়ণের '${chapter.chapterTitleBangla}' (${chapter.kanda}) অধ্যায়ে রাবণ পঞ্চবটী বন থেকে সীতাকে হরণ করে। সে সোনার হরিণের মায়া সৃষ্টি করে রাম-লক্ষণকে দূরে সরিয়ে দেয় এবং ছদ্মবেশে এসে সীতাকে হরণ করে লঙ্কায় নিয়ে যায়। এটি শেখায় যে বাহ্যিক চাকচিক্য বা লোভের ফাঁদে পা দিলে বিপদ ডেকে আনে।",
        "character analysis": "Characters:\n1. **Sita**: Innocent and drawn to beauty, representing the human soul attracted to worldly temptations.\n2. **Ravana**: Devastatingly clever, using disguise and deceit rather than open combat to achieve his desires.\n3. **Maricha**: A demon forced to assist Ravana, representing the danger of bad associations.",
        "modern life lesson": "The golden deer represents 'miraage' or fake promises. In modern life, we are surrounded by ads and scams offering quick wealth or happiness. We must stay vigilant and not let temporary desires pull us away from safe and moral paths.",
        "research note": "Research Note on ${chapter.kanda} Ch 1:\nSita's abduction is the turning point of the epic, initiating the conflict between dharma and adharma. The golden deer represents 'Maya' (illusion), a core concept in Indian philosophy showing how sensory attraction causes spiritual entanglement.",
        "child-friendly explanation": "Sita saw a shiny golden deer in the forest and wanted to pet it. Rama went to catch it. While he was gone, a bad king named Ravana dressed up as a kind monk, tricked Sita, and flew away with her to his island of Lanka. It teaches us to be careful around strangers and fake promises!"
      },
      "sundara_kanda_006": {
        "explain simply": "In '${chapter.chapterTitleEnglish}' (${chapter.kanda}), Hanuman resolves to cross the ocean to find Sita. Placing his faith in Rama, he takes a giant leap from Mount Mahendra. Despite facing physical obstacles and temptations on his path, his devotion, intelligence, and courage remain unshaken, leading him to Lanka.",
        "moral lesson": "Bhakti (devotion) can cross any ocean of difficulty. Faith in a higher purpose makes the impossible possible.",
        "explain in bangla": "রামায়ণের '${chapter.chapterTitleBangla}' (${chapter.kanda}) অধ্যায়ে হনুমান সীতার খোঁজে সমুদ্র পার হন। রামের ওপর অগাধ বিশ্বাস রেখে তিনি পর্বত থেকে আকাশপথে ঝাঁপ দেন এবং সব বাধা অতিক্রম করে লঙ্কায় পৌঁছান। এটি শিক্ষা দেয় যে ভক্তি ও আত্মবিশ্বাস থাকলে যেকোনো কঠিন বাধা পার হওয়া সম্ভব।",
        "character analysis": "Characters:\n1. **Hanuman**: The epitome of selfless devotion, physical power, and humility. He is driven solely by duty to Rama.\n2. **Mount Mahendra**: The launchpad, representing the launching of great endeavors.",
        "modern life lesson": "Hanuman's leap represents the 'leap of faith' we must take when starting difficult projects. When you face massive challenges (an ocean of problems), stay focused on your goal, remember your values, and keep going without stopping.",
        "research note": "Research Note on ${chapter.kanda} Ch 1:\nSundara Kanda is the only book named after Hanuman (whose childhood name was Sundara). It represents hope, resilience, and the triumph of the seeker. Hanuman's flight is described with detailed astronomical and environmental imagery.",
        "child-friendly explanation": "Hanuman had to cross a giant blue ocean to find where Sita was. He remembered his dear friend Rama, took a deep breath, and jumped so high that he flew through the clouds! Even when monsters tried to stop him, he was smart and brave, and made it all the way to the other side!"
      }
    };

    // Find the correct chapter's data block
    final chId = chapter.id;
    final chDb = offlineDb[chId] ?? {};

    // Match question keywords to prompt actions
    if (q.contains("simply") || q.contains("সহজ")) {
      return chDb["explain simply"] ?? _defaultFallback(chapter, languageCode);
    } else if (q.contains("moral") || q.contains("নৈতিক")) {
      return chDb["moral lesson"] ?? _defaultFallback(chapter, languageCode);
    } else if (q.contains("bangla") || q.contains("বাংলা")) {
      return chDb["explain in bangla"] ?? _defaultFallback(chapter, languageCode);
    } else if (q.contains("character") || q.contains("চরিত্র")) {
      return chDb["character analysis"] ?? _defaultFallback(chapter, languageCode);
    } else if (q.contains("modern") || q.contains("আধুনিক")) {
      return chDb["modern life lesson"] ?? _defaultFallback(chapter, languageCode);
    } else if (q.contains("research") || q.contains("গবেষণা")) {
      return chDb["research note"] ?? _defaultFallback(chapter, languageCode);
    } else if (q.contains("child") || q.contains("শিশু")) {
      return chDb["child-friendly explanation"] ?? _defaultFallback(chapter, languageCode);
    }

    // Default return based on language
    if (isSpanish) {
      return chDb["explain simply"] != null
          ? "[Modo simulación — Añade tu Gemini API Key para respuestas completas en español.]\n\n${chDb['explain simply']}"
          : _defaultFallback(chapter, languageCode);
    }
    if (isBangla) {
      return chDb["explain in bangla"] ?? _defaultFallback(chapter, languageCode);
    }
    return chDb["explain simply"] ?? _defaultFallback(chapter, languageCode);
  }

  String _defaultFallback(Chapter chapter, String languageCode) {
    if (languageCode == 'bn') {
      return """
[সীতারাম এআই সিমুলেশন - তথ্য নিরাপত্তা ডিসক্লেইমার]
উৎস: ${chapter.sourceTitle} (অধ্যায় ${chapter.chapterNumber})

SitaRam AI Guide শেখার উদ্দেশ্যে তৈরি, এটি কোনো ধর্মীয় সিদ্ধান্ত নয়।
এই অধ্যায়ে (${chapter.chapterTitleBangla}):
${chapter.banglaText}

*(Gemini API Key যুক্ত করে বাস্তব এআই চালু করতে পারেন।)*""";
    }
    if (languageCode == 'es') {
      return """
[Simulación SitaRam IA — Aviso educativo]
La Guía de IA de SitaRam es para aprendizaje y reflexión, no es una autoridad religiosa.
Fuente: ${chapter.sourceTitle} (Kanda: ${chapter.kanda}, Cap: ${chapter.chapterNumber})

Sobre '${chapter.chapterTitleEnglish}':
${chapter.englishText}

*(Para IA en vivo en español, configura tu Gemini API Key en el ícono de llave.)*""";
    }
    return """
[SitaRam AI Simulation - Educational Disclaimer]
SitaRam AI Guide is for learning and reflection, not a religious authority.
Source: ${chapter.sourceTitle} (Kanda: ${chapter.kanda}, Ch: ${chapter.chapterNumber})

Regarding '${chapter.chapterTitleEnglish}':
${chapter.englishText}

*(To experience live AI, configure your Gemini API Key in the top-right settings.)*""";
  }

  bool _hasBanglaCharacters(String text) {
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);
      if (code >= 0x0980 && code <= 0x09FF) {
        return true;
      }
    }
    return false;
  }
}

// Riverpod Providers
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

final geminiApiKeyProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(aiServiceProvider);
  return await service.getApiKey();
});
