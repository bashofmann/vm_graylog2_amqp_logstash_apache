class rabbitmq {
	$data_dir = "/data/rabbitmq"
	$user = "rabbitmq"

    Exec['apt-get update'] -> Package <| |>

    exec {
        "Import key":
            path        => '/bin:/usr/bin',
            environment => 'HOME=/root',
            command     => "wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc && apt-key add rabbitmq-signing-key-public.asc && rm rabbitmq-signing-key-public.asc",
            user        => 'root',
            group       => 'root',
           # unless      => "apt-key list | grep $keyid",
            logoutput   => on_failure;
    } ->
    exec {
        "/bin/echo 'deb http://www.rabbitmq.com/debian/ testing main' >> '/etc/apt/sources.list'":
            unless => "/bin/grep -qFx 'deb http://www.rabbitmq.com/debian/ testing main' '/etc/apt/sources.list'";
    } ->
    exec {
        'apt-get update for rabbitmq':
            command => '/usr/bin/apt-get update';
    } ->
    package {
        "erlang-nox":
            ensure => "present";
        "rabbitmq-server":
            ensure => "present";
    } ->
    exec {
	    "install management plugin":
	        command => "/usr/sbin/rabbitmq-plugins enable rabbitmq_management",
	        user => "root",
	        unless => "/usr/sbin/rabbitmq-plugins list | grep 'rabbitmq_management ' | grep [E]",
	        notify => Service["rabbitmq-server"];
	} ->
	file {
		"$data_dir":
			ensure => directory,
			owner => $user,
			group => $user;
		"$data_dir/mnesia":
			ensure => directory,
			owner => $user,
			group => $user;
		"/etc/rabbitmq/rabbitmq-env.conf":
			ensure => file,
			content => template("rabbitmq/rabbitmq-env.conf.erb");
	} ->
	service {
		"rabbitmq-server":
			ensure => running,
			enable => true;
	}

}