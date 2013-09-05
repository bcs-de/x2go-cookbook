# Cookbook Name:: x2go
# Recipe:: common
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

##
## Activate the X2Go-Repository for debian packages
##

apt_repository "x2go-stable" do
  uri "http://packages.x2go.org/debian"
  distribution "wheezy"
  components ["main"]
  action :add
end

apt_package "x2go-keyring" do
  #action :upgrade
  action :install
  options "--force-yes"
  notifies :run, "execute[apt-get update]", :immediately
end

