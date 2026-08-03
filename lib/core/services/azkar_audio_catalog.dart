enum AzkarAudioGroup { morning, evening, sleep, postPrayer }

class AzkarAudioCatalog {
  AzkarAudioCatalog._();

  static const morning = <String?>[
    'https://www.hisnmuslim.com/audio/ar/75.mp3',
    'https://server8.mp3quran.net/afs/112.mp3',
    'https://server8.mp3quran.net/afs/113.mp3',
    'https://server8.mp3quran.net/afs/114.mp3',
    'https://www.hisnmuslim.com/audio/ar/77.mp3',
    'https://www.hisnmuslim.com/audio/ar/79.mp3',
    'https://www.hisnmuslim.com/audio/ar/87.mp3',
    'https://www.hisnmuslim.com/audio/ar/80.mp3',
    'https://www.hisnmuslim.com/audio/ar/81.mp3',
    'https://www.hisnmuslim.com/audio/ar/83.mp3',
    'https://www.hisnmuslim.com/audio/ar/86.mp3',
    'https://www.hisnmuslim.com/audio/ar/78.mp3',
    'https://www.hisnmuslim.com/audio/ar/90.mp3',
    'https://www.hisnmuslim.com/audio/ar/94.mp3',
    'https://www.hisnmuslim.com/audio/ar/82.mp3',
    'https://www.hisnmuslim.com/audio/ar/82.mp3',
    'https://www.hisnmuslim.com/audio/ar/84.mp3',
    'https://www.hisnmuslim.com/audio/ar/88.mp3',
    'https://www.hisnmuslim.com/audio/ar/89.mp3',
    'https://www.hisnmuslim.com/audio/ar/85.mp3',
    'https://www.hisnmuslim.com/audio/ar/97.mp3',
    'https://www.hisnmuslim.com/audio/ar/98.mp3',
    null,
    null,
    null,
    null,
    'https://www.hisnmuslim.com/audio/ar/95.mp3',
    null,
    'https://www.hisnmuslim.com/audio/ar/93.mp3',
    'https://www.hisnmuslim.com/audio/ar/91.mp3',
    'https://www.hisnmuslim.com/audio/ar/96.mp3',
  ];

  static const evening = <String?>[
    'https://www.hisnmuslim.com/audio/ar/75.mp3',
    'https://www.hisnmuslim.com/audio/ar/101.mp3',
    'https://server8.mp3quran.net/afs/112.mp3',
    'https://server8.mp3quran.net/afs/113.mp3',
    'https://server8.mp3quran.net/afs/114.mp3',
    'https://www.hisnmuslim.com/audio/ar/77.mp3',
    'https://www.hisnmuslim.com/audio/ar/79.mp3',
    'https://www.hisnmuslim.com/audio/ar/87.mp3',
    'https://www.hisnmuslim.com/audio/ar/80.mp3',
    'https://www.hisnmuslim.com/audio/ar/81.mp3',
    'https://www.hisnmuslim.com/audio/ar/83.mp3',
    'https://www.hisnmuslim.com/audio/ar/86.mp3',
    'https://www.hisnmuslim.com/audio/ar/78.mp3',
    'https://www.hisnmuslim.com/audio/ar/90.mp3',
    'https://www.hisnmuslim.com/audio/ar/94.mp3',
    'https://www.hisnmuslim.com/audio/ar/82.mp3',
    'https://www.hisnmuslim.com/audio/ar/82.mp3',
    'https://www.hisnmuslim.com/audio/ar/84.mp3',
    'https://www.hisnmuslim.com/audio/ar/88.mp3',
    'https://www.hisnmuslim.com/audio/ar/89.mp3',
    'https://www.hisnmuslim.com/audio/ar/85.mp3',
    'https://www.hisnmuslim.com/audio/ar/97.mp3',
    'https://www.hisnmuslim.com/audio/ar/98.mp3',
    null,
    null,
    null,
    'https://www.hisnmuslim.com/audio/ar/95.mp3',
    'https://www.hisnmuslim.com/audio/ar/93.mp3',
    'https://www.hisnmuslim.com/audio/ar/91.mp3',
  ];

  static const sleep = <String?>[
    'https://www.hisnmuslim.com/audio/ar/102.mp3',
    'https://www.hisnmuslim.com/audio/ar/103.mp3',
    'https://www.hisnmuslim.com/audio/ar/104.mp3',
    'https://www.hisnmuslim.com/audio/ar/105.mp3',
    null,
    null,
    null,
  ];

  static const postPrayer = <String?>[
    'https://www.hisnmuslim.com/audio/ar/66.mp3',
    'https://www.hisnmuslim.com/audio/ar/67.mp3',
    'https://www.hisnmuslim.com/audio/ar/68.mp3',
    null,
    null,
    null,
    null,
    'https://www.hisnmuslim.com/audio/ar/71.mp3',
  ];

  static List<String?> forGroup(AzkarAudioGroup group) => switch (group) {
    AzkarAudioGroup.morning => morning,
    AzkarAudioGroup.evening => evening,
    AzkarAudioGroup.sleep => sleep,
    AzkarAudioGroup.postPrayer => postPrayer,
  };

  static List<String> available(AzkarAudioGroup group) =>
      forGroup(group).whereType<String>().toSet().toList();
}
