FROM --platform=linux/amd64 archlinux:base

# archlinux:base ships amd64 only, so this runs under QEMU emulation on
# Apple Silicon. pacman's download sandbox (seccomp/landlock) breaks under
# that emulation ("error restricting syscalls via seccomp: 22") — disable
# it in this throwaway container.
RUN echo 'DisableSandboxSyscalls' >> /etc/pacman.conf

RUN pacman-key --init && pacman-key --populate archlinux \
  && pacman -Syu --noconfirm \
  && pacman -S --needed --noconfirm sudo git which \
  && pacman -Scc --noconfirm

# deps.sh needs a non-root user: makepkg (used to build yay from AUR)
# refuses to run as root, and chsh needs a real account to switch shells for.
RUN useradd -m -G wheel -s /bin/bash tester \
  && mkdir -p /etc/sudoers.d \
  && echo 'tester ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/tester \
  && chmod 440 /etc/sudoers.d/tester \
  && echo 'tester:tester' | chpasswd

USER tester
WORKDIR /home/tester/dotfiles
ENTRYPOINT ["/bin/bash"]
