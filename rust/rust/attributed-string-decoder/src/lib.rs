mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */

pub mod api; // so the module path crate::api exists

mod internal; // if you split helpers, optional

use anyhow::{Context, Result};
use crabstep::{PropertyIteratorData, TypedStreamDeserializer};
use plist::Value as PlistValue;
use std::collections::HashSet;


// === public Rust API your app (and FRB wrapper) will call ===
pub fn extract_text_from_typedstream_blob(blob: &[u8]) -> Result<String> {
    let mut d = TypedStreamDeserializer::new(blob);
    let root = d.oxidize().context("TypedStream oxidize failed")?;
    extract_text_from_typedstream_deserializer(&d, root)
}

pub fn extract_text_from_typedstream_deserializer(
    d: &TypedStreamDeserializer,
    root: usize,
) -> Result<String> {
    let mut seen = HashSet::new();
    let mut candidates = Vec::<String>::new();
    collect_strings_from_node(d, root, &mut candidates, &mut seen);

    candidates
        .into_iter()
        .map(clean_extracted_text)
        .filter(|s| is_likely_message_text(s))
        .max_by_key(score_text)
        .ok_or_else(|| anyhow::anyhow!("No plausible user text found"))
}

/* ===================== Traversal & helpers ===================== */

fn collect_strings_from_node(
    d: &TypedStreamDeserializer,
    idx: usize,
    out: &mut Vec<String>,
    seen: &mut HashSet<usize>,
) {
    if !seen.insert(idx) {
        return; // cycle guard
    }

    let Ok(props) = d.resolve_properties(idx) else { return; };

    for p in props {
        match p {
            // Direct string value
            PropertyIteratorData::String(s) => out.push(s.to_string()),

            // Nested object: walk its properties recursively when possible.
            PropertyIteratorData::Object(children) => {
                harvest_strings_from_prop_slice(children, out);
            }

            // Embedded binary; if it’s an NSKeyedArchiver plist, crack it and harvest strings
            PropertyIteratorData::Data(bytes) => {
                if bytes.starts_with(b"bplist00") {
                    out.extend(extract_strings_from_bplist(bytes));
                }
            }

            _ => {}
        }
    }
}

fn harvest_strings_from_prop_slice(children: &[PropertyIteratorData], out: &mut Vec<String>) {
    for c in children {
        match c {
            PropertyIteratorData::String(s) => out.push(s.to_string()),
            PropertyIteratorData::Object(grand) => {
                harvest_strings_from_prop_slice(grand, out);
            }
            PropertyIteratorData::Data(bytes) => {
                if bytes.starts_with(b"bplist00") {
                    out.extend(extract_strings_from_bplist(bytes));
                }
            }
            _ => {}
        }
    }
}

/* ---------------------- embedded bplist support --------------------- */

fn extract_strings_from_bplist(data: &[u8]) -> Vec<String> {
    // Try binary first, fall back to XML (rare)
    let root = PlistValue::from_reader(data).or_else(|_| PlistValue::from_reader_xml(data));
    let Ok(root) = root else { return vec![]; };

    let mut acc = Vec::<String>::new();

    // Sweep entire plist for any strings
    collect_plist_strings(&root, &mut acc);

    // NSKeyedArchiver common path: strings under "$objects"[i]."NS.string"
    if let Some(objects) = root
        .as_dictionary()
        .and_then(|d| d.get("$objects"))
        .and_then(|v| v.as_array())
    {
        for obj in objects {
            if let Some(s) = obj
                .as_dictionary()
                .and_then(|d| d.get("NS.string"))
                .and_then(|v| v.as_string())
            {
                acc.push(s.to_owned());
            }
        }
    }

    acc
}

fn collect_plist_strings(v: &PlistValue, acc: &mut Vec<String>) {
    match v {
        PlistValue::String(s) => acc.push(s.clone()),
        PlistValue::Array(a) => a.iter().for_each(|vv| collect_plist_strings(vv, acc)),
        PlistValue::Dictionary(d) => d.values().for_each(|vv| collect_plist_strings(vv, acc)),
        _ => {}
    }
}

/* ------------------------- heuristics & hygiene --------------------- */

fn is_likely_message_text(s: &str) -> bool {
    // Filter obvious framework noise and metadata
    let lower = s.to_ascii_lowercase();
    if lower.contains("nsattributedstring")
        || lower.contains("nsmutablestring")
        || lower.contains("nsstring")
        || lower.contains("nskeyedarchiver")
        || lower.contains("__kim")
        || lower.starts_with("__k")
    {
        return false;
    }

    let len = s.chars().count();
    let letters = s.chars().filter(|c| c.is_alphabetic()).count();
    letters >= 3 && len >= 3
}

/// Prefer longer, more natural-language-y segments.
fn score_text(s: &str) -> usize {
    let len = s.chars().count();
    let spaces = s.matches(' ').count();
    len * 10 + spaces
}

fn clean_extracted_text(text: String) -> String {
    const ATTACHMENT_CHAR: char = '\u{FFFC}';   // object replacement
    const REPLACEMENT_CHAR: char = '\u{FFFD}';  // replacement char
    const NBSP: char = '\u{00A0}';              // non-breaking space
    const SHY: char = '\u{00AD}';               // soft hyphen

    let mut s = text
        .replace(ATTACHMENT_CHAR, "")
        .replace(REPLACEMENT_CHAR, "")
        .replace(NBSP, " ")
        .replace(SHY, "")
        .replace('\r', "\n");

    while s.contains("\n\n\n") {
        s = s.replace("\n\n\n", "\n\n");
    }

    s.trim().to_string()
}

/* ========================= Optional C ABI ============================
   Enable with `--features ffi` and link against the produced cdylib.

   C signature:
     // Returns 0 on success, non-zero on error.
     // On success, *out_cstr points to a malloc()'d UTF-8 string you must free with imsg_free().
     int imsg_extract_text(const uint8_t* data, size_t len, char** out_cstr);

     void imsg_free(void* ptr);
===================================================================== */

#[cfg(feature = "ffi")]
mod ffi {
    use super::*;
    use libc::{c_char, c_int, c_void};
    use std::{ffi::CString, ptr};

    #[no_mangle]
    pub extern "C" fn imsg_extract_text(
        data: *const u8,
        len: usize,
        out_cstr: *mut *mut c_char,
    ) -> c_int {
        if data.is_null() || out_cstr.is_null() {
            return 1;
        }
        // Safety: we only read `len` bytes
        let slice = unsafe { std::slice::from_raw_parts(data, len) };

        match extract_text_from_typedstream_blob(slice) {
            Ok(s) => match CString::new(s) {
                Ok(cs) => {
                    // Hand ownership to the caller; they must free with imsg_free().
                    unsafe { *out_cstr = cs.into_raw(); }
                    0
                }
                Err(_) => 3, // interior NUL
            },
            Err(_) => 2,
        }
    }

    #[no_mangle]
    pub extern "C" fn imsg_free(ptr: *mut c_void) {
        if ptr.is_null() {
            return;
        }
        unsafe {
            drop(CString::from_raw(ptr as *mut c_char));
        }
    }
}
