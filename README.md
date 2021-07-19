# Contiki Udp Simple Scenario

A campaign executing a single scenario based on the Contiki operating system and M3 FIT IoT-Lab nodes.

## Build

In order to build the project, use [Nix](https://nixos.org/) and run ```nix build```.

## Setup

In order to run the experiments, a few environment variables are needed:

### Campaign-specific Environment Variables

- FITIOT_USER: User to use to connect to the FIT IoT-Lab frontend servers
- FITIOT_PRIVATE_KEY: base64 encoded SSH private key to use to connect to the FIT IoT-Lab frontend servers
- FITIOT_PUBLIC_KEY: base64 encoded SSH public key to use to connect to the FIT IoT-Lab frontend servers
- FITIOT_RC: FIT IoT-Lab configuration file (usually located in `~/.iotlabrc`) containing the user and base64 encoded password of the FIT IoT-Lab account to use to schedule experiments. The format of the file is `username:base64_encoded_password`.

### Sisyphe Environment Variables

- SSH_PORT: Port used by the SSH service running on the server receiving experimental data
- SSH_USER: User to use to connect to the server receiving experimental data using SSH
- SSH_HOST: Hostname of the server receiving experimental data
- SSH_PATH: Path where the data will be copied on the server receiving experimental data
- SSH_PRIVATE_KEY: SSH private key to use to connect to the server receiving experimental data
- SSH_PUBLIC_KEY: SSH public key to use to connect to the server receiving experimental data

## Testing

After having built the project and exported the needed environment variables, you can make a test run of the project by executing:

```
$ ./result/run
```

To change the parameters of the experiment, edit the `flake.nix` file.