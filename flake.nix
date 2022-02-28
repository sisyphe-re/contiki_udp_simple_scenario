{
  description = "A flake for setting up an experiment on FIT IoT-Lab";
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.03;
  inputs.iotlabcli.url = github:sisyphe-re/iotlabcli;

  inputs.iot-lab = {
    url = "github:iot-lab/iot-lab";
    flake = false;
  };

  inputs.traces = {
    url = "github:sisyphe-re/traces";
    flake = false;
  };

  outputs = { self, nixpkgs, iotlabcli, iot-lab, traces }:
    with import nixpkgs { system = "x86_64-linux"; };
    let
      run_script = pkgs.writeScriptBin "run" ''
        #! ${pkgs.nix}/bin/nix-shell
        #! nix-shell -I nixpkgs=${nixpkgs} -i bash -p git nix gnutar openssh gcc-arm-embedded jq socat
                
        export PATH=''${PATH}:${iotlabcli.defaultPackage.x86_64-linux}/bin;
        
        if [ -z ''${FITIOT_USER+x} ]; then echo "FITIOT_USER is unset."; exit 1; else echo "FITIOT_USER is set to '$FITIOT_USER'."; fi
        if [ -z ''${FITIOT_PRIVATE_KEY+x} ]; then echo "FITIOT_PRIVATE_KEY is unset."; exit 1; else echo "FITIOT_PRIVATE_KEY is set."; fi
        if [ -z ''${FITIOT_PUBLIC_KEY+x} ]; then echo "FITIOT_PUBLIC_KEY is unset."; exit 1; else echo "FITIOT_PUBLIC_KEY is set."; fi
        if [ -z ''${FITIOT_RC+x} ]; then echo "FITIOT_RC is unset."; exit 1; else echo "FITIOT_RC is set."; fi

        if [ -z ''${SSH_PORT+x} ]; then echo "SSH_PORT is unset."; exit 1; else echo "SSH_PORT is set to '$SSH_PORT'."; fi
        if [ -z ''${SSH_USER+x} ]; then echo "SSH_USER is unset."; exit 1; else echo "SSH_USER is set to '$SSH_USER'."; fi
        if [ -z ''${SSH_HOST+x} ]; then echo "SSH_HOST is unset."; exit 1; else echo "SSH_HOST is set to '$SSH_HOST'."; fi
        if [ -z ''${SSH_PATH+x} ]; then echo "SSH_PATH is unset."; exit 1; else echo "SSH_PATH is set to '$SSH_PATH'."; fi
        if [ -z ''${SSH_PRIVATE_KEY+x} ]; then echo "SSH_PRIVATE_KEY is unset."; exit 1; else echo "SSH_PRIVATE_KEY is set."; fi
        if [ -z ''${SSH_PUBLIC_KEY+x} ]; then echo "SSH_PUBLIC_KEY is unset."; exit 1; else echo "SSH_PUBLIC_KEY is set."; fi

        echo "HOME is ''${HOME}"
        cd ~/;
        mkdir -p ~/.ssh/
        echo "''${FITIOT_PRIVATE_KEY}" | base64 -d &> ~/.ssh/id_ed25519
        echo "''${FITIOT_PUBLIC_KEY}" | base64 -d &> ~/.ssh/id_ed25519.pub
        chmod 600 ~/.ssh/id_ed25519

        for site in {paris,grenoble,saclay,strasbourg,lyon,lille};
        do
            ${openssh}/bin/ssh-keyscan -t rsa ''${site}.iot-lab.info >> ~/.ssh/known_hosts;
        done

        echo "Setting up secret";
        echo "''${FITIOT_RC}" &> ~/.iotlabrc

        cp -r ${traces} traces;
        cp -r ${iot-lab} iot-lab;
        cd iot-lab/;
        make setup-contiki;
        cp ../traces/src/broadcast-example.c ./parts/contiki/examples/ipv6/simple-udp-rpl/broadcast-example.c;
        cd ./parts/contiki/examples/ipv6/simple-udp-rpl/;
        make TARGET=iotlab-m3
        cd ~/traces/;

        sed -i "s/yourlogin/''${FITIOT_USER}/g" scripts/exp.sh;
        cd scripts;
        sed -i "s/bin\/bash/usr\/bin\/env bash/g" exp.sh;
        ./exp.sh "MyExp" 6 12 1 1 "3,archi=m3:at86rf231+site=lille"
        cp ~/traces/log/*/MyExp.tar.gz ''${SSH_PATH}/;
      '';
    in
    {
      packages.x86_64-linux.scripts =
        stdenv.mkDerivation {
          src = self;
          name = "scripts";
          buildInputs = [
            iotlabcli
            run_script
          ];
          installPhase = ''
            mkdir $out;
            cp ${run_script}/bin/run $out;
          '';
        };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.scripts;
    };
}
