# Testing Checklist

## Live ISO

- [ ] Boot UEFI.
- [ ] Boot BIOS/legacy nếu VM hỗ trợ.
- [ ] GRUB menu hiển thị nonlaOS hoặc không còn Debian mặc định.
- [ ] Plymouth/boot splash dùng nonla nếu khả dụng.
- [ ] Plymouth có animation nhẹ: logo pulse và vệt sáng lướt, không phải ảnh
  tĩnh phóng to.
- [ ] Live desktop vào được.
- [ ] KDE live session dùng wallpaper nonla.
- [ ] `/var/lib/live/config/nonla-default-settings` tồn tại trong live session.
- [ ] `~/.config/plasma-org.kde.plasma.desktop-appletsrc` trỏ tới
  `/usr/share/wallpapers/nonla-default`.
- [ ] KDE live session dùng color scheme `Nonla` nếu Plasma nhận config.
- [ ] Desktop có shortcut `Install nonlaOS`.
- [ ] Menu app có `Install nonlaOS`.
- [ ] Calamares mở được.
- [ ] `fastfetch` hiển thị `nonlaOS 0.1 Alpha` và logo ANSI màu nonlaOS.
- [ ] Nếu có `neofetch`, logo ANSI màu và thông tin distro hiển thị đúng.
- [ ] Installer mở được.
- [ ] Cài vào VM thành công.
- [ ] Reboot vào hệ đã cài.
- [ ] `apt update` / `apt upgrade`.
- [ ] `systemctl --failed`.
- [ ] `journalctl -p 3 -b`.
- [ ] Gõ tiếng Việt.
- [ ] LibreOffice mở và tạo tài liệu được.
- [ ] Firefox mở web được.
- [ ] USB.
- [ ] Audio.
- [ ] Wi-Fi.
- [ ] Suspend/resume.

## Package Checklist

- [ ] `./tools/build-packages.sh` chạy pass.
- [ ] `.deb` nằm trong `dist/packages/`.
- [ ] `lintian dist/packages/*.deb` không có error nghiêm trọng.
- [ ] Cài thử package bằng `apt install ./dist/packages/*.deb` hoặc
  `dpkg -i dist/packages/*.deb`.

## Default Settings Checklist

- [ ] Cài `nonla-look` và `nonla-default-settings`.
- [ ] Tạo user mới sau khi package đã được cài.
- [ ] Login KDE bằng user mới.
- [ ] Wallpaper nonla được áp dụng.
- [ ] Color scheme `Nonla` được áp dụng.
- [ ] Panel Plasma cơ bản xuất hiện và launcher dùng icon `nonlaos`.
- [ ] `fcitx5` chạy sau khi login.
- [ ] Gõ tiếng Việt được bằng FCITX5 Unikey.
- [ ] User đã tồn tại trước đó không bị ghi đè cấu hình.

## Calamares Checklist

- [ ] Cài `nonla-calamares-config`.
- [ ] `/etc/calamares/settings.conf` tồn tại.
- [ ] `/etc/calamares/branding/nonla/branding.desc` tồn tại.
- [ ] `/etc/calamares/branding/nonla/show.qml` tồn tại.
- [ ] `/usr/share/applications/install-nonlaos.desktop` tồn tại.
- [ ] `/etc/skel/Desktop/install-nonlaos.desktop` tồn tại và executable.
- [ ] `branding.desc` có key `slideshow: show.qml`.
- [ ] `settings.conf` không gọi module ngoài Calamares core như
  `dpkg-unsafe-io`, `sources-media`, `bootloader-config`.
- [ ] `calamares` mở với branding nonlaOS.
- [ ] `install-nonlaos` mở Calamares qua `pkexec`.

## Fetch Tool Checklist

- [ ] `/usr/share/nonlaos/ascii/nonlaos.ansi` tồn tại.
- [ ] File ASCII/ANSI được sinh từ `img/launcher_icon.png` bằng
  `tools/generate-ascii-logo.py`, không vẽ tay.
- [ ] Logo terminal dùng ký tự ASCII thường, không dùng block glyph.
- [ ] `fastfetch` dùng logo `/usr/share/nonlaos/ascii/nonlaos.ansi`.
- [ ] `fastfetch` đọc OS là `nonlaOS 0.1 Alpha`.
- [ ] Nếu cài `neofetch`, config user mới dùng cùng logo ANSI.

## Branding Checklist

- [ ] Cài `nonla-branding`.
- [ ] Kiểm tra `/usr/share/nonlaos/branding/nonlaos-release`.
- [ ] Kiểm tra `/usr/share/nonlaos/branding/boot_logo.png`.
- [ ] Kiểm tra `/usr/share/nonlaos/branding/launcher_icon.png`.
- [ ] Kiểm tra `/usr/share/pixmaps/nonlaos.png`.
- [ ] Kiểm tra `/usr/share/icons/hicolor/256x256/apps/nonlaos.png`.
- [ ] Dry-run cài `nonla-desktop` và xác nhận kéo `nonla-branding`,
  `nonla-look`, `nonla-default-settings`, `nonla-calamares-config`,
  `nonla-repo-keyring`, `nonla-apt-source`.

## APT Repository Checklist

- [ ] `./tools/build-packages.sh` chạy pass.
- [ ] `./tools/make-repo.sh` chạy pass.
- [ ] `dist/repo/dists/stable/main/binary-amd64/Packages` tồn tại.
- [ ] `dist/repo/dists/stable/main/binary-amd64/Packages.gz` tồn tại.
- [ ] `dist/repo/dists/stable/Release` tồn tại.
- [ ] `dist/repo/dists/stable/InRelease` tồn tại sau khi chạy
  `./tools/sign-repo.sh`.
- [ ] `dist/repo/dists/stable/Release.gpg` tồn tại sau khi chạy
  `./tools/sign-repo.sh`.
- [ ] `gpgv --keyring packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg
  dist/repo/dists/stable/InRelease` verify good.
- [ ] `gpgv --keyring packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg
  dist/repo/dists/stable/Release.gpg dist/repo/dists/stable/Release` verify
  good.
- [ ] `nonla-repo-keyring` ship đúng
  `/usr/share/keyrings/nonla-archive-keyring.gpg`.
- [ ] APT đọc được repo local qua `file://`.
- [ ] `apt-cache policy nonla-desktop` thấy package từ repo local.

## APT Source Checklist

- [ ] Build mặc định `./tools/build-packages.sh` tạo
  `nonla-apt-source_*.deb`.
- [ ] Entry mặc định có `Enabled: no` và URI placeholder
  `https://REPLACE-WITH-NONLA-REPO-URI.invalid/nonlaos`.
- [ ] `apt update` không báo lỗi khi chỉ có entry placeholder disabled.
- [ ] Build với `NONLA_REPO_URI=...` tạo entry `Enabled: yes` đúng URI.
- [ ] Generator từ chối scheme không hợp lệ như `ftp://`.
- [ ] Generator từ chối URI chứa ký tự ngoài whitelist `A-Za-z0-9:/._~%+-`,
  gồm `|`, `&`, `\`, khoảng trắng, tab và newline.
- [ ] Generator từ chối `NONLA_REPO_SUITE`, `NONLA_REPO_COMPONENT`,
  `NONLA_REPO_ARCH` rỗng.
- [ ] Generator báo lỗi rõ khi thiếu tham số hoặc template không tồn tại.
- [ ] `nonla-apt-source` ship đúng `/etc/apt/sources.list.d/nonla.sources`.
- [ ] Entry có `Signed-By: /usr/share/keyrings/nonla-archive-keyring.gpg`.
- [ ] `nonla-apt-source` `Depends` trên `nonla-repo-keyring`.
- [ ] `nonla-desktop` `Depends` trên `nonla-repo-keyring` và
  `nonla-apt-source`.
- [ ] Với repo đã ký, `apt update` verify chữ ký thành công qua entry này.
- [ ] `apt-cache policy nonla-desktop` thấy package qua entry này.
- [ ] `apt update` từ chối repo ký bằng key khác, chứng minh `Signed-By` có
  hiệu lực.
- [ ] `tools/build-packages.sh` in dòng `Verified Signed-By ...`.
- [ ] Đổi `Signed-By` sang tên keyring sai thì build fail.
- [ ] Upgrade khi conffile chưa bị sửa: entry được cập nhật theo build mới.
- [ ] Upgrade khi conffile đã bị admin sửa: giá trị của admin được giữ.

## CI ISO Checklist

- [ ] Workflow `ISO build` chạy pass trên GitHub Actions bằng
  `workflow_dispatch`.
- [ ] Secret `NONLA_ARCHIVE_PRIVATE_KEY` đã được set.
- [ ] Artifact `nonlaos-packages` có đủ package `.deb`.
- [ ] Artifact `nonlaos-apt-repo` có `Packages.gz`, `Release`, `InRelease` và
  `Release.gpg`.
- [ ] Artifact `nonlaos-iso` có `nonlaOS-0.1-alpha-amd64.iso`.
- [ ] Artifact `nonlaos-iso` có `SHA256SUMS`.
- [ ] Artifact `nonlaos-iso` có `SHA256SUMS.gpg`.
- [ ] `file dist/iso/nonlaOS-0.1-alpha-amd64.iso` nhận diện ISO image.
- [ ] `isoinfo -d -i dist/iso/nonlaOS-0.1-alpha-amd64.iso` thấy El Torito boot
  catalog.
- [ ] `xorriso -indev dist/iso/nonlaOS-0.1-alpha-amd64.iso -report_el_torito
  plain` thấy boot metadata.
- [ ] `./tools/verify-iso-boot.sh` chạy pass trong CI.
- [ ] QEMU BIOS smoke test không báo `Boot failed` hoặc `No bootable device`.
- [ ] `SHA256SUMS.gpg` verify good bằng public key nonlaOS.
- [ ] `sha256sum -c SHA256SUMS` pass.
- [ ] SourceForge upload pass nếu có đủ secrets:
  `SOURCEFORGE_USER`, `SOURCEFORGE_PROJECT`, `SOURCEFORGE_SSH_PRIVATE_KEY`.
- [ ] Nếu thiếu SourceForge secrets, workflow skip public upload nhưng vẫn pass.
- [ ] Tải ISO về và boot thử trong VM bằng UEFI.
- [ ] Live KDE desktop vào được.
- [ ] Wallpaper/theme nonla được áp dụng.
- [ ] Desktop có shortcut `Install nonlaOS`.
- [ ] Menu app có `Install nonlaOS`.
- [ ] Calamares mở được.
- [ ] `apt-cache policy nonla-desktop`.
- [ ] `systemctl --failed`.
- [ ] `journalctl -p 3 -b`.
