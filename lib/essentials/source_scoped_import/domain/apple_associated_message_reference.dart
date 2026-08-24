/// Returns the source message GUID carried by an Apple Messages associated
/// message reference.
///
/// Apple stores ordinary references as the raw GUID, part references as
/// `p:<part>/<GUID>`, and balloon/plugin references as `bp:<GUID>`. Malformed
/// or unknown forms remain unchanged so source evidence is never invented.
String appleAssociatedMessageTargetGuid(String reference) {
  if (reference.startsWith('bp:') && reference.length > 3) {
    return reference.substring(3);
  }

  if (reference.startsWith('p:')) {
    final separatorIndex = reference.indexOf('/');
    if (separatorIndex >= 0 && separatorIndex + 1 < reference.length) {
      return reference.substring(separatorIndex + 1);
    }
  }

  return reference;
}
