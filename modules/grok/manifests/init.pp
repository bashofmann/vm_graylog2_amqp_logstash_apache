class grok {
    package {
        "bison":
            ensure => present;
        "ctags":
            ensure => present;
        "flex":
            ensure => present;
        "gperf":
            ensure => present;
        "libevent-dev":
            ensure => present;
        "libpcre3-dev":
            ensure => present;
        "libtokyocabinet-dev":
            ensure => present;
    } ->
    file {
       "/opt/grok":
           ensure => directory,
           mode => '0755';
    } ->
    exec {
        "download grok":
           command => "/usr/bin/wget --no-check-certificate --output-document=/opt/grok/grok-1.20110630.1.tar.gz http://semicomplete.googlecode.com/files/grok-1.20110630.1.tar.gz",
           unless => "/usr/bin/test -r /opt/grok/grok-1.20110630.1.tar.gz" ;
    } ->
    exec {
         "unzip grok":
            command => "/bin/tar --directory /opt/grok -xzf /opt/grok/grok-1.20110630.1.tar.gz",
            unless => "/usr/bin/test -d /opt/grok/grok-1.20110630.1" ;
    } ->
    exec {
        "compile grok":
            command => "/usr/bin/make && /usr/bin/make install",
            cwd => "/opt/grok/grok-1.20110630.1";
    }
}