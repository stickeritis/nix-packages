{ callPackage, nvidia_x11 }:

{
  v1_5_1 = callPackage ./generic.nix rec {
    inherit nvidia_x11;

    libtorchVersion = "1.5.1";
    libtorchArchives = {
      x86_64-darwin-cpu = {
        url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-${libtorchVersion}.zip";
        sha256 = "1j8sjw1ldq1l2vxd9pan2jq2jn6rjr8j6jv818lz51k4jd9j3l89";
      };
      x86_64-linux-gpu = {
        url = "https://download.pytorch.org/libtorch/cu101/libtorch-cxx11-abi-shared-with-deps-${libtorchVersion}%2Bcu101.zip";
        sha256 = "0vram4a1irgl6hspk3d8hxg6z09z41p40rpmg4r10z66vn1k4nr4";
      };
      x86_64-linux-cpu = {
        url = "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-${libtorchVersion}%2Bcpu.zip";
        sha256 = "0sv2xiiks5iwx07ssn6sxj7hk9la32v6c0fkmrcj610d8cwz3kwd";
      };
    };
  };

  v1_6_0 = callPackage ./generic.nix rec {
    inherit nvidia_x11;

    libtorchVersion = "1.6.0";
    libtorchArchives = {
      x86_64-darwin-cpu = {
        url = "https://download.pytorch.org/libtorch/cpu/libtorch-macos-${libtorchVersion}.zip";
        sha256 = "0d4n7la31qzl4s9pwvm07la7q6lhcwiww0yjpfz3kw6nvx84p22r";
      };
      x86_64-linux-gpu = {
        url = "https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-${libtorchVersion}.zip";
        sha256 = "127qnfyi1faqbm40sbnsyqxjhrqj82bzwqyz7c1hs2bm0zgrrpya";
      };
      x86_64-linux-cpu = {
        url = "https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-${libtorchVersion}%2Bcpu.zip";
        sha256 = "1975b4zvyihzh89vnwspw0vf9qr05sxj8939vcrlmv3gzvdspcxz";
      };
    };
  };
}
