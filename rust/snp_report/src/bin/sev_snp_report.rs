use anyhow::*;
use serde::{Deserialize, Serialize};
use sev::firmware::guest::types::{AttestationReport, SnpReportReq};
use sev::firmware::guest::Firmware;
use sev::firmware::host::types::CertTableEntry;

use std::io::Write;

#[derive(Serialize, Deserialize)]
struct SnpEvidence {
    attestation_report: AttestationReport,
    cert_chain: Vec<CertTableEntry>,
}

fn get_evidence() -> Result<String> {
        let data = "AAAAAAAABBBBBBBBCCCCCCCCDDDDDDDDEEEEEEEECCCCCCCCDDDDDDDDEEEEEEEE";
        let mut buffer = [0; 64];
        let mut test: &mut[u8] = &mut buffer;
        test.write(data.as_bytes()).unwrap();

        let mut firmware = Firmware::open()?;
        //let mut report_request = SnpReportReq::new(Some(report_data_bin.as_slice().try_into()?), 0);

        //let mut report_request = SnpReportReq::new(Some(buffer), 0);
        let report_request = SnpReportReq::new(Some(buffer), 0);

        let (report, certs) = firmware
        //let report = firmware
            //.snp_get_ext_report(None, &mut report_request)
            .snp_get_ext_report(None, report_request)
            //.snp_get_report(None, &mut report_request)
            .map_err(|e| anyhow!("failed to get attestation report: {:?}", e))?;

        let evidence = SnpEvidence {
            attestation_report: report,
            cert_chain: certs,
        };

        serde_json::to_string(&evidence).map_err(|_| anyhow!("Serialize SNP evidence failed"))
}

fn main() {
        let out = get_evidence();
        println!("out: {:?}", out);
}

