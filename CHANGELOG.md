# v0.0.3

* Parse more syntax edge cases without exploding. We can't evaluate everything
  because it's pre-compilation, but do what we can or just use a marker token.
* Only print out undeclared module warnings once per module.
* Added the option for debug logging of files as they're evaluated.
* Improved the external element detection logic.


# v0.0.2

* Add namespace validation. This will now warn you if you're using elements from
  modules which have not been declared as dependencies.
* Allow you to filter to external resources only.


# v0.0.1

* Initial release
