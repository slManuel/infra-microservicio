# cluster

EKS privado Kubernetes 1.36 y acceso del administrador existente. Recibe el nombre exclusivo del entorno; EKS crea su propio SG y se añade una regla TCP 443 desde el SG compartido de Jenkins, sin CIDR público.
