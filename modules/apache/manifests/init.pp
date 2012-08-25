class apache {
    Exec['apt-get update'] -> Package <| |>

  package {
    "apache2":
        ensure => present;
    "php5-dev":
        ensure => present;
    "php5-cli":
        ensure => present;
    "libapache2-mod-php5":
        ensure => present;
  }

  service { "apache2":
    ensure => running,
    require => Package["apache2"],
  }
}
