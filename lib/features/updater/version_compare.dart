/// Compares release versions of the form `1.0.0` or `1.0.0-rc3`.
///
/// A version without an `-rcN` suffix is a final release and counts as newer
/// than any release candidate with the same base version. Unparseable input
/// is treated as "not newer" so a malformed tag can never cause an update
/// prompt loop.
bool isNewerVersion({required String current, required String latest}) {
  final currentParsed = _parse(current);
  final latestParsed = _parse(latest);
  if (currentParsed == null || latestParsed == null) {
    return false;
  }

  for (var i = 0; i < 3; i++) {
    if (latestParsed.base[i] != currentParsed.base[i]) {
      return latestParsed.base[i] > currentParsed.base[i];
    }
  }

  final currentRc = currentParsed.rc;
  final latestRc = latestParsed.rc;
  if (latestRc == null) {
    return currentRc != null;
  }
  if (currentRc == null) {
    return false;
  }
  return latestRc > currentRc;
}

class _ParsedVersion {
  _ParsedVersion(this.base, this.rc);

  final List<int> base;
  final int? rc;
}

_ParsedVersion? _parse(String version) {
  final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:-rc(\d+))?$')
      .firstMatch(version.trim());
  if (match == null) {
    return null;
  }
  final base = [
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  ];
  final rcGroup = match.group(4);
  return _ParsedVersion(base, rcGroup == null ? null : int.parse(rcGroup));
}
