class riakcs::stanchion($stanchionhost = $fqdn) {
	$package_filename = "stanchion_1.0.1-1_amd64.deb"
	$package_location = "/tmp/${package_filename}"
	$nodename = "stanchion@${stanchionhost}"

	package {
		"stanchion":
			provider => "dpkg",
			ensure => latest,
			source => $package_location,
			require => File[$package_location]
	}

    file {
        "${package_location}":
            ensure => present,
            mode => 660,
            source => "puppet:///modules/riakcs/${package_filename}"
    }

	service {
		"stanchion":
			ensure => running,
			require => [Package["stanchion"], Class["riak"]],
			hasrestart => true,
			hasstatus => true,
	}

	file {
		"/etc/stanchion/app.config":
			ensure => present,
			mode => 644,
			content => template('riakcs/stanchion/app.config.erb'),
			require => Package["stanchion"],
			notify => Service["stanchion"],
	}

	file {
		"/etc/stanchion/vm.args":
			ensure => present,
			mode => 644,
			content => template('riakcs/stanchion/vm.args.erb'),
			require => Package["stanchion"],
			notify => Service["stanchion"],
	}

}