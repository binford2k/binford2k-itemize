class puppet_itemize::dependencies {
  package ['tty-table', 'tty-progressbar']:
    ensure   => present,
    provider => gem,
  }
}

