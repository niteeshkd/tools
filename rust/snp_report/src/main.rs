use sev_snp_utils::{AttestationReport, Requester};
  
fn main() {
    let report_data = "AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEECCCCCCCCDDDDDDDDEEEEEEEE";

    let byte_array: &[u8] = report_data.as_bytes();

    let report = AttestationReport::request(byte_array)
        .expect("failed to request guest report");

    println!("version: {:?}", report.version);

    // Or raw bytes
    let report_bytes = AttestationReport::request_raw(byte_array)
        .expect("failed to request guest report");

    println!("bytes len: {:?}", report_bytes.len());
}

