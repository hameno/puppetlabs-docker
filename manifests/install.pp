# == Class: docker
#
# Module to install an up-to-date version of Docker from a package repository.
# This module currently works only on Debian, Red Hat
# and Archlinux based distributions.
#
class docker::install {
  $docker_start_command = $docker::docker_start_command
  if $::osfamily {
    assert_type(Pattern[/^(Debian|RedHat|Archlinux|Gentoo)$/], $::osfamily) |$a, $b| {
      fail('This module only works on Debian or Red Hat based systems or on Archlinux as on Gentoo.')
    }
  }
  if $docker::version and $docker::ensure != 'absent' {
    $ensure = $docker::version
  } else {
    $ensure = $docker::ensure
  }

  if $docker::manage_package {

    if empty($docker::repo_opt) {
      $docker_hash = {}
    } else {
      $docker_hash = { 'install_options' => $docker::repo_opt }
    }

    if $docker::package_source {
      case $::osfamily {
        'Debian' : {
          $pk_provider = 'dpkg'
        }
        'RedHat' : {
          $pk_provider = 'rpm'
        }
        'Gentoo' : {
          $pk_provider = 'portage'
        }
        default : {
          $pk_provider = undef
        }
      }

      case $docker::package_source {
        /docker-engine/ : {
          ensure_resource('package', 'docker', merge($docker_hash, {
            ensure   => $ensure,
            provider => $pk_provider,
            source   => $docker::package_source,
            name     => $docker::docker_engine_package_name,
          }))
        }
        /docker-ce/ : {
          ensure_resource('package', 'docker', merge($docker_hash, {
            ensure   => $ensure,
            provider => $pk_provider,
            source   => $docker::package_source,
            name     => $docker::docker_ce_package_name,
          }))
        }
        default : {}
      }

    } else {
      ensure_resource('package', 'docker', merge($docker_hash, {
        ensure => $ensure,
        name   => $docker::docker_package_name,
      }))
    }
  }
}
