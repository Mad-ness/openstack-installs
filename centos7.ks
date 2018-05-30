install
lang en_US.UTF-8
keyboard us
timezone Australia/Melbourne
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
services --enabled=NetworkManager,sshd
eula --agreed
ignoredisk --only-use=vda
reboot

bootloader --location=mbr
zerombr
clearpart --all --initlabel
part swap --asprimary --fstype="swap" --size=1024
part /boot --fstype ext4 --size=1024
part pv.01 --size=1 --grow
volgroup rootvg pv.01
logvol / --fstype ext4 --name=root --vgname=rootvg --size=1 --grow

rootpw --iscrypted $YOUR_ROOT_PASSWORD_HASH_HERE

repo --name=base --baseurl=http://mirror.cogentco.com/pub/linux/centos/7/os/x86_64
url --url="http://mirror.cogentco.com/pub/linux/centos/7/os/x86_64/"

%packages --ignoremissing
@core
%end

%post
mkdir -m0700 -p /root/.ssh 
cat << EOF > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwd2aaHbXGS69xW/0zJZNpfm0gTEid/PWZsiiEwWYBV3vGmKW34kylk7M3XhVmCr4eauRkz9phChpyy56jw24x+rrQkn3hm19ViyTo0Vk3nmxeHLaH621sJRk5TKJbbHNGcWcY47iov4NusDji/d3xmnJ3E8X1fIDoObNnEp+EEqqEwv/0xS+Lu1dfblqDP6pFPJVrXlBqSsAontPv2nfvsaZx14Pex+rrfj5pWoJYt+IzK5RNwGLsgeeQX9+PWoCsXN0Sa7ojwDwUY9o4LTK0hf1YXRoe5/fBilXAnMd3PwyHHARPyX8pU1JSK8fUVy5RxJ3jjRutvNEQ9OHuNt4d root@localhost.localdomain
EOF
chmod 0600 /root/.ssh/authorized_keys
restorecon -R /root/.ssh/

cat << EOF >> /etc/ssh/sshd_config
PermitRootLogin yes
PasswordAuthentication yes
EOF
restorecon -R /root/.ssh/
echo Admin123 | passwd --stdin root
%end
