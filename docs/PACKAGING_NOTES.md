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

`nonla-apt-source` có payload sinh lúc build nên cũng không nằm trong nhóm
warning `empty-binary-package`.

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

## APT source sinh lúc build

`nonla-apt-source` không commit file `nonla.sources` hoàn chỉnh. Thay vào đó
repo giữ template `payload/etc/apt/sources.list.d/nonla.sources.in` và render
nó trong `override_dh_auto_build` bằng `debian/generate-apt-source`.

Lý do: README yêu cầu không hardcode domain public của nonlaOS trong source,
nhưng hệ thống đã cài vẫn cần một entry APT thật để nhận update.

Hành vi của generator:

- Có `NONLA_REPO_URI`: render URI đó và đặt `Enabled: yes`.
- Không có `NONLA_REPO_URI`: render placeholder
  `https://REPLACE-WITH-NONLA-REPO-URI.invalid/nonlaos` và đặt `Enabled: no`.

Chọn `Enabled: no` thay vì bỏ hẳn file, vì đã kiểm chứng thực tế: APT đọc entry
`Enabled: no` mà không phát sinh lỗi, còn placeholder với `Enabled: yes` làm
`apt update` báo `Could not resolve`. Cách này giữ file ở đúng vị trí để admin
sửa, mà không làm hỏng `apt update` của build không cấu hình URI.

Generator từ chối URI có scheme ngoài `http://`, `https://`, `file:/`. Ngoài
ra mọi giá trị đưa vào template phải khớp whitelist ký tự
`A-Za-z0-9:/._~%+-`.

Dùng whitelist thay vì blacklist là có chủ đích. Bản blacklist đầu tiên chặn
`|`, `&`, `\`, khoảng trắng nhưng vẫn để lọt newline, và một URI chứa newline
có thể chèn thêm field deb822 vào stanza sinh ra. Whitelist chặn luôn newline,
tab và các metacharacter shell/sed.

`debian/generate-apt-source` được gọi qua `sh <script>` chứ không dựa vào bit
executable, vì `tools/build-packages.sh` normalize toàn bộ file trong package
về `0644` trước khi build và chỉ `chmod 0755` riêng `debian/rules`.

File `/etc/apt/sources.list.d/nonla.sources` được dpkg đăng ký là conffile.
Hành vi này đã được kiểm chứng bằng `dpkg -i` thật trên rootfs tạm:

- Conffile chưa bị sửa: build mới ghi đè được, kể cả khi version không đổi.
  dpkg so sánh nội dung chứ không so version, nên một build có URI thật vẫn
  thay được entry placeholder đã cài trước đó.
- Conffile đã bị admin sửa: dpkg giữ nguyên giá trị của admin.

### Guard Signed-By trong build

`tools/build-packages.sh` kiểm tra sau khi build: đường dẫn `Signed-By` trong
`nonla-apt-source` phải là file mà `nonla-repo-keyring` thật sự ship. Sai tên
keyring sẽ làm `apt update` hỏng trên mọi máy người dùng, mà entry mặc định
`Enabled: no` thì không phát hiện được vì APT bỏ qua stanza disabled.

Guard này fail build khi lệch, và đã được kiểm chứng bằng cách cố tình đổi
`Signed-By` sang tên sai.

### Việc còn lại cho pipeline ISO

`tools/build-iso.sh` hiện gọi `./tools/build-packages.sh` mà không truyền
`NONLA_REPO_URI`. Nghĩa là ISO build từ CI hiện tại vẫn ship entry placeholder
`Enabled: no`, và máy cài từ ISO đó chưa tự nhận update cho tới khi admin sửa
file.

Đây là giới hạn có chủ ý ở phạm vi thay đổi này, vì AGENTS.md yêu cầu không mở
rộng scope sang ISO/live-build khi task chỉ nằm ở mức package. Bước tiếp theo
để đóng vòng lặp update là truyền URI repo thật vào ISO workflow từ GitHub
secret/variable, thay vì commit domain vào source.
