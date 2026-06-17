// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'SitaRam';

  @override
  String get appTagline => 'Leer • Escuchar • Reflexionar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navRead => 'Leer';

  @override
  String get navListen => 'Escuchar';

  @override
  String get navReflect => 'Reflexionar';

  @override
  String get navAiGuide => 'Guía de IA';

  @override
  String get navResearch => 'Investigación';

  @override
  String get navDonate => 'Apoyar';

  @override
  String get navSettings => 'Configuración';

  @override
  String get homeTitle => 'SitaRam';

  @override
  String get homeSubtitle => 'Ramayana de Valmiki';

  @override
  String get homeTagline => 'Leer  •  Escuchar  •  Reflexionar';

  @override
  String get homeKandaLibrary => 'Biblioteca de Kandas';

  @override
  String get homeDailyWisdom => 'Sabiduría diaria';

  @override
  String get homeContinueReading => 'Continuar leyendo';

  @override
  String get homeContinueListening => 'Continuar escuchando';

  @override
  String get homeOpenChapterLibrary => 'Abrir biblioteca de capítulos';

  @override
  String get homeReadMainBook => 'Leer el libro principal';

  @override
  String get homeOpenPdfBook => 'Abrir libro PDF';

  @override
  String get homeSourcePdf => 'PDF fuente';

  @override
  String homeChaptersLoaded(int count) {
    return '$count capítulo(s) cargado(s)';
  }

  @override
  String get homeNotYetCompiled => 'Este Kanda aún no está compilado.';

  @override
  String get homeNoChaptersImported => 'No se han importado capítulos';

  @override
  String get kandaNameBala => 'Bala Kanda';

  @override
  String get kandaNameAyodhya => 'Ayodhya Kanda';

  @override
  String get kandaNameAranya => 'Aranya Kanda';

  @override
  String get kandaNameKishkindha => 'Kishkindha Kanda';

  @override
  String get kandaNameSundara => 'Sundara Kanda';

  @override
  String get kandaNameYuddha => 'Yuddha Kanda';

  @override
  String get kandaNameUttara => 'Uttara Kanda';

  @override
  String get kandaDescBala =>
      'Libro de la Juventud — El nacimiento, la juventud y educación de Sri Rama, y su sagrado matrimonio con Sita.';

  @override
  String get kandaDescAyodhya =>
      'Libro de Ayodhya — Los preparativos para la coronación de Rama, los deseos de Kaikeyi y el triste exilio.';

  @override
  String get kandaDescAranya =>
      'Libro del Bosque — La vida en el bosque, encuentros con sabios y demonios, y el rapto de Sita por Ravana.';

  @override
  String get kandaDescKishkindha =>
      'Libro de Kishkindha — La alianza de Rama con Sugriva, el reino de los monos y el inicio de la búsqueda.';

  @override
  String get kandaDescSundara =>
      'Libro de la Belleza — El vuelo milagroso de Hanuman a Lanka, la localización de Sita y la quema de Lanka.';

  @override
  String get kandaDescYuddha =>
      'Libro de la Guerra — La construcción del puente, la gran batalla con Ravana y el rescate de Sita.';

  @override
  String get kandaDescUttara =>
      'Último Libro — El regreso a Ayodhya, la coronación de Sri Rama y los pasatiempos finales.';

  @override
  String get readerTabEnglish => 'English';

  @override
  String get readerTabBangla => 'বাংলা';

  @override
  String get readerTabSpanish => 'Español';

  @override
  String get readerTabInsights => 'Perspectivas';

  @override
  String get readerTabAudio => 'Audio';

  @override
  String get readerSourceInfo => 'Info de fuente';

  @override
  String get readerBanglaNotLoaded => 'Traducción en bengalí no disponible.';

  @override
  String get readerSpanishNotLoaded =>
      'Marcador de posición en español — se añadirá tras la revisión de dominio público.';

  @override
  String get readerSetAiContext => 'Establecer como contexto de IA';

  @override
  String get readerAiSnackbar =>
      'Contexto cambiado. Toca la pestaña de Guía de IA para hablar con el asistente.';

  @override
  String get readerAskAiGuide => 'Preguntar a la Guía de IA';

  @override
  String get readerChapterLabel => 'Capítulo';

  @override
  String get readerCharactersPresent => 'Personajes presentes';

  @override
  String get readerThemesPrinciples => 'Temas y principios';

  @override
  String get readerEnglishSummary => 'Resumen en inglés';

  @override
  String get readerBanglaSummary => 'Resumen en bengalí';

  @override
  String get readerSpanishSummary => 'Resumen en español';

  @override
  String get readerMoralLesson => 'Enseñanza moral (Dharma)';

  @override
  String get readerBanglaMoral => 'Moral en bengalí';

  @override
  String get readerSpanishMoral => 'Enseñanza moral';

  @override
  String get readerAudioTrack => 'Pista de audio';

  @override
  String get readerAudioEnglish => 'Narración en inglés';

  @override
  String get readerAudioBangla => 'Explicación en bengalí';

  @override
  String get readerAudioMissing =>
      'El archivo de audiolibro no está disponible actualmente. Se añadirá tras la grabación.';

  @override
  String readerSpeedLabel(double speed) {
    return 'Velocidad: ${speed}x';
  }

  @override
  String get aiGuideTitle => 'Guía de IA de las Escrituras';

  @override
  String get aiGuideDisclaimer =>
      'La Guía de IA de SitaRam es para aprendizaje y reflexión, no es una autoridad religiosa.';

  @override
  String aiGuideContextLabel(String chapter, String kanda) {
    return 'Contexto: $chapter ($kanda)';
  }

  @override
  String aiGuideWelcome(String kanda, String chapter) {
    return '¡Jai Shri Ram! Soy tu guía de investigación de IA de SitaRam.\n\nHe cargado el contexto para $kanda - $chapter.\n\n¡Escribe una pregunta o toca una sugerencia para explorar!';
  }

  @override
  String get aiGuideInputHint => 'Haz una pregunta de investigación...';

  @override
  String get aiGuideResearcher => 'Investigador';

  @override
  String get aiGuideBotName => 'SitaRam IA';

  @override
  String get aiGuideApiKeyTitle => 'Configuración de API Gemini';

  @override
  String get aiGuideApiKeyHint => 'Ingresa la clave API...';

  @override
  String get aiGuideApiKeySave => 'Guardar';

  @override
  String get aiGuideApiKeyDelete => 'Eliminar clave';

  @override
  String get aiGuideApiKeySaved => '¡Clave API guardada! IA en vivo activada.';

  @override
  String get aiGuideApiKeyDeleted =>
      'Clave API eliminada. Volviendo al modo simulación.';

  @override
  String get aiGuideApiKeyInfo =>
      'Ingresa tu clave API de Gemini para habilitar consultas de IA en vivo. Las claves se guardan de forma segura en tu dispositivo.';

  @override
  String get aiGuidePrompt1 => 'Explica este capítulo de forma sencilla';

  @override
  String get aiGuidePrompt2 => '¿Cuál es la enseñanza moral?';

  @override
  String get aiGuidePrompt3 => 'Explica el amor y el deber de Rama y Sita';

  @override
  String get aiGuidePrompt4 => 'Dame una nota de investigación';

  @override
  String get aiGuidePrompt5 => 'Explícalo para niños';

  @override
  String get aiGuidePrompt6 =>
      '¿Cómo puedo aplicar esta enseñanza en la vida moderna?';

  @override
  String get researchTitle => 'Modo de Investigación y Estudio';

  @override
  String get researchSearchHint =>
      'Buscar personajes, temas, enseñanzas morales, texto...';

  @override
  String get researchFilterAll => 'Todo';

  @override
  String get researchFilterCharacters => 'Personajes';

  @override
  String get researchFilterThemes => 'Temas';

  @override
  String get researchFilterKandas => 'Kandas';

  @override
  String get researchFilterLessons => 'Enseñanzas';

  @override
  String get researchFilterBangla => 'Bengalí';

  @override
  String get researchFilterSpanish => 'Español';

  @override
  String get researchNoResults => 'No se encontraron coincidencias';

  @override
  String get researchNoResultsHint =>
      'Intenta ajustar las palabras clave o borrar los filtros.';

  @override
  String get researchExploreThemes => 'Explorar temas';

  @override
  String get researchExploreCharacters => 'Explorar personajes';

  @override
  String get researchNotesTitle => 'Registros de reflexión guardados';

  @override
  String get researchNotesSubtitle =>
      'Escribe tus notas e ideas. Guardadas localmente en tu dispositivo.';

  @override
  String get researchNotesHint => 'Escribe tus notas de reflexión aquí...';

  @override
  String get researchNotesSave => 'Guardar nota';

  @override
  String get researchNotesSaved =>
      'Tus notas de reflexión han sido guardadas localmente.';

  @override
  String get researchAiPrompt =>
      '¿Necesitas perspectivas escriturales más profundas?';

  @override
  String get researchAiPromptSub =>
      'Pregunta a nuestra Guía de IA para analizar motivos de personajes, estructuras morales o contexto histórico.';

  @override
  String get researchAiSnackbar =>
      'Toca la pestaña \"Guía de IA\" para abrir el asistente de investigación.';

  @override
  String get donateTitle => 'Apoyo y Seva';

  @override
  String get donateHeading => 'Apoyar SitaRam';

  @override
  String get donateBody =>
      'SitaRam es gratis para todos. Tu donación ayuda a mantener la app, mejorar la calidad del audiolibro, apoyar recursos de aprendizaje en bengalí, inglés y español, y mantener disponibles las explicaciones de IA para todos.';

  @override
  String get donateNoSubscription => 'Sin suscripciones requeridas';

  @override
  String get donateNoPay => 'Sin contenido bloqueado ni muros de pago';

  @override
  String get donateNoAds => 'Sin anuncios ni interrupciones';

  @override
  String get donateOneTime => 'Bendición única';

  @override
  String get donateMonthly => 'Seva mensual';

  @override
  String get donateFooter => 'Que el dharma guíe todas tus acciones.';

  @override
  String get donateSimulatedTitle => 'Apoyo reconocido';

  @override
  String donateSimulatedBody(String amount, String tier) {
    return '¡Gracias! Tu contribución de $amount para \"$tier\" fue recibida. La integración de pago completa se conectará antes del despliegue en la tienda.';
  }

  @override
  String get donateDhanyavad => '¡Gracias! 🙏';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsTerms => 'Términos de uso';

  @override
  String get settingsAbout => 'Acerca de SitaRam';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsAboutBody =>
      'SitaRam es una app gratuita y devocional del Ramayana de Valmiki con soporte en inglés, bengalí y español. Creada con amor por Lead.AI Labs.';

  @override
  String get langEnglish => 'English';

  @override
  String get langBangla => 'বাংলা';

  @override
  String get langSpanish => 'Español';

  @override
  String get sourceSafetyTitle => 'Seguridad y verificación de fuentes';

  @override
  String get sourceBook => 'Libro fuente';

  @override
  String get sourceTranslator => 'Traductor';

  @override
  String get sourceYear => 'Año de publicación';

  @override
  String get sourceCopyright => 'Estado de derechos de autor';

  @override
  String get sourceReview => 'Estado de revisión';

  @override
  String get sourceApprovedBy => 'Aprobado por';

  @override
  String get sourceApprovalDate => 'Fecha de aprobación';

  @override
  String get generalSave => 'Guardar';

  @override
  String get generalShare => 'Compartir';

  @override
  String get generalBookmark => 'Marcador';

  @override
  String get generalFavorite => 'Favorito';

  @override
  String get generalReadMore => 'Leer más';

  @override
  String get generalListenNow => 'Escuchar ahora';

  @override
  String get generalLoading => 'Cargando...';

  @override
  String get generalError => 'Algo salió mal. Por favor intenta de nuevo.';

  @override
  String get generalRetry => 'Reintentar';

  @override
  String get generalClose => 'Cerrar';

  @override
  String get generalBack => 'Atrás';

  @override
  String get generalSearch => 'Buscar';

  @override
  String get sitaramFreeForAll => 'SitaRam es gratis para todos';

  @override
  String get allContentFree => 'Todo el contenido sigue siendo gratuito';

  @override
  String get fullTextReviewPending =>
      'El texto completo revisado se añadirá tras la revisión de dominio público.';

  @override
  String get aiPageAnalysisPending =>
      'El análisis de página de IA estará disponible tras añadir la extracción de texto revisado.';

  @override
  String get dailyWisdomTitle => 'Sabiduría diaria';

  @override
  String get dailyWisdomSubtitle => 'Un verso del Ramayana';

  @override
  String get audiobook => 'Audiolibro';

  @override
  String get pdfBook => 'Libro PDF';

  @override
  String get bookmarks => 'Marcadores';

  @override
  String get notes => 'Notas';

  @override
  String get sourceInfoLabel => 'Info de fuente';
}
