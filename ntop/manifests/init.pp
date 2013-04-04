class ntop ($passwd_admin = ''){

	case $::lsbmajdistrelease  {


	6: {
           $ntop_conf = ["ntop-CentOS-6",]
           $var_db  = ["/var/lib/ntop/ntop_pw.db",]
	   $ntop_daemon = ["ntop-daemon-6",]
	   $dependencias = [
       		"ntop",
	]
		}

	 5: {
	   $ntop_conf = ["ntop-CentOS-5",]
	   $var_db  = ["/var/ntop/ntop_pw.db",]
 	   $ntop_daemon = ["ntop-daemon-5",]
	   $dependencias = [
		"ntop",
	]
		}
	}	


if $::ntop_monit == 'ativado' {

   package { $dependencias:
      ensure => present, 
	}

   file { 
      "/etc/ntop.conf":
      ensure => present,
      content => template("ntop/${ntop_conf}.erb"),
      require => Package[$dependencias];

     "/etc/init.d/ntop":
      ensure => present,
      content => template("ntop/${ntop_daemon}.erb"),
      mode => 755,
      group => root,
      owner => root,
      require => [Package[$dependencias],File["/etc/ntop.conf"]];
	}

   exec {"ntop-pass-admin":
      path => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
      command => "ntop -A --set-admin-password=${passwd_admin} && chown ntop:ntop -R ${var_db}", 
      creates => "${var_db}",
      user => root,
      notify => Service["ntop"],
      require => [File["/etc/ntop.conf"],File["/etc/init.d/ntop"]],
      	}

   service {"ntop":
      ensure => 'running',
      enable => 'true', 
      hasstatus => true,
      hasrestart => true,
      require => [File["/etc/init.d/ntop"],File["/etc/ntop.conf"],Package[$dependencias],Exec["ntop-pass-admin"]],

	}

  } elsif $::ntop_monit == 'desativado' { 

   service { "ntop":
      ensure => 'stopped',
      enable => 'false',
	}
    }
}
