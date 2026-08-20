# Changelog

Tất cả thay đổi đáng chú ý của nonlaOS sẽ được ghi tại đây.

Định dạng dựa trên Keep a Changelog, nhưng repo hiện đang ở giai đoạn alpha nên
chưa có release chính thức.

## Unreleased

- Tạo nền repo và skeleton Debian package.
- Làm cho package skeleton build được trên Debian/WSL.
- Thêm payload nhận diện đầu tiên cho `nonla-look`.
- Nâng `Standards-Version` lên `4.7.2` cho toàn bộ package và ghi lại trạng
  thái version của toolchain packaging trong `docs/PACKAGING_NOTES.md`.
- Thêm package `nonla-apt-source` ship `/etc/apt/sources.list.d/nonla.sources`
  và cho `nonla-desktop` kéo `nonla-repo-keyring` cùng `nonla-apt-source`, để
  hệ thống đã cài nhận update qua APT.
- Thêm guard trong `tools/build-packages.sh` để build fail nếu `Signed-By` của
  APT source không khớp keyring mà `nonla-repo-keyring` ship.
