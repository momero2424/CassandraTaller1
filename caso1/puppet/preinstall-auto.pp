
# Instala el paquete de preinstalacion
package {'oracle-rdbms-server-12cR1-preinstall':
  ensure      => installed
}

# Pone la contrasena del usuario
user { 'oracle': 
  ensure   => present,
  password => 'datum2016',
  require => Package['oracle-rdbms-server-12cR1-preinstall'],
}

# El anterior comando no pone bien la contrasena pero es a nivel de sistema operativo que el comando no lo hace
exec {'contrasena':
  command     => "echo datum2016 | passwd oracle --stdin",
  path        => ['/usr/bin', '/bin'],
  require     => User['oracle'],
}

# Cambia la linea del archivo
file { '/etc/security/limits.d/90-nproc.conf':
  ensure => present,
  require => Package['oracle-rdbms-server-12cR1-preinstall'],
}

file_line { 'Reemplazar /etc/security/limits.d/90-nproc.conf':
  path => '/etc/security/limits.d/90-nproc.conf',  
  line => '* - nproc 16384',
  #match   => '\s+soft\s+nproc\s+1024',
  match => '^\*',
  require => File['/etc/security/limits.d/90-nproc.conf'],
}

# Cambia la linea del archivo
file { '/etc/selinux/config':
  ensure => present,
  require => Package['oracle-rdbms-server-12cR1-preinstall'],
}

file_line { 'Reemplazar /etc/selinux/config':
  path => '/etc/selinux/config',  
  line => 'SELINUX=permissive',
  match   => '^SELINUX=',
  require => File['/etc/selinux/config'],
}

# Deshabilita iptables
service { 'disable_iptables':
  name => 'iptables',
  ensure => 'stopped',
  enable => false,
}


# Crea el directorio db_1
exec {'db_1':
  command     => "mkdir -p /u01/app/oracle/product/12.1.0.2/db_1",
  path        => '/bin',
  require     => Package['oracle-rdbms-server-12cR1-preinstall'],
}

# Cambia los permisos del directorio
file {'/u01':
  ensure      => directory,
  owner       => 'oracle',
  group       => 'oinstall',
  mode        => '775',
  require     => Exec['db_1'],
  recurse    => true,
}

# Escribe en el bash_profile las variables de entorno
$lineas = {
  '.bash_profile_1' => {
    line => 'export TMP=/tmp',
    require => Package['oracle-rdbms-server-12cR1-preinstall'],
  },
  '.bash_profile_2' => {
    line => 'export TMPDIR=$TMP',
    require => File_line['.bash_profile_1'],
  },
  '.bash_profile_3' => {
    line => 'export ORACLE_HOSTNAME=localhost',
    require => File_line['.bash_profile_2'],
  },
  '.bash_profile_4' => {
    line => 'export ORACLE_UNQNAME=cdb1',
    require => File_line['.bash_profile_3'],
  },
  '.bash_profile_5' => {
    line => 'export ORACLE_BASE=/u01/app/oracle',
    require => File_line['.bash_profile_4'],
  },
  '.bash_profile_6' => {
    line => 'export ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/db_1',
    require => File_line['.bash_profile_5'],
  },
  '.bash_profile_7' => {
    line => 'export ORACLE_SID=cdb1',
    require => File_line['.bash_profile_6'],
  },
  '.bash_profile_8' => {
    line => 'export PATH=/usr/sbin:$PATH',
    require => File_line['.bash_profile_7'],
  },
  '.bash_profile_9' => {
    line => 'export PATH=$ORACLE_HOME/bin:$PATH',
    require => File_line['.bash_profile_8'],
  },
  '.bash_profile_10' => {
    line => 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib',
    require => File_line['.bash_profile_9'],
  },
  '.bash_profile_11' => {
    line => 'export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib',
    require => File_line['.bash_profile_10'],
  },
}

$lineas_defaults = {
  path => '/home/oracle/.bash_profile',
}

create_resources(file_line, $lineas, $lineas_defaults)
