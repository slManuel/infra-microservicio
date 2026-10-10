# nodos

Un node group por clúster, nombre `<cluster_name>-nodos` y launch template con prefijo exclusivo. Recibe tipo de instancia y disco del módulo común, fijados en cada entorno a t3.medium y 20 GiB gp3 cifrado. Mantiene IMDSv2, AL2023 y un nodo. No aloja Jenkins/Vault.
