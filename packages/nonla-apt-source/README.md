# nonla-apt-source

Package này ship APT source entry của nonlaOS để hệ thống đã cài nhận package
và update từ repo chính thức.

File được cài:

```text
/etc/apt/sources.list.d/nonla.sources
```

Entry dùng định dạng deb822 và verify bằng keyring của `nonla-repo-keyring`:

```text
/usr/share/keyrings/nonla-archive-keyring.gpg
```

## Vì sao URI được truyền lúc build

README gốc của repo yêu cầu không hardcode domain public của nonlaOS trong
source. Vì vậy URI repo được truyền vào lúc build qua biến môi trường thay vì
commit thẳng vào file.

Build có URI thật:

```bash
NONLA_REPO_URI=https://YOUR_EXISTING_REPO_DOMAIN/path/to/repo \
  ./tools/build-packages.sh
```

Build không có URI:

```bash
./tools/build-packages.sh
```

Khi không có `NONLA_REPO_URI`, package vẫn build được nhưng entry sinh ra là
placeholder và mang `Enabled: no`. APT bỏ qua entry disabled, nên `apt update`
trên máy người dùng không bị lỗi vì domain giả.

## Biến build

| Biến | Mặc định | Ý nghĩa |
| --- | --- | --- |
| `NONLA_REPO_URI` | không có, sinh placeholder `Enabled: no` | URI gốc của APT repo |
| `NONLA_REPO_SUITE` | `stable` | Suite, khớp `tools/make-repo.sh` |
| `NONLA_REPO_COMPONENT` | `main` | Component, khớp `tools/make-repo.sh` |
| `NONLA_REPO_ARCH` | `amd64` | Architecture, khớp `tools/make-repo.sh` |

`NONLA_REPO_URI` chỉ chấp nhận scheme `http://`, `https://` hoặc `file:/`.

Mọi giá trị phải khớp whitelist ký tự `A-Za-z0-9:/._~%+-`. Whitelist này chặn
newline và tab, tránh việc một giá trị build chèn thêm field deb822 vào stanza
sinh ra.

## Bật thủ công trên máy đã cài

Nếu `.deb` được build không kèm URI, admin có thể sửa trực tiếp:

```bash
sudoedit /etc/apt/sources.list.d/nonla.sources
```

Đổi `URIs:` sang domain thật và `Enabled:` thành `yes`, rồi chạy:

```bash
sudo apt update
apt-cache policy nonla-desktop
```

File này được dpkg đăng ký là conffile, nên thay đổi thủ công ở trên không bị
ghi đè khi upgrade package.

## Kiểm tra

```bash
cat /etc/apt/sources.list.d/nonla.sources
apt-config dump | grep -i sourceparts
```

## Giới hạn hiện tại

`tools/build-iso.sh` chưa truyền `NONLA_REPO_URI`, nên ISO build từ CI hiện
vẫn ship entry placeholder disabled. Xem `docs/PACKAGING_NOTES.md` mục "Việc
còn lại cho pipeline ISO".
