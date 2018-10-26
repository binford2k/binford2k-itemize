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

Or as a Puppet module:

```
$ puppet module install binford2k/itemize
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
$ puppet parser itemize
$ puppet parser itemize manifests
$ puppet parser itemize manifests/init.pp
$ puppet parser itemize manifests/init.pp manifests/example/path.pp
```

### Module dependency validation

If the tool can identify that you're running this on manifests within a Puppet
module, then it will validate the dependencies listed in the `metadata.json`.
By default, it will print out warnings for resources or classes that come from
modules that aren't declared as dependencies. Facts and Puppet 3.x style functions
aren't namespaced in the same way, so they cannot be identified, but Puppet 4.x
namespaced functions will trigger the same validation.

You can also use the `--external` argument. This will filter the output to only
show elements which are either global or from other modules. This can be used to
help identify how dependencies are being used.


### Programatic use

You can choose to render the output in either JSON or YAML for consumption by
other tools or testing pipelines by simply passing the `--render-as` argument:

```
$ puppet parser itemize ~/Projects/puppetlabs-apache/manifests/ --render-as json
$ puppet parser itemize ~/Projects/puppetlabs-apache/manifests/ --render-as yaml
```

It's also reasonably easy to invoke this as a library from Ruby tools. See the
`bin/puppet-itemize` script for an example.


### Example output:

Because this is static analysis prior to compilation, no variables can be
resolved.  Because of that, when a class name is calculated dynamically, any
variable parts of the name will be represented as `<??>`. See an example of that
below in the class list as `apache::mod::<??>`.

```
$ puppet parser itemize ~/Projects/puppetlabs-apache/manifests/
Warning: Undeclared module dependancy: portage::makeconf
Warning: create_resources detected. Please update to use iteration instead.
Resource usage analysis:
=======================================
>> types:
                          concat |   3
                concat::fragment |  49
                            file |  81
                            exec |   8
                     apache::mod | 134
      apache::default_mods::load |   1
                         package |  11
                            user |   1
                           group |   1
               portage::makeconf |   8
                   apache::vhost |   3
                          anchor |   1
                     apache::mpm |   8
                       file_line |   3
                         yumrepo |   1
    apache::peruser::multiplexer |   1
     apache::security::rule_link |   1
                         service |   1
           apache::custom_config |   1

>> classes:
     apache::mod::proxy_balancer |   1
          apache::confd::no_accf |   1
               apache::mod::<??> |   2
         apache::mod::authn_core |   4
         apache::mod::reqtimeout |   2
            apache::mod::actions |   2
              apache::mod::cache |   2
         apache::mod::ext_filter |   1
               apache::mod::mime |   6
         apache::mod::mime_magic |   2
            apache::mod::rewrite |   3
            apache::mod::speling |   2
             apache::mod::suexec |   2
            apache::mod::version |   2
        apache::mod::vhost_alias |   3
         apache::mod::disk_cache |   1
            apache::mod::headers |   2
               apache::mod::info |   1
            apache::mod::userdir |   1
             apache::mod::filter |   5
                apache::mod::cgi |   1
               apache::mod::cgid |   1
              apache::mod::alias |   2
         apache::mod::authn_file |   1
          apache::mod::autoindex |   1
                apache::mod::dav |   2
             apache::mod::dav_fs |   1
            apache::mod::deflate |   1
                apache::mod::dir |   2
        apache::mod::negotiation |   1
           apache::mod::setenvif |   2
      apache::mod::authz_default |   1
         apache::mod::authz_user |   1
            apache::mod::fastcgi |   2
                 apache::service |   1
            apache::default_mods |   2
     apache::default_confd_files |   1
                          apache |  39
                apache::mod::dbd |   1
               apache::mod::ldap |   1
                     apache::dev |   1
            apache::mod::prefork |   1
              apache::mod::proxy |   4
         apache::mod::proxy_http |   2
                  apache::params |   2
      apache::mod::socache_shmcb |   1
                 apache::package |   1
                apache::mod::php |   1
             apache::mod::python |   1
                apache::mod::ssl |   2
          apache::mod::auth_kerb |   1
               apache::mod::wsgi |   1
          apache::mod::passenger |   3

>> functions:
                      versioncmp |  47
                 ensure_resource |   3
                 inline_template |   2
                        template |  94
                            fail |  58
                     validate_re |  20
                   validate_bool |  23
                        regsubst |   6
                         defined |  55
                is_absolute_path |   1
       validate_apache_log_level |   2
                         warning |  16
                        is_array |   9
                          concat |   2
          validate_absolute_path |   2
                            pick |  11
                 validate_string |   4
                  validate_array |   4
                        downcase |   4
                   validate_hash |   7
                       is_string |   2
                         has_key |   4
                         is_bool |   1
                           split |   2
                           empty |  20
                    enclose_ipv6 |   1
                          suffix |   2
                       any2array |   2
                         is_hash |   5
                           merge |   1
                create_resources |   1
```


## Limitations

This is super early in development and has not yet been battle tested.


## Disclaimer

I take no liability for the use of this tool.


Contact
-------

binford2k@gmail.com
