# Puppet Itemize

Count the number of types, classes, functions used in manifest(s)

Run this command with a space separated list of either manifest file paths, or
directories containing manifests. If omitted, it will default to inspecting all
manifests in the manifests directory, so you can just run this in the root of a
Puppet module and it will do the right thing.

## Installation

Install as either a gem:

```
$ gem install puppet-itemize
```

Or as a Puppet module. Note that the module has a few gem dependencies. Enforce
the `puppet_itemize::dependencies` class on each machine you plan to run this
tool on.

```
$ puppet module install binford2k/puppet_itemize
```

## Usage

Depending on how it's installed, there are two ways to run this. As the command
line tool, `puppet-itemize`, or as the Puppet subcommand, `puppet parser itemize`.
There are slight, but mostly insignificant differences in behaviour based on
which way you run it.

Basically, just invoke the tool with a list of manifest(s), or directories of
manifests, or just let it default to the `./manifests` directory.

If you'd like machine parsable outputs, then use the `--render-as` flag and
pass in a format of `json` or `yaml`.

### Command-line examples:
Available when installed via either gem or Puppet module.

```
$ puppet-itemize
$ puppet-itemize manifests
$ puppet-itemize manifests/init.pp
$ puppet-itemize manifests/init.pp manifests/example/path.pp
```

### Puppet subcommand examples:
Available only when installed via Puppet module.

```
$ puppet parser itemize"
$ puppet parser itemize manifests"
$ puppet parser itemize manifests/init.pp
$ puppet parser itemize manifests/init.pp manifests/example/path.pp
```

### Example output:
```
$ puppet parser itemize ~/Projects/pltraining-classroom/manifests/
Itemizing [===========================================]
Resource usage analysis:
==========================================================
 types:
                                                file   35
                                            defaults    8
                                             package   19
                                         windows_env    2
                                                exec   21
                                             dirtree    1
                                                host    1
                                              augeas    1
                                         dockeragent    2
                                   puppet_enterprise    2
                                    pe_hocon_setting    2
                                           rbac_user    1
                                              docker    3
                                         ini_setting    5
                                             service    1
                                                cron    1
                                             vcsrepo    1
                                           hash_file    1
                                             showoff    1
                                              notify    2
                                             stunnel    1
                                           selmodule    1
                                                user    2
                                             yumrepo    1
                                              reboot    2
                                  dsc_windowsfeature    1
                                       dsc_xaddomain    1
                                        dsc_xadgroup    1
                                         dsc_xaduser    1
                                             archive    1
                                           fileshare    1
                                                 acl    1
                                            registry    2
                                      registry_value    2
                                   chocolateyfeature    1
                                           classroom    1
 classes:
                                                 git    2
                                              docker    2
                                         dockeragent    1
                 classroom_legacy::course::architect    1
              classroom_legacy::course::fundamentals    1
              classroom_legacy::course::practitioner    1
                                  classroom::virtual    9
                                    classroom::facts    7
                          classroom::master::showoff    9
                                           classroom   24
                                              master    9
                                     reporting_tools    2
                                               hiera    2
                                               agent    7
                                               hosts    1
                                             windows    8
                                             stunnel    1
                                    classroom_legacy    1
                                             showoff    2
                                              legacy    1
                                        dependencies    2
                                            rubygems    2
                                           dashboard    1
                           classroom::master::tuning    1
                                            deployer    1
                                        perf_logging    1
                                               gitea    1
                                       puppetfactory    1
                      classroom::master::codemanager    1
                                               proxy    1
                                            packages    1
                                        postfix_ipv4    1
                                    classroom::gemrc    1
                                              augeas    1
                                            geotrust    1
                                     password_policy    1
                                         disable_esc    1
                                               alias    1
                                          enable_rdp    1
                                           userprefs    1
                                                 npp    1
                        classroom::windows::adserver    1
 functions:
                                              method    4
                                      assert_private   19
                                             require    5
                                             include   28
                                               chomp    2
                                                file    2
                                             flatten    1
                                            template    2
                                                 epp    4
                                             defined    1
                                          versioncmp    4
                                                fail    7
                                                pick    6
                                            regsubst    3
                                      is_domain_name    1
                                               split    1
                                                 dig    1
                                              String    1
```

## Limitations

This is super early in development and has not yet been battle tested. It's also
currently godawful slow and a teeny bit error prone because it's invoking
`puppet parser` each time and then parsing out the AST. It does not yet understand
defined types, nor how to resolve dynamically declared classes. This is next on the
roadmap to fix.


## Disclaimer

I take no liability for the use of this tool.

Contact
-------

binford2k@gmail.com
