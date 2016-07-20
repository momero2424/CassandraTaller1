# num_nodo viene del facter de vagrant
# total_nodes viene del facter de vagrant
# hosts viene del facter de vagrant

# Crea el usuario
user { 'datum': 
  ensure   => present,
  password => 'datum',
  managehome  => true,
}

# El anterior comando no pone bien la contrasena pero es a nivel de sistema operativo que el comando no lo hace
exec {'contrasena':
  command     => "echo datum | passwd datum --stdin",
  path        => ['/usr/bin', '/bin'],
  require     => User['datum'],
}

# Crea la carpeta para el nodo
file {"/home/datum/node${num_nodo}":
  ensure      => directory,
  require     => Exec['contrasena'],
}

file {"/home/datum/node${num_nodo}/cassandra-2.1.14":
  ensure      => directory,
  require     => File["/home/datum/node${num_nodo}"],
}

# Instala el paquete OpenJDK
package {'java-1.8.0-openjdk':
  ensure      => installed
}

# Modifica el archivo hosts
file_line { 'hosts':
  path => '/etc/hosts',  
  line => $hosts,
}

# Descarga cassandra
exec{ 'descarga_cassandra':
  command     => "wget -O /home/datum/node${num_nodo}/cassandra-2.1.14.tar.gz http://archive.apache.org/dist/cassandra/2.1.14/apache-cassandra-2.1.14-bin.tar.gz",
  path        => ['/usr/bin','/bin'],
  timeout     => 1200,
  require     => File["/home/datum/node${num_nodo}"],
}


# Descomprime cassandra
exec { "descomprime_cassandra":
  command     => "/bin/tar -zxvf /home/datum/node${num_nodo}/cassandra-2.1.14.tar.gz",
  cwd         => "/home/datum/node${num_nodo}/cassandra-2.1.14",
  require     => [File["/home/datum/node${num_nodo}/cassandra-2.1.14"], Exec['descarga_cassandra']],
}
