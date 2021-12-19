# eks-with-ec2

## Étapes
- [x] recréer une instance EC2 complète (40 min)
    - [x] **test:** voir l'ensemble des ressources provisionnées dans la console AWS
- [x] améliorations (+ 30 min)
    - [x] extraire `KEYNAME` dans une variable d'environnement
    - [x] récupérer l'ip publique dans une output value
    - [x] récupérer le DNS public dans une output value<br>Voir<br>
          https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#public_dns
          https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#enable_dns_hostnames
    - [x] augmenter le nombre d'instances avec `count`
    - [x] **test:** se connecter en SSH aux multiples instances avec leur DNS
- [x] installer docker
    - [x] utiliser `newgrp` pour éviter de se déconnecter après l'installation<br>Voir
          https://stackoverflow.com/a/49565797/6402299
    - [x] **test:** lancer un container `hello-world`
- [ ] installer k8s
    - [ ] utiliser des instances Ubuntu plutôt que Amazon Linux (#1)
    - [x] exposer les ports

- [ ] faire un cluster, à la main
- [ ] faire un cluster, avec terraform
- [ ] y accéder depuis l'extérieur

## Notes
- Nécessite une clé SSH pré-existante pour se connecter
- Nécessite une variable d'environnement `TF_VAR_AWS_KEYNAME`
  (`$env:TF_VAR_AWS_KEYNAME` avec Windows Powershell)


###### Gabriel Forien<br>INSA Lyon
