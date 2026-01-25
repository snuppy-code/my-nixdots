{ config, pkgs, lib, ... }: {
    config = {
        sops = {
            defaultSopsFile = ./secrets.yaml;
            validateSopsFiles = false; # https://youtu.be/gdxlc5a6ne0 his was false
            age = {
                # I generated keys from all my hosts' public ssh host keys and added them to .sops.yaml
                # Here I tell sops-nix(?) about this host's private ssh host key so it can import it automatically as an age key
                sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
                # this is where it will store the converted/imported age key
                keyFile = "/var/lib/sops-nix/key.txt";
                # generate a key from the sshKeyPaths if the key specified above doesn't exist
                generateKey = true;
            };
            # Secrets get output to /run/secrets unencrypted but only accessible to root -
            #  until we specify otherwise.
            # E.g. /run/secrets/msmtp-password
            # Secrets required for user creation need to be handled slightly differently -
            #  since sops-nix normally runs after users have been created by nixos so    -
            #  appropriate ownership/permissions can be set, but this can't happen for   -
            #  user passwords, because the user won't have been created yet.
            # The provided solution is setting neededForUsers, it will extract to        -
            # /run/secrets-for-users before user creation. Owners can't be set           -
            # for those files:
            # ```
            # secrets = {
            #     snuppy-password.neededForUsers = true;
            # };
            # ```
            # And later reference as, in this case, `config.sops.secrets.snuppy-password.path`
        };

        # Makes the passwords of users be controlled only by nixos config
        # Required to set passwords with sops-nix
        # BE CAREFUL WITH THIS! IT BITES! CAN AND WILL LOCK YOU OUT OF YOUR SERVER!
        users.mutableUsers = false; 
    };
}
