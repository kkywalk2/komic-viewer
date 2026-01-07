int naturalCompare(String a, String b) {
  final regex = RegExp(r'(\d+)|(\D+)');
  final partsA = regex.allMatches(a).map((m) => m.group(0)!).toList();
  final partsB = regex.allMatches(b).map((m) => m.group(0)!).toList();

  for (var i = 0; i < partsA.length && i < partsB.length; i++) {
    final partA = partsA[i];
    final partB = partsB[i];

    final numA = int.tryParse(partA);
    final numB = int.tryParse(partB);

    int cmp;
    if (numA != null && numB != null) {
      cmp = numA.compareTo(numB);
    } else {
      cmp = partA.toLowerCase().compareTo(partB.toLowerCase());
    }

    if (cmp != 0) return cmp;
  }

  return partsA.length.compareTo(partsB.length);
}

extension NaturalSort<T> on List<T> {
  void sortNatural(String Function(T) keyExtractor) {
    sort((a, b) => naturalCompare(keyExtractor(a), keyExtractor(b)));
  }
}
