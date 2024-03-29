class riakcs($riak_ip = "127.0.0.1", $riakcshost = $fqdn, $stanchion_ip = "127.0.0.1") inherits riak {
	$package_filename = "riak-cs_1.1.0-1_amd64.deb"
	$package_location = "/tmp/${package_filename}"
	$nodename = "riak-cs@${riakcshost}"

    file {
        "${package_location}":
            ensure => present,
            mode => 660,
            source => "puppet:///modules/riakcs/${package_filename}"
    }

    package {
        "riak-cs":
            provider => "dpkg",
            ensure => latest,
            source => $package_location,
            require => File[$package_location]
    }

    service {
        "riak-cs":
            ensure => running,
            require => [Package["riak-cs"], Class["riak"]],
            hasrestart => true,
            hasstatus => true
    }

	file {
		"/etc/riak-cs/app.config":
			ensure => present,
			mode => 644,
			content => template('riakcs/app.config.erb'),
			require => Package["riak-cs"],
			notify => Service["riak-cs"],
	}

	file {
		"/etc/riak-cs/vm.args":
			ensure => present,
			mode => 644,
			content => template('riakcs/vm.args.erb'),
			require => Package["riak-cs"],
			notify => Service["riak-cs"],
	}
}
