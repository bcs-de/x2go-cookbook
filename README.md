x2go Cookbook
=============
This cookbook sets up x2go-servers.

There are two kinds of servers (and therefor at least two recipes):

 1. x2goserver where users can connect to with x2goclient and work remotely.
    The recipe x2go::server aims to do this.
 2. X2Go Thinclient Environment servers providing the infrastructure to boot
    diskless clients from network and start x2goclient.
    The recipe for that is x2go::thinclientenv.

Not that the X2Go discourage running both roles on one server. And we have no
reason to say otherwise.

Requirements
------------

#### operating system
This cookbook is currently developed on Debian 7.1 (wheezy). It should also
work on Ubuntu LTS 12.04 or higher but thats speculation.

Supporting RPM-based distributions is currently not on my roadmap but patches
are accepted.

#### packages
The recipes install what they need.

#### cookbooks
To provide the netboot environment for the thinclients, the
thinclientenv-recipe needs <em>nfs</em>- and <em>tftp</em>-cookbooks.

#### environment
To make your diskless clients boot the X2Go-TCE you have to configure your
dhcp-server to send them to the server with the x2go::thinclientenv recipe.
That step is not (yet) done by the x2go-cookbook.

Attributes
----------

#### x2go::thinclientenv
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['x2go']['tce']['basedir']</tt></td>
    <td>Path</td>
    <td>Where to install the chroot and nfs-root for the thinclient-environment</td>
    <td><tt>/srv/x2gothinclient</tt></td>
  </tr>
  <tr>
    <td><tt>['x2go']['tce']['rootpassword']</tt></td>
    <td>String</td>
    <td>Hashed version of the root password for the thinclients. Can be nil.</td>
    <td><tt>[nil]</tt></td>
  </tr>
  <tr>
    <td><tt>['x2go']['tce']['extra_packages']</tt></td>
    <td>List of string</td>
    <td>Extra packages to install into the environment</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['x2go']['tce']['sessions']</tt></td>
    <td>List of hashs</td>
    <td>Sessions for x2goclient. For example (as json): <pre>
        [
            {
                "name": "ltsp02",
                "command": "KDE",
                "host": "ltsp02.bcs.bcs",
                "autostart": "true",
                "fullscreen": "true"
            }
        ]
    </pre></td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['x2go']['tce']['config']['sessionedit']</tt></td>
    <td>Boolean</td>
    <td>Whether users are allowed to edit the sessions on the thinclients.
(Changes are lost on restart of the client.)</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### x2go::default
The default recipe currently does nothing.


#### x2go::server

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[x2go::server]"
  ]
}
```

#### x2go::thinclientenv
TODO

Contributing
------------
This is a public cookbook currently in the stove. So the usual github+opschef
steps apply for now:

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. <del>Write tests for your change (if applicable)</del>
5. <del>Run the tests, ensuring they all pass</del> Test your changes:-)
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Arnold Krille <a.krille@b-c-s.de> for bcs kommunikationslösungen

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

