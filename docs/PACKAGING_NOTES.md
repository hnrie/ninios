# Packaging Notes

## Môi trường build Debian/WSL

Cài các package cần thiết:

```bash
sudo apt-get update
sudo apt-get install -y build-essential devscripts dpkg-dev debhelper lintian
```

Build toàn bộ package:

```bash
./tools/build-packages.sh
```

Output được ghi vào `dist/packages/`.

## Lintian

Lệnh kiểm tra cơ bản:

```bash
lintian dist/packages/*.deb
```

Các warning `empty-binary-package` hiện được chấp nhận cho:

- `nonla-calamares-config`
- `nonla-repo-keyring`
- `nonla-welcome`

Lý do: các package này đang là skeleton để giữ ownership packaging, chưa ship
payload thật. Khi thêm branding, cấu hình, theme, keyring hoặc welcome app thật,
các warning này phải biến mất thay vì bị ignore lâu dài.

`nonla-look` đã có payload thật đầu tiên nên không còn nằm trong nhóm warning
`empty-binary-package`.

`nonla-default-settings` đã có payload thật đầu tiên cho `/etc/skel` và
`/etc/environment.d`, nên không còn nằm trong nhóm warning
`empty-binary-package`.

`nonla-branding` đã có payload thật đầu tiên cho logo, icon và metadata nhận
diện riêng của nonlaOS, nên không còn nằm trong nhóm warning
`empty-binary-package`.

`nonla-desktop` giữ `fcitx5` và `fcitx5-unikey` trong `Depends`, nhưng đặt
`kcm-fcitx5` trong `Recommends`. Lý do: trên môi trường Debian/WSL hiện tại,
`kcm-fcitx5` không có candidate installable, nên đưa vào `Depends` sẽ làm
metapackage không cài được dù input method core vẫn có.

## Trạng Thái Version Của Toolchain Packaging

Phần này ghi lại kết quả kiểm chứng thực tế khi rà soát "nâng mọi thứ lên bản
mới nhất", để lần sau không phải kiểm tra lại từ đầu.

### Đã nâng

- `Standards-Version: 4.7.0` -> `4.7.2`.

`4.7.2` là bản Debian Policy trong Debian stable/trixie, đúng với base distro mà
repo đang nhắm tới. Các yêu cầu mới giữa `4.7.0` và `4.7.2` đã được kiểm tra
trên package hiện tại và không có vi phạm:

- Policy 4.7.1 (merged-usr): không package nào ship file vào `/bin`, `/lib`,
  `/sbin`.
- Policy 4.7.1 / 4.7.2 (`/usr/games`): không package nào ship file vào
  `/usr/games`.
- Policy 4.7.1 (`/usr/share/man`, `/usr/share/info`, locale): không package nào
  phụ thuộc runtime vào các đường dẫn này.

Ngoài ra repo chưa có maintainer script, init script hay systemd unit nào, nên
yêu cầu về systemd unit của Policy 4.7.0 cũng không áp dụng.

### Không nâng, kèm lý do đã kiểm chứng

- `debhelper-compat (= 13)`: **giữ nguyên 13**.

  Compat 14 và 15 vẫn đang ở trạng thái "open for development; use with
  caution" theo `debhelper-compat-upgrade-checklist(7)`. Quan trọng hơn, gói
  `debhelper` chỉ `Provides` compat tới `13`, nên khai báo `debhelper-compat
  (= 14)` làm `dpkg-checkbuilddeps` báo `Unmet build dependencies` và build
  fail ngay. Compat 13 hiện vẫn là "the recommended mode of operation".

- `Standards-Version` lên `4.7.3` / `4.7.4`: **giữ ở 4.7.2**.

  Lý do chính: khuyến nghị của Policy 4.7.3 là bỏ `Priority` khỏi source
  stanza, nhưng thử nghiệm thực tế cho thấy trên toolchain hiện tại việc bỏ
  `Priority` làm binary package mất luôn field `Priority` và sinh warning
  `recommended-field ... Priority`. Đây là regression thật nên không áp dụng.

  Bối cảnh thêm: hai bản này mới chỉ có trong forky/sid, chưa vào
  stable/trixie. Riêng điểm này không phải lý do chặn, vì `Standards-Version`
  là khai báo mức tuân thủ Policy chứ không phải build dependency.

- `actions/checkout` và `actions/upload-artifact`: **giữ `@v7`**.

  Đã kiểm tra release mới nhất trên GitHub: cả hai đang ở `v7.0.1`, tức major
  tag `v7` đã là mới nhất.

- Thêm `package-ecosystem: "docker"` vào `.github/dependabot.yml` để theo dõi
  image `debian:trixie`: **không thêm**.

  Dependabot chỉ nhận diện image trong `Dockerfile`, Docker Compose, Kubernetes
  manifest và Helm values. Image trong workflow này nằm trong một lệnh
  `docker run` bên trong block `run:`, nên Dependabot không quét được. Thêm
  entry này sẽ tạo config chết mà không sinh update nào.

- Base distro `trixie`: **giữ nguyên**.

  `trixie` vẫn là Debian stable hiện tại. `forky` mới ở trạng thái testing và dự
  kiến phát hành năm 2027, nên chưa phải "bản mới nhất" hợp lý cho một distro
  hướng tới người dùng cuối.

## Firefox Policy Và Trình Duyệt Mặc Định

`nonla-default-settings` ship policy Firefox tại
`/etc/firefox/policies/policies.json`, không phải `/etc/firefox-esr/policies`.

Lý do: `firefox-esr` của Debian tạo config dir `/etc/firefox-esr` nhưng runtime
lại đọc policy từ `/etc/firefox/policies/policies.json`. Đây là hành vi được ghi
nhận trên Debian Wiki và trong bug `#979821`, tới nay vẫn chưa đổi. Ship vào
`/etc/firefox-esr/policies` sẽ tạo file chết không có tác dụng.

Policy hiện chỉ đặt hai key:

- `RequestedLocales`: ưu tiên `vi`, fallback `en-US`. Cần
  `firefox-esr-l10n-vi` (đã nằm trong `Depends` của `nonla-desktop`) thì locale
  `vi` mới thực sự có sẵn.
- `DontCheckDefaultBrowser`: tắt prompt "đặt làm trình duyệt mặc định", vì
  distro đã đặt sẵn Firefox là mặc định.

Không đặt `DisableAppUpdate` vì `firefox-esr` trên Debian vốn đã cập nhật qua
APT, không có bộ updater riêng để tắt. Không đặt `DisableTelemetry` vì đây là
lựa chọn chính sách người dùng, nên để mặc định upstream thay vì ghi cứng trong
package settings.

Trình duyệt mặc định được đặt ở hai lớp trong `/etc/skel`:

- `.config/mimeapps.list` cho lớp XDG (`xdg-open`, app GTK).
- Khóa `BrowserApplication` trong `.config/kdeglobals` cho lớp KDE.

Cần cả hai vì KDE đọc `BrowserApplication` trước, còn app ngoài KDE chỉ nhìn
`mimeapps.list`.

## Lintian overrides

`nonla-default-settings` override tag `package-contains-file-in-etc-skel` cho
các file cấu hình trong `/etc/skel`.

Lý do: package này có mục tiêu rõ ràng là seed cấu hình KDE/FCITX5 cho user mới
của distro. Cách này không ghi đè cấu hình user hiện có và tránh maintainer
script sửa home directory runtime.

Package này cũng ship live-config component
`/usr/lib/live/config/9998-nonla-default-settings`. Lý do: trong live ISO,
live user thường được tạo trong quá trình boot bởi `live-config`, nên hook
chroot của live-build có thể chạy quá sớm khi `/home/user` chưa tồn tại.
Component này chỉ chạy trong môi trường live, sau bước `user-setup`, để copy
`/etc/skel` vào live home đúng thời điểm.
