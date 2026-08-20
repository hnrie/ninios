# nonla-default-settings

Package này ship cấu hình mặc định cho user mới thông qua `/etc/skel`, cấu hình
input method toàn hệ thống qua `/etc/environment.d` và policy Firefox toàn hệ
thống qua `/etc/firefox/policies`.

## Phạm vi

- Áp dụng wallpaper `nonla-default` cho Plasma desktop mới.
- Áp dụng color scheme `Nonla`.
- Seed panel Plasma cơ bản với launcher icon `nonlaos`.
- Ghim Firefox, Dolphin và Konsole vào task manager của panel.
- Đặt Firefox ESR làm trình duyệt mặc định cho user mới.
- Ưu tiên giao diện tiếng Việt cho Firefox ESR.
- Bật biến môi trường FCITX5.
- Autostart `fcitx5` cho user KDE mới.
- Seed FCITX5 profile ưu tiên `unikey`.

Package không sửa home directory của user hiện có và không dùng maintainer script
để ghi đè cấu hình runtime.

## Firefox

Firefox mặc định được cấu hình ở hai lớp:

- `/etc/firefox/policies/policies.json`: policy toàn hệ thống, đặt
  `RequestedLocales` ưu tiên `vi` và tắt prompt "đặt làm trình duyệt mặc định".
  Đây là đường dẫn mà `firefox-esr` của Debian thực sự đọc, không phải
  `/etc/firefox-esr/policies`.
- `/etc/skel/.config/mimeapps.list` và khóa `BrowserApplication` trong
  `/etc/skel/.config/kdeglobals`: đặt `firefox-esr.desktop` làm trình duyệt mặc
  định cho user mới ở cả lớp XDG lẫn lớp KDE.

`firefox-esr` nằm ở `Recommends` chứ không phải `Depends`: package này chỉ ship
cấu hình, còn việc chọn thành phần desktop stack thuộc về `nonla-desktop`. Gói
ngôn ngữ `firefox-esr-l10n-vi` cũng được kéo từ `Depends` của `nonla-desktop`
vì lý do tương tự.

## Locale và timezone

Package này không ép locale hoặc timezone hệ thống.

Locale/timezone nên được cấu hình ở installer, live-build profile hoặc tài liệu
triển khai, vì đây là lựa chọn theo vùng/người dùng và không nên bị package
settings ghi cứng bằng `postinst`.
