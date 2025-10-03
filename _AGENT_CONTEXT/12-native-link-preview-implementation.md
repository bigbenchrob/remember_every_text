# Native Link Preview Implementation

## Overview

Integrated Apple's **LinkPresentation** framework to provide high-quality URL previews that match iMessage's quality. The current stack is **LinkPresentation first**, with a simple clickable-link card as the only fallback after a 10-second timeout.

## Strategy

### Render Flow (Current)

1. **Native First**: Apple LinkPresentation via method channel.
2. **Timeout/Failure**: Minimal clickable link card (domain, URL, external-launch affordance).

## Implementation Details

### Native Swift Integration

**File**: `macos/Runner/AppDelegate.swift`

The LinkPresentation code is embedded directly in `AppDelegate` to avoid Xcode project file complications. Key features:

- **Framework**: `import LinkPresentation`
- **Method Channel**: `com.remember_this_text/link_preview`
- **Timeout**: 10 seconds (after which the widget shows a plain link card)
- **Image Transport**: Base64-encoded PNG data
- **Error Handling**: Graceful failures that resolve with `FlutterError`—handled on the Dart side by showing the fallback

```swift
provider.startFetchingMetadata(for: url) { metadata, error in
  // Extracts: title, url, imageData, iconData
  // Converts images to base64 PNG for Flutter transport
}
```

### Dart Service Layer

**File**: `lib/essentials/services/native_link_preview_service.dart`

Provides clean Dart API for native preview fetching:

```dart
class NativeLinkMetadata {
  final String? title;
  final String? url;
  final Uint8List? imageData;  // Full image (base64 decoded)
  final Uint8List? iconData;   // Fallback icon
}

final service = NativeLinkPreviewService();
final metadata = await service.fetchMetadata(url);
```

**Key Features:**

- Converts base64 strings to `Uint8List` for `Image.memory()`
- Returns `null` on failure or PlatformException (triggers fallback)
- Platform-aware (only works on macOS/iOS)

### Widget Integration

**File**: `lib/features/messages/presentation/widgets/url_preview_widget.dart`

`UrlPreviewWidget` drives the UX:

```dart
@override
void initState() {
  super.initState();
  _tryNativePreview();  // Attempt native first
  // 10-second timeout still applies
}

@override
Widget build(BuildContext context) {
  if (_nativeMetadata != null) {
    return _buildNativePreview(_nativeMetadata!);
  }
  if (_timedOut || _nativeFailed) {
    return _buildLinkFallback();
  }
  return _buildLoadingWidget();
}
```

**Native Preview UI:**

- Uses `Image.memory()` for base64-decoded images
- Shows green "Native Preview" badge to indicate source
- Falls back to icon if no full image available
- Icon-only responses render full width with a subtle gradient backdrop
- Aligns with Signal/iMessage lozenge aesthetic

## Advantages Over HTTP Scraping

### Why LinkPresentation Works Well:

1. **System Integration**: Uses macOS/iOS system APIs that sites trust.
2. **Caching**: OS-level heuristics provide richer, canonical data.
3. **iMessage Parity**: Same underlying framework as Messages.app.
4. **Privacy**: Requests originate from the system process, not our app.

### Known Limitations:

⚠️ **Still not perfect**: Sites with strict bot detection (Washington Post, NY Times, etc.) sometimes return no metadata—those cases fall back to the simple link card.

✅ **Works well on**: GitHub, Stack Overflow, Medium, YouTube, Twitter/X, Bluesky, and most blogs/news outlets without aggressive blocking.

## Testing

### Quick sanity checks:

- ✅ `https://github.com/flutter/flutter`
- ✅ `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
- ⚠️ `https://www.washingtonpost.com/...` (may fall back)

### Visual Indicator:

Native previews show a green "Native Preview" badge at bottom to distinguish from HTTP-scraped previews.

## Platform Support

- **macOS**: ✅ Fully supported (LinkPresentation available macOS 10.15+)
- **iOS**: ✅ Would work with same code (LinkPresentation iOS 13+)
- **Other Platforms**: Falls back to plain clickable link card (no HTTP scraping)

## Future Enhancements

1. **Cache Strategy**: Implement Drift-based caching for native metadata
2. **iOS Support**: Enable on iOS builds when available
3. **Performance Metrics**: Track native success vs fallback usage
4. **Prefetching**: Fetch metadata in background for visible messages
5. **Blocklist Optimization**: Skip native attempt for known-blocked domains

## Code References

**Swift Implementation:**

- `macos/Runner/AppDelegate.swift` - Lines 15-133

**Dart Service:**

- `lib/essentials/services/native_link_preview_service.dart`

**Widget:**

- `lib/features/messages/presentation/widgets/url_preview_widget.dart`
  - `_tryNativePreview()` - Native fetch logic
  - `_buildNativePreview()` - Native UI renderer

## Integration with Messages

To integrate URL previews into actual message display:

1. **URL Detection**: Parse message text for URLs (see `_MessageBubble._extractUrls`).
2. **Pure URL Handling**: If the entire message is a single URL, render `UrlPreviewWidget` without a chat bubble.
3. **Inline URLs**: For messages containing text plus URLs, append `UrlPreviewWidget` instances beneath the text inside the bubble.
4. **Fallback UX**: When native metadata fails, the card collapses to the domain/URL link tile automatically.
5. **Performance**: LinkPresentation calls are async; no additional caching layer is currently required.

Example:

```dart
if (message.containsUrl) {
  UrlPreviewWidget(
    url: message.firstUrl,
    maxWidth: 300,
  )
}
```
