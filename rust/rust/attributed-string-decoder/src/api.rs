use crabstep::TypedStreamDeserializer;
use flutter_rust_bridge::frb; // attribute macros

/// Synchronous wrapper for typedstream decoding
#[frb(sync)]
pub fn decode_typedstream_blob(blob: Vec<u8>) -> Result<String, String> {
    let mut typedstream = TypedStreamDeserializer::new(&blob);
    let root = typedstream
        .oxidize()
        .map_err(|error| format!("Failed to parse typedstream: {error}"))?;
    let root_object = typedstream
        .resolve_properties(root)
        .map_err(|error| format!("Failed to resolve typedstream: {error}"))?;

    for primitive in root_object.primitives() {
        if let Some(value) = primitive.as_str() {
            if is_message_text_candidate(value) {
                return Ok(value.to_string());
            }
        }
    }

    Err("No message text found in attributed body blob".to_string())
}

fn is_message_text_candidate(value: &str) -> bool {
    let trimmed = value.trim();
    !trimmed.is_empty() && !trimmed.starts_with("__") && !trimmed.starts_with("NS")
}

/// Rich metadata extracted from URL preview plists
#[frb]
pub struct UrlPreviewMetadata {
    pub title: Option<String>,
    pub summary: Option<String>,
    pub site_name: Option<String>,
    pub image_url: Option<String>,
    pub video_url: Option<String>,
    pub icon_url: Option<String>,
    pub url: Option<String>,
}

/// Parse a binary plist file (typically .pluginpayloadattachment)
/// and extract rich link preview metadata
#[frb(sync)]
pub fn parse_url_preview_plist(file_path: String) -> Result<UrlPreviewMetadata, String> {
    use plist::Value;

    let plist: Value =
        plist::from_file(&file_path).map_err(|e| format!("Failed to parse plist: {}", e))?;

    let mut metadata = UrlPreviewMetadata {
        title: None,
        summary: None,
        site_name: None,
        image_url: None,
        video_url: None,
        icon_url: None,
        url: None,
    };

    // Navigate the plist structure to extract metadata
    if let Value::Dictionary(root) = plist {
        // Try to find rich link metadata
        if let Some(Value::Dictionary(rich_link)) = root.get("richLinkMetadata") {
            extract_from_rich_link(rich_link, &mut metadata);
        }

        // Fallback: check top-level keys
        if let Some(Value::String(title)) = root.get("title") {
            metadata.title = Some(title.clone());
        }
        if let Some(Value::String(summary)) = root.get("summary") {
            metadata.summary = Some(summary.clone());
        }
        if let Some(Value::String(url)) = root.get("URL") {
            metadata.url = Some(url.clone());
        }
        if let Some(Value::String(url)) = root.get("url") {
            metadata.url = Some(url.clone());
        }
    }

    Ok(metadata)
}

fn extract_from_rich_link(dict: &plist::Dictionary, metadata: &mut UrlPreviewMetadata) {
    use plist::Value;

    // Extract title
    if let Some(Value::String(title)) = dict.get("title") {
        metadata.title = Some(title.clone());
    }

    // Extract summary/description
    if let Some(Value::String(summary)) = dict.get("summary") {
        metadata.summary = Some(summary.clone());
    }

    // Extract site name
    if let Some(Value::String(site)) = dict.get("siteName") {
        metadata.site_name = Some(site.clone());
    }

    // Extract URL
    if let Some(Value::String(url)) = dict.get("URL") {
        metadata.url = Some(url.clone());
    }
    if let Some(Value::String(url)) = dict.get("url") {
        metadata.url = Some(url.clone());
    }

    // Extract image URL
    if let Some(Value::Dictionary(image_dict)) = dict.get("image") {
        if let Some(Value::String(img_url)) = image_dict.get("URL") {
            metadata.image_url = Some(img_url.clone());
        }
        if let Some(Value::String(img_url)) = image_dict.get("url") {
            metadata.image_url = Some(img_url.clone());
        }
    }

    // Extract icon URL
    if let Some(Value::Dictionary(icon_dict)) = dict.get("icon") {
        if let Some(Value::String(icon_url)) = icon_dict.get("URL") {
            metadata.icon_url = Some(icon_url.clone());
        }
        if let Some(Value::String(icon_url)) = icon_dict.get("url") {
            metadata.icon_url = Some(icon_url.clone());
        }
    }

    // Extract video URL
    if let Some(Value::Dictionary(video_dict)) = dict.get("video") {
        if let Some(Value::String(vid_url)) = video_dict.get("URL") {
            metadata.video_url = Some(vid_url.clone());
        }
        if let Some(Value::String(vid_url)) = video_dict.get("url") {
            metadata.video_url = Some(vid_url.clone());
        }
    }
}

#[cfg(test)]
mod tests {
    use super::decode_typedstream_blob;

    #[test]
    fn decodes_message_text_from_attributed_body_blob() {
        let blob = decode_hex(
            "040B73747265616D747970656481E803840140848484124E534174747269\
             6275746564537472696E67008484084E534F626A65637400859284848408\
             4E53537472696E67019484012B045445535486840269490104928484840C\
             4E5344696374696F6E617279009484016901928496961D5F5F6B494D4D65\
             7373616765506172744174747269627574654E616D658692848484084E53\
             4E756D626572008484074E5356616C7565009484012A84999900868686",
        );

        let decoded = decode_typedstream_blob(blob).unwrap();

        assert_eq!(decoded, "TEST");
    }

    fn decode_hex(input: &str) -> Vec<u8> {
        let compact: String = input.chars().filter(|c| !c.is_whitespace()).collect();
        compact
            .as_bytes()
            .chunks_exact(2)
            .map(|chunk| {
                let pair = std::str::from_utf8(chunk).unwrap();
                u8::from_str_radix(pair, 16).unwrap()
            })
            .collect()
    }
}
