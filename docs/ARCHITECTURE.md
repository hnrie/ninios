# Architecture

nonlaOS được build theo hướng package-first:

- Debian stable là base.
- KDE Plasma là desktop mặc định.
- Mọi thay đổi hệ thống được đóng gói thành `.deb`.
- APT repo sẽ phân phối package nonlaOS.
- ISO sau này sẽ được build bằng live-build hoặc pipeline tương đương, không sửa
  thủ công.

## Package groups

- `nonla-desktop`: metapackage kéo desktop stack cơ bản.
- `nonla-look`: wallpaper, color scheme, SDDM, Plymouth và nhận diện ban đầu.
- `nonla-branding`: logo, icon và metadata nhận diện hệ thống.
- `nonla-default-settings`: cấu hình mặc định người dùng qua `/etc/skel`.
- `nonla-calamares-config`: cấu hình và branding installer Calamares.
- `nonla-repo-keyring`: public archive key để verify APT repo.
- `nonla-apt-source`: APT source entry trỏ tới repo nonlaOS.
- `nonla-welcome`: welcome app sau này.

## Đường update qua APT

Máy đã cài nhận update theo chuỗi:

1. `nonla-repo-keyring` cài public key vào
   `/usr/share/keyrings/nonla-archive-keyring.gpg`.
2. `nonla-apt-source` cài `/etc/apt/sources.list.d/nonla.sources` trỏ tới repo
   nonlaOS và tham chiếu keyring trên qua `Signed-By`.
3. `nonla-desktop` `Depends` cả hai, nên hệ thống cài từ ISO có sẵn đường
   update.

URI repo không được commit trong source. Nó được truyền lúc build qua
`NONLA_REPO_URI`; build không có biến này sinh entry placeholder `Enabled: no`.
