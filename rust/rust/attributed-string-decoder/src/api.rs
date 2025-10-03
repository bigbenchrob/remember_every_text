use flutter_rust_bridge::frb; // attribute macros

/// Synchronous wrapper for typedstream decoding
/// Note: This is a placeholder - actual implementation uses standalone binary
#[frb(sync)]
pub fn decode_typedstream_blob(blob: Vec<u8>) -> Result<String, String> {
    // Placeholder implementation
    // The actual work is done by the extract_messages_limited binary
    Err("Use extract_messages_limited binary instead".to_string())
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
    
    let plist: Value = plist::from_file(&file_path)
        .map_err(|e| format!("Failed to parse plist: {}", e))?;
    
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
