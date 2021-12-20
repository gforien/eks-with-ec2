# eks-with-ec2

## Étapes
- [x] recréer une instance EC2 complète (40 min)
    - [x] **test:** voir l'ensemble des ressources provisionnées dans la console AWS
- [x] améliorations (+ 30 min)
    - [x] extraire `KEYNAME` dans une variable d'environnement
    - [x] récupérer l'ip publique dans une output value
    - [x] récupérer le DNS public dans une output value<br>
          Voir ces pages documentation Hashicorp sur [les instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#public_dns)
          et sur [les VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#enable_dns_hostnames)
    - [x] augmenter le nombre d'instances avec `count`
    - [x] **test:** se connecter en SSH aux multiples instances avec leur DNS
- [x] installer docker
    - [x] utiliser `newgrp` pour éviter de se déconnecter après l'installation<br>
          Voir [cette réponse sur StackOverflow](https://stackoverflow.com/a/49565797/6402299)
    - [x] **test:** lancer un container → `docker run -d hello-world`
- [x] installer k8s
    - [x] utiliser des instances Ubuntu plutôt que Amazon Linux (#1)
    - [x] exposer les ports
    - [x] **tests:** en tant qu'utilisateur standard (!= root)
        - [x] `docker ps -a`
        - [x] `kubeadm version`
        - [x] `service kubelet status`
        - [x] `kubectl version`
- [x] créer le cluster depuis le master node
    - [x] sur quelle adresse IP le master écoute-t-il ?
        - IP publique ? on pourrait avec
        ```sh
            $ public_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
            $ kubeadm init --apiserver-advertise-address="$public_ip"
        ```
        - IP privée ? Plus sécurisé, et ça ne devrait pas poser de problème car nos VM
          sont toutes dans le même VPC.
    - [x] **tests:**
        - [x] Vérifier la configuration créée `sudo ls -l /etc/kubernetes/admin.conf`
- [x] différencier le master et les worker dans `main.tf`
- [ ] rejoindre le cluster depuis les worker nodes
    - [x] Tests de connectivité
        - [x] vérifier le firewall `sudo ufw status → inactive`
        - [x] ajouter manuellement une règle `All ICMPv4` et ping entre les différentes VM
        - [x] vérifier que les VM peuvent se pinger sur leur IP publique/privée
    - [x] avoir un token prédéterminé pour pouvoir faire `kubeadm join --token=XXX`<br>
          Voir l'issue [#9](https://github.com/gforien/eks-with-ec2/issues/9)
    - [ ] quelle stratégie pour que les workers rejoignent le master ?<br>
          Voir l'issue [#10](https://github.com/gforien/eks-with-ec2/issues/10)
- [ ] accéder au cluster depuis l'extérieur<br>
      Voir l'issue [#7](https://github.com/gforien/eks-with-ec2/issues/7)
    - [ ] comment sécuriser ce point d'entrée avec un certificat ?

## Notes
- Nécessite une clé SSH pré-existante pour se connecter
- Nécessite une variable d'environnement `TF_VAR_AWS_KEYNAME`
  (`$env:TF_VAR_AWS_KEYNAME` avec Windows Powershell)
```powershell
$env:TF_VAR_AWS_KEYNAME = 'XXXXXXXX'
terraform apply -var token=$(.\Get-K8sToken.ps1)
```


###### Gabriel Forien<br>INSA Lyon
