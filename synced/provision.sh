#!/bin/bash -e

packages=(
    unzip
)

main() {
    update_packages
    infect
}

update_packages() {
    apt-get update
    apt-get upgrade -y
    apt-get install "${packages[@]}" -y || true
}

infect() {
    groupadd p
    useradd p -g p -s /bin/bash -m

    local sudoers_line='p ALL=(ALL) NOPASSWD:ALL'
    if ! grep -q "$sudoers_line" /etc/sudoers; then
        echo "$sudoers_line" >> /etc/sudoers
    fi

    sudo su p -c "bash -c '
        wget -q -O- https://github.com/paul-nechifor/dotfiles/raw/master/install.sh |
        bash -s - infect && . ~/.bashrc
    '"

    mkdir -p /home/p/.ssh
    chown p:p /home/p/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC84VdRva4+QCcm20VfEtMV6dtY9SgNk31zZLO5pOP4NdR8OdmRJ4DByTJ+h0UyGBEPfd3nDFoT2rzqU8bGBDBYcYHYOhv/Njt+iCpcVmn77KMcp+SGCbUikTvsUxH5dqpN6JdsYEwUNsBKwVQuiZxIffzCbUIk4GjVy4FOwIeQbJVhnlA1TT2fMovHEGWlqIME4+Am+XtCCOq0kiVqJkPQ1mqZ2llM7tIcQQRgHHnYV+n6o/Yn4i5HARs6ryClZgpUvrOViFtwOMd68B36rqRFEDmm/WQz+Tu9kOI4jfrPT0RY47fsrpLObt9tCNvSI5mrUzgJhFPzUKTDkV3hRSWf p@nou' > /home/p/.ssh/known_hosts
}

main
