# Infraestructura EKS del microservicio

Segundo clúster de la evaluación: `prueba-devops-microservicio`, Kubernetes1.36, API exclusivamente privada, un nodo t3.medium AL2023 en us-east-1a. Reutiliza VPC/subredes de `infra-red-compartida` mediante estado remoto S3. No se aplicó todavía; 16 recursos administrados definidos explícitamente, sin locals/for/for_each/dynamic.

| Módulo | Responsabilidad |
|---|---|
| identidad_base | Roles IAM EKS/nodos y asociaciones de políticas |
| cluster | EKS, acceso del administrador existente y entrada TCP443 al API desde SG tools |
| red_pods | CNI, Pod Identity Agent, rol y asociación CNI antes de nodos |
| nodos | Launch template cifrado/IMDSv2 y node group único |

Estado S3: bucket protegido `tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis`, clave `microservicio/terraform.tfstate`, cifrado y bloqueo S3. Nunca copiar otro estado sobre esta clave. El workflow OIDC conserva rol/subject actuales; valida catálogo fijado, subredes, plan guardado y allowlist exacta. Rechaza updates, deletes y replacements en el alcance inicial; aplica **el mismo** plan y valida main antes. Logs muestran salida/exit code original; planes y diagnósticos privados retención 1 día, no publicar estados.

Temporalmente sólo checks: `AWS_DEPLOY_ENABLED` debe ser `true` para permitir deploy. Mantener ausente/false mientras AWS bloquea EC2/Fleet. No activar ni relanzar hasta resolver soporte y autorizar reanudación. La regla de API privada necesita la ampliación estrecha de IAM preparada en el bootstrap; su aplicación está pendiente con el estado bootstrap existente, nunca estado vacío. No se cambia la API a pública ni se crea administrador EC2.

Validación local: `terraform fmt -check -recursive`, `terraform init -backend=false -lockfile=readonly`, `terraform validate`. Éxito de validate no prueba permisos, catálogo vivo, cuotas o creación de recursos. El catálogo AWS6.68.0/TF1.15.9/AMI/addons se verificó previamente para herramientas; el workflow vuelve a comprobar compatibilidad antes del plan real.

Aplicación y micro: [despliegue Jenkins/Vault](https://github.com/slManuel/despliegue-jenkins-vault) y [servicio Java](https://github.com/slManuel/devops-java-service). Los manifiestos de aplicación son propios, sin Helm. VSO/CSI vienen de upstream versionado y se instalan en el segundo clúster mediante Kustomize.

Los recursos, NLB de aplicación y conectividad privada requieren validación real después de desbloquear AWS. Dos réplicas sobre un solo nodo no dan tolerancia a la pérdida de nodo; configuración de evaluación, no HA de producción.
