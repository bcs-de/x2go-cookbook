# Cookbook Name:: x2go
# Recipe:: default
#
# Copyright 2013, Arnold Krille for bcs kommunikationsloesungen
#                 <a.krille@b-c-s.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe('x2go::common')

include_recipe('line')

include_recipe('pxe::default')
tftpdir = node[:tftp][:directory]

node.default[:nfs][:service][:portmap] = 'rpcbind'
include_recipe('nfs::server')

x2gotce_base = node[:x2go][:tce][:basedir] || '/srv/x2gothinclient'

# Basic setup:

apt_package 'x2gothinclientmanagement' do
  action :install
end

aptcacherservers = []
if node[:apt] && node[:apt][:cacher_ipaddress]
  cacher = Chef::Node.new
  cacher.name(node[:apt][:cacher_ipaddress])
  cacher.set[:ipaddress] = node[:apt][:cacher_ipaddress]
  cacher.set[:apt] = node[:apt]
  aptcacherservers << cacher
end

unless Chef::Config[:solo]
  query = 'recipes:apt\:\:cacher-ng'
  if node[:apt]['cacher-client'][:restrict_environment]
    query += " AND chef_environment:#{node.chef_environment}"
  end
  Chef::Log.debug("apt::cacher-client searching for '#{query}'")
  aptcacherservers += search(:node, query)
end

aptproxy = ''
if aptcacherservers.length > 0
  aptproxy = "http://#{aptcacherservers[0][:ipaddress]}:"\
             "#{aptcacherservers[0][:apt].fetch('cacher_port', 3142)}"
end

template '/etc/x2go/x2gothinclient_settings' do
  source 'x2gothinclient_settings.erb'
  variables(
    http_proxy: aptproxy,
    x2gotce_base: x2gotce_base,
    tftpdir: tftpdir
  )
end

directory x2gotce_base do
  action :create
  mode 0755
end
directory "#{x2gotce_base}/etc" do
  action :create
  mode 0755
end

template "#{x2gotce_base}/etc/preseed.txt" do
  source 'preseed.txt.erb'
  mode 0755
end

cookbook_file '/usr/sbin/x2gothinclient_create' do
  source 'x2gothinclient_create'
  mode 0755
end

##
## Create the chroot
##
execute 'x2gothinclient_create' do
  command '/usr/sbin/x2gothinclient_create'
  environment('USER' => 'root', 'TC_NONINTERACTIVE' => 'true')
  action :run
  creates "#{x2gotce_base}/chroot"
end

##
## Export via nfs
##
nfs_export "#{x2gotce_base}/chroot" do
  network '*'
  writeable false
  sync false
  options %w(no_root_squash hide nocrossmnt no_subtree_check)
end

##
## Install the kernel
##
cookbook_file '/usr/sbin/x2gothinclient_shell' do
  source 'x2gothinclient_shell'
  mode 0755
end

has_kernel = false
if ::Dir.exists?("#{x2gotce_base}/chroot/boot")
  ::Dir.entries("#{x2gotce_base}/chroot/boot").each do |file|
    if ::File.fnmatch('vmlinuz*', "#{x2gotce_base}/chroot/boot/#{file}")
      log "Found a kernel '#{file}'"
      has_kernel = true
    end
  end
end

extrapackages = node['x2go']['tce']['extra_packages']
%w(linux-image-3.2.0-4-686-pae xserver-xorg-input-kbd).each do |pkg|
  extrapackages << pkg
end
extrapackages = extrapackages.join(' ')

execute 'install extra packages' do
  command "/usr/sbin/x2gothinclient_shell apt-get install -y #{extrapackages}"
  environment('USER' => 'root')
end

# configure ssh and root-pw

replace_or_add 'revert_sshd_config_ipv6' do
  path "#{x2gotce_base}/chroot/etc/ssh/sshd_config"
  pattern 'AddressFamily inet'
  line 'ListenAddress ::'
end
replace_or_add 'revert_sshd_config_public_sshd' do
  path "#{x2gotce_base}/chroot/etc/ssh/sshd_config"
  pattern 'ListenAddress 127.0.0.1'
  line 'ListenAddress 0.0.0.0'
end

replace_or_add 'set root pw' do
  path "#{x2gotce_base}/chroot/etc/shadow"
  pattern 'root:'
  line "root:#{node[:x2go][:tce][:rootpassword]}:15940:0:99999:7:::"
  only_if { node[:x2go][:tce].fetch(:rootpassword, nil).nil? == false }
end

file "#{x2gotce_base}/chroot/etc/X11/xorg.conf" do
  content """
Section \"ServerFlags\"
  Option \"AutoAddDevices\" \"off\"
EndSection
Section \"InputDevice\"
        Identifier  \"Keyboard0\"
        Driver      \"kbd\"
        Option      \"XkbLayout\" \"de\"
EndSection
"""
  mode 0755
end

file "#{x2gotce_base}/chroot/etc/hostname" do
  action :delete
end

# Sessions and stuff

template "#{x2gotce_base}/etc/x2gothinclient_sessions" do
  source 'x2gothinclient_sessions.erb'
  variables(node[:x2go][:tce])
  notifies :run, 'execute[update_x2gotce]'
end
template "#{x2gotce_base}/etc/x2gothinclient_start" do
  source 'x2gothinclient_start.erb'
  variables(node[:x2go][:tce])
  notifies :run, 'execute[update_x2gotce]'
end

execute 'update_x2gotce' do
  command '/usr/sbin/x2gothinclient_update'
  user 'root'
  group 'root'
  action :nothing
end

##
## configure tftp-boot
##

['x2go'].each do |dir|
  directory "#{tftpdir}/#{dir}" do
    action :create
    mode 0755
  end
end

# ['x2go-simple-splash.png', 'x2go-splash.png'].each do |file|
#   execute "place #{file}" do
#     command "cp /usr/share/x2go/tce/tftpboot/#{file} #{tftpdir}"
#     creates "#{tftpdir}/#{file}"
#   end
# end

pxe_menu 'x2go-tce-i686' do
  section 'x2go'
  label 'X2Go ^Thin Client'
  default true
  kernel 'x2go/vmlinuz-3.2.0-4-686-pae'
  initrd 'x2go/initrd.img-3.2.0-4-686-pae'
  append "nfsroot=#{x2gotce_base}/chroot boot=nfs ro quiet splash"
end
pxe_menu 'x2go-tce-i686-debug' do
  section 'x2go'
  label 'X2Go Thin Client ^Debug'
  kernel 'x2go/vmlinuz-3.2.0-4-686-pae'
  initrd 'x2go/initrd.img-3.2.0-4-686-pae'
  append "nfsroot=#{x2gotce_base}/chroot boot=nfs ro"
end

# Copy the kernel to tftp-boot
['vmlinuz-3.2.0-4-686-pae', 'initrd.img-3.2.0-4-686-pae'].each do |file|
  execute "place #{file}" do
    command "cp #{x2gotce_base}/chroot/boot/#{file} #{tftpdir}/x2go"
    creates "#{tftpdir}/x2go/#{file}"
  end
end
