import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  String contents = await File('dinosaur-details.json').readAsString();
  final dinosaurs = json.decode(contents).map((item) => Dinosaur.fromMap(item)).toList();
  List<Dinosaur> withImages = [];
  for (var i = 0; i<dinosaurs.length; i++) {
    Dinosaur dinosaur = await getImage(dinosaurs[i]);
    withImages.add(dinosaur);

    if (i % 20 == 0) {
      print('Completed ${i+1}.  pausing....');
      await Future.delayed(Duration(seconds: 5));
    }
  }
  writeResultsToFile(withImages);
}

Future<String> writeResultsToFile(withImages) async {
  final jsonString = json.encode(withImages.map((d) => d.toMap()).toList());

  try {
    final resultsPath = './results-new.json';
    File file = File(resultsPath);
    await file.writeAsString(jsonString);
    return resultsPath;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<Dinosaur> getImage(Dinosaur dinosaur) async {
  print(dinosaur.link);
  final name = dinosaur.name;
  final imageUrl = await getImageLink(await dinosaur.link);
  final imageName = await downloadImage(imageUrl);
  return dinosaur.copyWith(
    imageUrl: imageUrl,
    imageName: imageName,
  );
}

Future<String> downloadImage(imageUrl) async {
  final name = imageUrl.split('/').last;

  var response = await http.get(Uri.parse(imageUrl));

  try {
    final imagePath = './images/$name';
    File file = File(imagePath);
    await file.writeAsBytesSync(response.bodyBytes);
    return name;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<String> getImageLink(pageLink) async {
  final url = Uri.parse(pageLink);
  final content = await http.read(url);
  //print(content);
  final regex = RegExp(r'.*<img class="dinosaur--image" src="(.*)" alt=".*');
  final match = regex.firstMatch(content);
  final imageUrl = match.group(1);
  return imageUrl;
}

class Dinosaur {
  final String name;
  final String diet;
  final String period;
  final String lived_in;
  final String type;
  final String length;
  final String taxonomy;
  final String named_by;
  final String species;
  final String link;
  final String imageUrl;
  final String imageName;

  Dinosaur({
    this.name,
    this.diet,
    this.period,
    this.lived_in,
    this.type,
    this.length,
    this.taxonomy,
    this.named_by,
    this.species,
    this.link,
    this.imageUrl,
    this.imageName,
  });

  @override
  String toString() {
    return 'Dinosaur(name: $name, link: $link, imageName: $imageName, imageUrl: $imageUrl)';
  }

  Dinosaur copyWith({
    imageUrl,
    imageName,
  }) {
    return Dinosaur(
      name: this.name,
      diet: this.diet,
      period: this.period,
      lived_in: this.lived_in,
      type: this.type,
      length: this.length,
      taxonomy: this.taxonomy,
      named_by: this.named_by,
      species: this.species,
      link: this.link,
      imageUrl: imageUrl,
      imageName: imageName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'diet': this.diet,
      'period': this.period,
      'lived_in': this.lived_in,
      'type': this.type,
      'length': this.length,
      'taxonomy': this.taxonomy,
      'named_by': this.named_by,
      'species': this.species,
      'link': this.link,
      'imageUrl': this.imageUrl,
      'imageName': this.imageName,
    };
  }

  factory Dinosaur.fromMap(Map<String, dynamic> map) {
    return Dinosaur(
      name: map['name'],
      diet: map['diet'],
      period: map['period'],
      lived_in: map['lived_in'],
      type: map['type'],
      length: map['length'],
      taxonomy: map['taxonomy'],
      named_by: map['named_by'],
      species: map['species'],
      link: map['link'],
      imageUrl: map['imageUrl'],
      imageName: map['imageName'],
    );
  }
}
