use flutter_rust_bridge::frb; // attribute macros
use crate::extract_text_from_typedstream_blob;

/// Synchronous wrapper; FRB can still expose it as a Future on Dart side if you prefer.
#[frb(sync)] // mark as sync; remove if you want it generated as async
pub fn decode_typedstream_blob(blob: Vec<u8>) -> Result<String, String> {
    match extract_text_from_typedstream_blob(&blob) {
        Ok(s) => Ok(s),
        Err(e) => Err(e.to_string()),
    }
}
