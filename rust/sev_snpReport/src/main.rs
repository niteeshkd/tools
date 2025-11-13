use sev::firmware::host::Firmware;

fn main() {
   let mut fw = Firmware::open().unwrap();
   let status = fw.snp_platform_status().unwrap();
   println!(
    "Platform status ioctl results:
        version (major, minor): {}.{}
        build id: {}
        guests: {}
        platform tcb microcode version: {}
        platform tcb snp version: {}
        platform tcb tee version: {}
        platform tcb bootloader version: {}
        reported tcb microcode version: {}
        reported tcb snp version: {}
        reported tcb tee version: {}
        reported tcb bootloader version: {}
        state: {}",
        status.build.version.major,
        status.build.version.minor,
        status.build.build,
        status.guests,
        status.tcb.platform_version.microcode,
        status.tcb.platform_version.snp,
        status.tcb.platform_version.tee,
        status.tcb.platform_version.bootloader,
        status.tcb.reported_version.microcode,
        status.tcb.reported_version.snp,
        status.tcb.reported_version.tee,
        status.tcb.reported_version.bootloader,
        status.state
    );
}
