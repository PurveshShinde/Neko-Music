void main() {
  final titles = [
    'Khamoshiyan Full Video, Arijit Singh',
    'Khamoshiyan (Title Song) Lyrics | Arijit Singh',
    'Arijit Singh | Jeet Gannguli - Khamoshiyan',
    'Khamoshiyan - Title Track | Khamoshiyan',
    'Baatein Ye Kabhi Na - Full Video | Arijit Singh',
    'Aadat (Juda Hoke Bhi) | Atif Aslam',
    'Khamoshiyan Full Lyric Video - Title Track',
  ];

  final seen = <String>[];
  
  for (var title in titles) {
    String coreTitle = title.toLowerCase().split(RegExp(r'[-|,]')).first.trim();
    coreTitle = coreTitle
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll(RegExp(r'\b(official|video|lyric|lyrics|audio|full|song|track|music)\b'), '')
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
        
    if (coreTitle.isEmpty) {
      coreTitle = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    }
    
    bool isDuplicate = false;
    for (var existing in seen) {
      if (existing.isNotEmpty && coreTitle.isNotEmpty) {
        if (existing.contains(coreTitle) || coreTitle.contains(existing)) {
          isDuplicate = true;
          break;
        }
      }
    }
    
    if (!isDuplicate) {
      seen.add(coreTitle);
      print('ADDED: $title (key: $coreTitle)');
    } else {
      print('DUPLICATE: $title (key: $coreTitle)');
    }
  }
}
