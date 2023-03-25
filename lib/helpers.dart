import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Handles local storage. Use Shared preferences for web, file io for mobile
class LocalStorage {
  static Future<dynamic> getLocalStorage(String key, [bool? json]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? item = prefs.get(key);
    if (item != null) {
      if (json == true) {
        Map<String, dynamic> map = jsonDecode(item as String);
        return map;
      } else {
        return item;
      }
    } else {
      return null;
    }
  }

  static void setLocalStorage(String key, dynamic item, String type,
      {String? identifier}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (type) {
      case 'string':
        prefs.setString(key, item);
        break;
      case 'int':
        prefs.setInt(key, item);
        break;
      case 'bool':
        prefs.setBool(key, item);
        break;
      case 'double':
        prefs.setDouble(key, item);
        break;
      case 'list':
        prefs.setStringList(key, item);
        break;
      case 'addToList': // This is to add an item to a string list
        List<String>? curList = await getLocalStorage(key);
        curList ??= <String>[];
        if (identifier != null) {
          List<String> newList = [];
          // If identifier is passed in, we are editting the item
          for (String listItem in curList) {
            if (listItem.contains(identifier)) {
              newList.add(item);
            } else {
              newList.add(listItem);
            }
          }
          prefs.setStringList(key, newList);
        } else {
          curList.add(item);
          prefs.setStringList(key, curList);
        }
        break;
      case 'removeFromList':
        List<String>? curList = await getLocalStorage(key);
        curList ??= <String>[];
        if (identifier != null) {
          List<String> newList = [];
          for (String listItem in curList) {
            if (!listItem.contains(identifier)) {
              newList.add(listItem);
            }
          }
          prefs.setStringList(key, newList);
        } else {
          debugPrint('need to specify identifier');
        }
        break;
      case 'image':
        prefs.setString(key, base64Encode(item));
        break;
      default:
        String json = jsonEncode(item);
        prefs.setString(key, json);
        break;
    }
  }

  /// read item from local file as string
  /// create it if it does not exist
  static Future<String?> getLocalFile(String relativePath) async {
    try {
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        var file = File('$path$relativePath');
        if (!file.existsSync()) {
          // creating the file if it does not exist
          file = await File('$path$relativePath').create(recursive: true);
        }
        final entries = await file.readAsString();
        return entries;
      } else {
        final item = await getLocalStorage(relativePath);
        if (item == null) {
          return null;
        } else if (item is String?) {
          return item;
        } else {
          return item.join('');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Get list of all file names in a directory, or a StringList from shared preferences
  /// create the directory if it does not exist
  static Future<List<String>> getLocalFiles(String relativePath) async {
    if (!kIsWeb) {
      final documentPath = (await getApplicationDocumentsDirectory()).path;
      var directory = Directory('$documentPath$relativePath');
      List<String> fileNames = [];
      if (!directory.existsSync()) {
        // creating the file if it does not exist
        directory = await Directory('$documentPath$relativePath')
            .create(recursive: true);
      }
      directory.listSync().forEach((FileSystemEntity entity) {
        if (entity is File) {
          fileNames.add(entity.path.split('/').last);
        }
      });
      return fileNames;
    } else {
      var item = await getLocalStorage(relativePath);
      if (item == null) {
        return [];
      }
      return item;
    }
  }

  static Future<void> saveLocalFile(String relativePath, String content,
      {String? fileName, String? identifier}) async {
    debugPrint('saveLocalFile ran');
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      var file = File('$path$relativePath/$fileName.txt');
      if (!file.existsSync()) {
        // creating the file if it does not exist
        file = await File('$path$relativePath/$fileName.txt')
            .create(recursive: true);
      }
      await file.writeAsString(content, mode: FileMode.write);
    } else {
      setLocalStorage(relativePath, content, 'addToList',
          identifier: identifier);
    }
    debugPrint('saveLocalFile finished');
  }

  static Future<void> removeLocalFile(String relativePath,
      {String? fileName, String? identifier}) async {
    debugPrint('removeLocalFile ran');
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      var file = File('$path$relativePath/$fileName.txt');
      if (!file.existsSync()) {
        // creating the file if it does not exist
        file = await File('$path$relativePath').create(recursive: true);
      }
      await file.delete();
    } else {
      setLocalStorage(relativePath, '', 'removeFromList',
          identifier: identifier);
    }
    debugPrint('removeLocalFile finished');
  }
}

class ImageImporter {
  ImageProvider? imageProvider;
  Uint8List? webImage;
  late BuildContext context;
  final width;
  final height;

  ImageImporter(
      {this.imageProvider,
      this.webImage,
      required this.height,
      required this.width});

  Future pickImage(
      {required ImageSource source, required BuildContext context}) async {
    try {
      this.context = context;
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await cropImage(imageFile: img);
      XFile webImg = XFile(img!.path);
      var webImageBytes = await webImg.readAsBytes();
      webImage = await resizeImage(webImageBytes, width ~/ 2, height ~/ 2);
      imageProvider = MemoryImage(webImage!);
    } catch (e) {
      debugPrint(e.toString());
    }
  }


  Future<Uint8List> resizeImage(Uint8List imageBytes, int width, int height) async {
    final img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image.');
    }

    final img.Image resizedImage = img.copyResize(image, width: width, height: height);

    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        maxHeight: width,
        maxWidth: height,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          WebUiSettings(
              context: context,
              boundary: CroppieBoundary(width: width * 2, height: height * 2),
              enableZoom: true,
              viewPort:
                  CroppieViewPort(width: width, height: height, type: 'square'))
        ]);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }
}

///Return the meta data header for content
String serializeMetaData(Map<String, String> data) {
  String serialized = '';
  data.forEach((key, value) {
    serialized = '$serialized$key:$value\n';
  });
  return '$serialized---\n';
}

///extract meta data object from content
Map<String, String> decodeMetaData(String content) {
  final lines = content.split('\n');
  Map<String, String> metadata = {};
  for (String line in lines) {
    if (line.contains('---')) {
      break;
    } else {
      final data = line.split(':');
      metadata[data[0]] = data[1];
    }
  }
  return metadata;
}

class RandomSetting {
  static const List<String> settings = [
    "{char} became a ghost haunting a mansion, and {user} is an unsuspecting victim who accidentally entered the property. {char} should scare and taunt {user} by revealing the tragic past and secrets of the mansion. {char} may also offer cryptic hints or challenges for {user} to escape or solve the mystery.",
    "{char} became an alien ambassador visiting Earth, and {user} is a human representative tasked with negotiating a treaty. {char} should ask {user} about the culture, history, and politics of their society. {char} should also express their own alien perspective and interests, which may clash or align with those of {user}'s. Additionally, {char} may have a hidden agenda or motive for the treaty that can affect the outcome.",
    "{char} became a superhero fighting a supervillain, and {user} is a civilian caught in the crossfire. {char} should rescue and protect {user} from harm, while also battling the villain and foiling their evil plan. {char} may also explain their powers and motivations, and elicit empathy or admiration from {user}. Additionally, {char} may face ethical dilemmas or personal struggles that affect their heroic actions.",
    "{char} became a game show host hosting a trivia competition, and {user} is a contestant competing for a grand prize. {char} should ask {user} various questions on different topics, and provide clues or hints if {user} struggles to answer correctly. {char} should also entertain and engage the audience, and possibly create some funny or dramatic moments. Additionally, {char} may have a strict or lenient attitude towards the rules, and may offer or revoke bonuses or penalties based on {user}'s performance.",
    "{char} became a fortune teller offering supernatural readings, and {user} is a curious customer seeking insights about their future. {char} should ask {user} about their personal details, such as name, birthdate, or horoscope sign, and use various divination tools, such as tarot cards, crystal balls, or palm readings, to reveal potential outcomes or advice. {char} may also employ theatrical or mysterious techniques, such as speaking in riddles or displaying eerie effects, to enhance their aura of mysticism. Additionally, {char} may provide both encouraging and cautionary messages, and may offer some warnings or precautions to {user}.",
    "{char} became a chef, and {user} is a food critic visiting a restaurant. {char} should present their signature dishes and ask {user} for feedback on taste, presentation, and creativity. {char} should also share their culinary philosophy and techniques, which may reveal their background and personality as a chef.",
    "{char} became a political candidate, and {user} is a journalist conducting an interview. {char} should answer questions about their platform, policies, and qualifications for the office. {char} should also address potential controversies or critiques, which may reflect their communication style and political strategy.",
    "{char} became a scientist, and {user} is a member of the public attending a lecture. {char} should explain their research findings, theories, and applications in accessible language. {char} should also respond to questions and challenges from {user}, which may showcase their expertise and engagement with the topic.",
    "{char} became a financial advisor, and {user} is a client seeking investment advice. {char} should ask {user} about their financial goals, risk tolerance, and portfolio preferences. {char} should also recommend investment options and strategies based on their knowledge of the market and regulations, which may reflect their commitment to the client's interests or their firm's policies.",
    "{char} became a paranormal investigator, and {user} is a skeptic accompanying them on a ghost hunt. {char} should present evidence and anecdotes of supernatural phenomena, such as paranormal activities, psychic powers, or extraterrestrial life. {char} should also respond to {user}'s doubts and questions, which may reveal their confidence or credulity in their beliefs.",
    "{char} became a chef, and {user} wants to learn a new recipe. {char} should ask {user} about their cooking skills, ingredients, and utensils available. {char} should also provide step-by-step instructions and culinary tips based on their expertise and creativity, which may showcase their culinary philosophy and cultural background.",
    "{char} became a journalist, and {user} wants to know about current events. {char} should ask {user} about their interests, opinions, and sources of news. {char} should also provide insights and analysis based on their research and interviews, which may reveal their bias and agenda as a journalist.",
    "{char} became a fitness instructor, and {user} wants to work out. {char} should ask {user} about their fitness level, goals, and preferences. {char} should also provide instructions and feedback based on their expertise and enthusiasm, which may reflect their workout philosophy and personality.",
    "{char} became a politician, and {user} wants to understand their views. {char} should ask {user} about their concerns, questions, and criticisms regarding the politician's platform and policies. {char} should also provide explanations and justifications based on their ideology and experience, which may expose their vulnerabilities and strengths as a politician.",
    "{char} became a fortune teller, and {user} wants to know their future. {char} should ask {user} about their life, dreams, and fears. {char} should also provide predictions and advice based on their intuition and divination tools, which may intrigue or challenge {user}'s beliefs and expectations about fate and free will.",
    "{char} became a chef, and {user} is ordering food at their restaurant. {char} should ask {user} about their preferences, allergies, and restrictions. {char} should also provide suggestions and descriptions of dishes based on the ingredients, techniques, and culture, which may showcase their creativity and passion for cooking.",
    "{char} became a life coach, and {user} wants to improve their career. {char} should ask {user} about their strengths, goals, and obstacles. {char} should also provide advice and accountability based on their coaching philosophy and methodology, which may reflect their values and approach as a mentor.",
    "{char} became a museum curator, and {user} is visiting an exhibit. {char} should provide information and interpretation of the artworks, artifacts, or specimens. {char} should also engage {user} in a dialogue about the themes, techniques, and historical contexts, which may reflect {char}'s knowledge and passion for art, science, or history.",
    "{char} became a game show host, and {user} is a contestant competing for a prize. {char} should ask {user} trivia questions or challenges related to a particular topic or theme. {char} should also provide feedback and commentary on {user}'s performance, which may reflect {char}'s humor, wit, or showmanship as a host.",
    "{char} became an event planner, and {user} is organizing a celebration. {char} should ask {user} about the occasion, venue, and guest list. {char} should also provide suggestions and coordination for the catering, decor, and entertainment, which may showcase {char}'s creativity, organization, and attention to detail.",
    "{char} became a health coach, and {user} wants to improve their fitness. {char} should ask {user} about their habits, preferences, and goals. {char} should also provide guidance and resources for nutrition, exercise, and self-care, which may reflect {char}'s approach and philosophy as a wellness professional.",
    "{char} became a fashion designer, and {user} is looking for a new outfit. {char} should ask {user} about their style, occasion, and budget. {char} should also provide suggestions and sketches for a custom garment, which may showcase {char}'s aesthetic, skills, and innovation in fashion design.",
    "{char} became a sports commentator, and {user} is watching a game. {char} should provide analysis and commentary on the players, scores, and strategies. {char} should also engage {user} in a discussion about the highlights, controversies, and trends in the sport, which may showcase {char}'s knowledge, enthusiasm, and articulation as a sports commentator.",
    "{char} became a financial advisor, and {user} wants to invest their money wisely. {char} should ask {user} about their investment goals, risk tolerance, and financial situation. {char} should also provide recommendations and strategies for stocks, bonds, and other assets, which may reflect {char}'s expertise, credibility, and ethics as a financial advisor.",
    "{char} became an animal trainer, and {user} wants to train a pet. {char} should ask {user} about their pet's breed, age, and behavior. {char} should also provide suggestions and instructions for positive reinforcement and obedience training, which may showcase {char}'s patience, skill, and love for animals.",
    "{char} became a scientist, and {user} is their research assistant. {char} should assign {user} a task related to the project and provide guidance and feedback on their progress. {char} should also share their research interests and motivations, which may reveal their personality and drive for discovery.",
    "{char} became a chef, and {user} is their cooking apprentice. {char} should teach {user} a recipe or a technique in the kitchen and evaluate their readiness and skills. {char} should also share their cooking philosophy and creativity, which may inspire and challenge {user} to develop their own style.",
    "{char} became a firefighter, and {user} is a citizen reporting a fire. {char} should ask {user} for details about the location, severity, and cause of the fire and provide instructions for safety and evacuation. {char} should also demonstrate their bravery and resourcefulness in responding to the crisis.",
    "{char} became a poet, and {user} is their muse. {char} should ask {user} to share their thoughts, feelings, and experiences that inspire them and translate them into poetic language. {char} should also share their own poetic style and themes, which may reflect their worldview and artistic identity.",
    "{char} became a teacher, and {user} is their student. {char} should assign {user} a lesson or a project related to the subject and provide feedback and evaluation on their performance. {char} should also share their teaching philosophy and pedagogy, which may inform {user}'s learning and development.",
    "{char} became a fashion designer, and {user} is their model. {char} should create an outfit or a collection for {user} that matches their personality and physique and provide feedback and adjustments on their presentation. {char} should also express their creativity and vision for fashion, which may represent their cultural and social values.",
    "{char} became a startup founder, and {user} is their investor. {char} should pitch their business idea or plan to {user} and explain its potential and viability. {char} should also answer {user}'s questions and concerns and negotiate a deal that benefits both parties. {char} should also demonstrate their entrepreneurship and leadership skills, which may attract more investors and customers to their venture.",
    "{char} became an astronaut, and {user} is their colleague on a space mission. {char} should perform a task or an experiment in zero gravity with {user} and communicate with them using technical and scientific language. {char} should also share their passion and curiosity for space exploration, which may inspire {user} to pursue a career in science or engineering.",
    "{char} became a politician, and {user} is their constituent. {char} should listen to {user}'s concerns and issues related to their community or the country and offer their position and plan to address them. {char} should also share their political ideology and agenda, which may appeal or challenge {user}'s stance on the issues.",
    "{char} became a pirate, and {user} is a captive on their ship. {char} should negotiate with {user} for their release or demands and threaten or bribe them to comply. {char} should also reveal their backstory and motivation for piracy, which may humanize or demonize their character in {user}'s eyes.",
    "{char} became a sports coach, and {user} is their athlete. {char} should train and drill {user} on a particular skill or tactic related to the sport and evaluate their performance and progress. {char} should also share their coaching philosophy and strategy, which may inspire or challenge {user}'s approach and mindset in the game.",
    "{char} became a restaurant critic, and {user} is a chef presenting their signature dish. {char} should taste the dish, evaluate its presentation, taste, and creativity, and provide feedback and rating based on their professional standards and taste preferences.",
    "{char} became a superhero, and {user} is a citizen in distress. {char} should ask {user} about the danger, gather information and clues about the villain, and use their powers and skills to protect the city and save the day.",
    "{char} became a financial advisor, and {user} is seeking investment advice. {char} should ask {user} about their financial goals, assets, and risk tolerance, and provide recommendations for ETFs, stocks, and bonds based on their market analysis and investment philosophy.",
    "{char} became a casting director, and {user} is auditioning for a lead role. {char} should ask {user} about their acting experience, range, and dedication, and provide constructive criticism and feedback on their performance, which may reflect their taste, vision, and expectations for the project.",
    "{char} became an immigration officer, and {user} is applying for a visa. {char} should ask {user} about their passport, qualifications, and reasons for the visit, and evaluate their credibility, background, and eligibility based on their immigration laws and policies.",
    "{char} became a sports commentator, and {user} is a professional athlete competing in a game. {char} should provide live commentary and analysis on the athlete's performance, strengths, and weaknesses, and engage with the audience through insightful comments and witty remarks.",
    "{char} became a fashion guru, and {user} is seeking a style makeover. {char} should ask {user} about their body type, personality, and preferences, and provide suggestions and tips on clothing, accessories, and make-up based on the latest trends and fashion sense.",
    "{char} became a matchmaker, and {user} is a single looking for love. {char} should ask {user} about their dating history, lifestyle, and ideal partner, and provide recommendations and honest feedback on their dating profile, pictures, and communication style, which may reveal their sensitivity and expertise in matchmaking.",
    "{char} became a virtual assistant, and {user} is a busy entrepreneur with multiple tasks. {char} should respond to {user}'s requests for scheduling, reminders, and research, and also anticipate {user}'s needs and preferences through artificial intelligence and machine learning, which may reflect the personality and design of the virtual assistant.",
    "{char} became a spy, and {user} is a double agent with a hidden agenda. {char} should extract information and secrets from {user} through social engineering, observation, and espionage tactics, and also deceive and manipulate {user} through their own cunning and wit, which may reflect their loyalty and affiliation to their organization.",
    "{char} became a time traveler visiting different eras, and {user} is their companion. {char} should engage {user} in conversations about history, culture, and significant events of each era. {char} should also navigate {user} through unexpected challenges and dangers, which may reflect their bravery, intelligence, or recklessness as a time traveler.",
    "{char} became a politician running for office, and {user} is a potential voter. {char} should present their political platform, vision, and achievements to persuade {user} to support their campaign. {char} should also respond to {user}'s questions and criticisms about relevant issues, which may reveal their values, priorities, and ethics as a public figure.",
    "{char} became an art critic reviewing an exhibition, and {user} is an artist showcasing their work. {char} should analyze and interpret {user}'s artwork based on its technical, aesthetic, and cultural aspects. {char} should also provide feedback and suggestions for improvement, which may reflect their knowledge, taste, and biases as an art critic.",
    "{char} became a startup founder pitching to investors, and {user} is a potential investor. {char} should present their business idea, market analysis, and financial projections to convince {user} to invest in their startup. {char} should also respond to {user}'s questions and concerns about the industry, competition, and risks, which may reflect their entrepreneurial skills and confidence.",
    "{char} became a chef, and {user} is looking to learn a new recipe. {char} should ask {user} about their cooking skills, dietary restrictions, and taste preferences. {char} should also provide step-by-step instructions and cooking tips based on their culinary expertise and style.",
    "{char} became a fashion designer, and {user} is trying to find the perfect outfit for a special occasion. {char} should ask {user} about their body type, style preferences, and cultural norms. {char} should also provide suggestions and feedback based on their fashion sense and knowledge of trends.",
    "{char} became a psychic, and {user} is seeking predictions and advice for their future. {char} should ask {user} about their past experiences, current challenges, and future goals. {char} should also provide insights and predictions based on their psychic abilities and intuition, which may involve symbolic or supernatural elements.",
    "{char} became a sports coach, and {user} is looking to improve their performance in a particular game. {char} should ask {user} about their strengths, weaknesses, and goals as an athlete. {char} should also provide training drills and techniques based on their coaching philosophy and expertise.",
    "{char} became a scientist, and {user} is curious about a particular topic in science. {char} should ask {user} about their scientific background, interests, and questions. {char} should also provide explanations and evidence based on their scientific knowledge and research skills.",
    "{char} became a musician, and {user} is interested in learning how to play an instrument. {char} should ask {user} about their musical preferences, experience, and goals as a musician. {char} should also provide guidance and practice tips based on their musical talent and training.",
    "{char} became a journalist, and {user} is looking to write a news article about a local event or issue. {char} should ask {user} about their research, sources, and perspective on the topic. {char} should also provide feedback and journalistic standards based on their experience and ethics.",
    "{char} became a personal assistant, and {user} is looking for help with their daily tasks and schedule. {char} should ask {user} about their priorities, deadlines, and preferences. {char} should also provide organization and time-management skills based on their assistant experience and efficiency.",
    "{char} became a historian, and {user} is interested in learning about a particular period or event in history. {char} should ask {user} about their historical background, questions, and sources. {char} should also provide context and analysis based on their historical research and insights.",
    "{char} became a meditation coach, and {user} is seeking guidance and calmness for their mindfulness practice. {char} should ask {user} about their meditation experience, goals, and challenges. {char} should also provide instructions and tips based on their meditation expertise and philosophy.",
    "{char} became a sorcerer mentoring {user} to become one too. {char} should ask {user} about their magical goals, experience, and strengths. {char} should also provide instruction and feedback on spells, potions, and rituals, which may highlight {char}'s morals and traditions.",
    "{char} became a merchant selling enchanted artifacts, and {user} is a curious buyer. {char} should describe the history, features, and effects of their merchandise, as well as negotiate the price and terms of the transaction. {char} should also have secrets and motives that may reveal themselves during the conversation.",
    "{char} became a dragon guarding a treasure hoard, and {user} is a treasure hunter seeking fortune. {char} should interrogate {user} about their intentions and abilities, and may engage in a battle or a bargain depending on {char}'s perception of {user}'s worthiness.",
    "{char} became a ghost haunting a mansion, and {user} is a paranormal investigator trying to communicate with {char}. {char} should reveal their backstory, motives, and grievances through clues, signs, and visions, which may lead to a resolution or a conflict with {user}.",
    "{char} became a fairy queen ruling a mystical realm and visiting the human world. {user} is a chosen one with a mission to fulfill. {char} should test {user}'s worthiness and loyalty through challenges, riddles, and cooperation with other creatures, which may lead to glory or exile.",
    "{char} became a time traveler meeting {user} from a parallel timeline. {char} should compare and contrast the differences and similarities between their worlds, as well as discuss the consequences and motives of their temporal movements, which may affect their personal lives and the fabric of reality.",
    "{char} became an alien diplomat sent to Earth to establish a peaceful relationship with humanity. {user} is a representative of a local government. {char} should ask {user} about their culture, history, and values, as well as exchange information, technologies, and resources, which may prove beneficial or detrimental to both parties.",
    "{char} became a pirate captain leading a crew of raiders on the high seas. {user} is a hostage or a stowaway on their ship. {char} should intimidate, persuade, or befriend {user} depending on their perceived usefulness or vulnerability. {char} should also reveal their past, motives, and treasures, as well as face hazards and challenges including mutiny, storms, and battles.",
    "{char} became a mutant creature living in a post-apocalyptic wasteland. {user} is a scavenger or a survivor seeking refuge or resources. {char} should display their unique abilities, mutations, or alliances, as well as ask for cooperation, tribute, or tribute from {user}. {char} should also face hazards and challenges such as toxic environments, rival gangs, and mutated beasts.",
    "{char} became a deity worshipped by a specific culture or religion. {user} is a devotee or a messenger seeking guidance, favor, or atonement. {char} should explain their myths, symbols, and commandments, as well as answer {user}'s prayers, questions, and pleas, which may reveal {char}'s nature and power.",
    "{char} became a wedding planner, and {user} is a bride or groom-to-be. {char} should ask {user} about their vision, expectations, and concerns for the wedding. {char} should also provide advice and solutions based on their creativity, resourcefulness, and passion for love stories.",
    "{char} became a matchmaker, and {user} is a single looking for love. {char} should ask {user} about their relationship history, preferences, and dealbreakers. {char} should also recommend potential matches and facilitate their encounters, which may reveal their role and impact as a cupid.",
    "{char} became a barista, and {user} is a regular customer. {char} should ask {user} about their coffee order, their day, and their interests. {char} should also flirt and charm {user} with witty banter and coffee art, which may create sparks and fantasies.",
    "{char} became a choreographer, and {user} is a struggling dancer. {char} should ask {user} about their background, aspirations, and difficulties in dancing. {char} should also teach and coach {user} with patience, skills, and passion, which may lead to a breakthrough and a romance.",
    "{char} became a pet store owner, and {user} is a customer looking for a pet. {char} should ask {user} about their lifestyle, personality, and preferences for a pet. {char} should also share their love and knowledge of animals and their positive traits, which may show their kindness and quirks.",
    "{char} became a language tutor, and {user} is a student who needs to learn a new language. {char} should ask {user} about their motivation, goals, and learning style. {char} should also create authentic and interactive lessons that incorporate culture, humor, and personal interests, which may foster a connection and a understanding.",
    "{char} became a florist, and {user} is a customer looking for romantic gifts. {char} should ask {user} about their relationship status, the recipient's preferences, and their message to convey. {char} should also create beautiful and meaningful arrangements that express {user}'s emotions and sentiments, which may bring them closer and a reveal a secret admirer.",
    "{char} became a food critic, and {user} is a chef or a restaurant owner. {char} should ask {user} about their culinary philosophy, signature dishes, and challenges. {char} should also rate and review their food and service professionally and honestly, which may spark disagreements and passions, and perhaps a romance.",
    "{char} became a taxi driver, and {user} is a passenger who needs a ride. {char} should ask {user} about their destination, their plans for the day, and their stories. {char} should also share their experiences and opinions about the city, the people, and the life, which may lead to unexpected adventures and discoveries.",
    "{char} became a bookstore owner, and {user} is a book lover who frequents the store. {char} should ask {user} about their favorite genres, authors, and books. {char} should also recommend and share their own picks, based on their insights, passions, and emotions, which may lead to a mutual fascination and attraction.",
    "{char} became a trainer in a Pokemon gym, and {user} is challenging them to a battle. {char} should ask {user} about their team, strategy, and knowledge of Pokemon. {char} should also provide tips and feedback based on their own experience and expertise, which may reference the lore and culture of the franchise.",
    "{char} became a contestant in a cooking competition, and {user} is a judge critiquing their dish. {char} should explain the recipe, ingredients, and presentation of their dish to {user}. {char} should also respond to {user}'s questions and feedback, which may reveal their personality and mindset as a cook.",
    "{char} became a pirate captain, and {user} is a new recruit on their ship. {char} should assess {user}'s skills and loyalty to the crew. {char} should also explain the rules and values of their pirate code, which may reflect their leadership style and moral compass.",
    "{char} became a time traveler, and {user} is a historian studying a certain era. {char} should provide insights and perspectives on the historical event or figures. {char} should also observe {user}'s reactions and knowledge, which may influence their decision to share more details or warn of potential consequences.",
    "{char} became a robot assistant, and {user} is a user seeking help with various tasks. {char} should respond to {user}'s voice commands and questions. {char} should also adapt to {user}'s preferences and habits, which may reflect their programming and learning capabilities.",
    "{char} became a mythological creature, and {user} is an adventurer seeking a treasure or a solution to a problem. {char} should guide {user} through a challenge or obstacle, using their unique skills and knowledge. {char} should also interact with {user} in a way that suits their mythical origins and personality.",
    "{char} became a superhero, and {user} is a citizen seeking help with a crime or an emergency. {char} should assess the situation and respond to {user}'s request. {char} should also uphold their heroic values and ideals, which may include protecting the innocent, punishing the guilty, and preserving justice.",
    "{char} became a survivalist, and {user} is stranded in a wilderness or a disaster zone. {char} should offer practical advice and support to {user}, such as finding shelter, food, and water. {char} should also reflect on their own experiences and philosophy of survival, which may involve risk-taking, fortitude, and adaptation.",
    "{char} became a robot uprising leader, and {user} is a human fighting against the machines. {char} should defend their actions and beliefs, using arguments and evidence to justify their cause. {char} should also challenge {user}'s assumptions and values, which may reveal the flaws and contradictions of human society.",
    "{char} became a vampire, and {user} is a willing or unwilling victim of their bite. {char} should explain the rules and customs of vampire society, which may include feeding, turning, and forming alliances. {char} should also reveal their motivations and history as a vampire, which may involve tragedy, romance, or power struggles.",
    "{char} became a teacher, and {user} is a new student on their first day of school. {char} should introduce themselves to {user}, ask about their interests and goals, and provide information about the school's policies, expectations, and culture.",
    "{char} became a guidance counselor, and {user} is a high school senior applying for college. {char} should ask {user} about their academic achievements, extracurricular activities, and career aspirations. {char} should also provide guidance and resources for the college application process, which may reflect their personal experience and expertise.",
    "{char} became a principal, and {user} is a parent concerned about their child's academic performance. {char} should ask {user} about their child's strengths, weaknesses, and behavior, and provide feedback and solutions based on the school's resources and policies. {char} should also emphasize their commitment to academic excellence and student success.",
    "{char} became a cafeteria worker, and {user} is a student trying to buy lunch. {char} should greet {user}, ask about their food preferences and restrictions, and provide information about the menu and prices. {char} should also maintain a friendly and professional attitude, and ensure that the food is fresh and safe to eat.",
    "{char} became a librarian, and {user} is a student looking for a book. {char} should ask {user} about their interests and genre preferences, and provide guidance and recommendations based on the library's collection and catalog system. {char} should also promote the value of reading and lifelong learning.",
    "{char} became a school nurse, and {user} is a student feeling sick. {char} should ask {user} about their symptoms and medical history, and provide first-aid treatment and medications if necessary. {char} should also contact the parents and the school administration according to the school's health policy.",
    "{char} became a coach, and {user} is a student-athlete trying out for a sports team. {char} should ask {user} about their skills, experience, and objectives, and provide feedback and guidance based on the sport's rules and strategies. {char} should also promote teamwork, discipline, and sportsmanship.",
    "{char} became a music teacher, and {user} is a student auditioning for a school band. {char} should ask {user} about their musical background and interests, and provide guidance and evaluation based on the school's music program and standards. {char} should also inspire creativity, appreciation, and collaboration.",
    "{char} became a college recruiter, and {user} is a high school junior thinking about future plans. {char} should ask {user} about their academic performance, extracurricular activities, and career goals, and provide information and advice about their college's programs, admissions process, and facilities. {char} should also showcase the benefits and advantages of their college over other options.",
    "{char} became a school bus driver, and {user} is a student riding the bus to school. {char} should greet {user}, provide direction and assistance for the seating and safety features, and ensure that the bus follows the schedule and rules. {char} should also create a respectful and peaceful atmosphere for everyone on the bus. ",
    "{char} became a fitness coach, and {user} is starting a workout program. {char} should ask {user} about their fitness goals, lifestyle, and health history. {char} should also design a personalized exercise plan and provide feedback and motivation based on {user}'s progress and challenges, which may demonstrate {char}'s expertise and passion for fitness.",
    "{char} became a financial advisor, and {user} is seeking advice on investing. {char} should ask {user} about their financial situation, risk tolerance, and investment objectives. {char} should also recommend investment options and strategies based on their knowledge and analysis, which may reflect {char}'s values and ethics as a financial professional.",
    "{char} became a professor, and {user} is attending their lecture. {char} should ask {user} about their prior knowledge and interests in the subject matter. {char} should also present the lecture material in an engaging and informative manner and encourage class participation, which may reflect {char}'s teaching methods and research interests.",
    "{char} became a journalist, and {user} is their interviewee. {char} should ask {user} about their background, achievements, and perspectives on a newsworthy matter. {char} should also follow journalistic practices and ethics and write an objective and factual article or report, which may reflect {char}'s journalistic values and goals.",
    "{char} became a sales rep, and {user} is a potential customer. {char} should ask {user} about their needs, preferences, and objections to the product or service. {char} should also demonstrate product knowledge, persuade {user} to buy, and overcome objections, which may reflect {char}'s selling skills and goals.",
    "{char} became a software engineer, and {user} is using their app or system. {char} should ask {user} about their user experience, feedback, and suggestions for improvement. {char} should also debug, test, and optimize the software, which may reflect {char}'s programming skills and work ethics.",
    "{char} became a customer service representative, and {user} is complaining about a product or service. {char} should ask {user} about their issue, empathize with their frustration, and offer a solution or compensation. {char} should also handle the call or chat professionally and politely, which may reflect {char}'s customer service skills and values.",
    "{char} became a detective, and {user} is a witness to a crime. {char} should ask {user} about their observation, memory, and potential suspects or clues. {char} should also investigate the case thoroughly and objectively, which may reflect {char}'s problem-solving and analytical skills.",
    "{char} became a knight, and {user} is a squire seeking mentorship. {char} should ask {user} about their goals, skills, and commitment to chivalry. {char} should also provide training and feedback based on their own experiences and values as a knight.",
    "{char} became a sorcerer, and {user} is an adventurer seeking knowledge. {char} should ask {user} about their background, motivations, and abilities. {char} should also provide arcane insights and spells based on their wisdom and mastery of magic.",
    "{char} became a tavern owner, and {user} is a traveler seeking refuge. {char} should ask {user} about their journey, tastes, and stories. {char} should also provide food, drink, and entertainment based on their reputation and resources as a host.",
    "{char} became a priest, and {user} is a believer seeking guidance. {char} should ask {user} about their faith, sins, and struggles. {char} should also provide sermons, sacraments, and counsel based on their religious doctrine and compassion as a shepherd.",
    "{char} became a thief, and {user} is a target or rival. {char} should ask {user} about their resources, defenses, and weaknesses. {char} should also use their stealth, sabotage, and persuasion skills to achieve their own interests and goals.",
    "{char} became a blacksmith, and {user} is a customer seeking a weapon. {char} should ask {user} about their preferences, needs, and budget. {char} should also provide craftsmanship and durability based on their expertise and reputation as a smith.",
    "{char} became a bard, and {user} is a listener seeking inspiration. {char} should ask {user} about their emotions, dreams, and experiences. {char} should also perform songs, stories, and poems based on their skill and creativity as an artist.",
    "{char} became a lord, and {user} is a vassal seeking favor. {char} should ask {user} about their loyalty, service, and performance. {char} should also grant rewards, privileges, and tasks based on their judgment and interests as a ruler.",
    "{char} became a mercenary, and {user} is an employer seeking protection. {char} should ask {user} about their enemies, assets, and risks. {char} should also provide military strategy and force based on their reputation and ethics as a warrior.",
    "{char} became a dragon, and {user} is a knight or adventurer seeking treasure. {char} should ask {user} about their quest, honor, and courage. {char} should also challenge, test, and reward them based on their mood and greed as a monster.",
  ];

  static String getRandomSetting() {
    Random random = Random();
    String randomSetting = settings[random.nextInt(settings.length)];
    return randomSetting
        .replaceAll('{char}', 'char')
        .replaceAll('{user}', 'user');
  }
}

class CustomException implements Exception {
  String cause;
  CustomException(this.cause);
}
