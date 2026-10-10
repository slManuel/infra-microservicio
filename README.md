# Infraestructura del microservicio

Prepara tres EKS privados distintos para la aplicación Java. Reutiliza la red y Jenkins/Vault compartidos; no instala la aplicación.

| Rama | Root Terraform | Clúster | Bucket de estado |
|---|---|---|---|
| `develop` | [`environments/development/`](environments/development/) | `prueba-devops-microservicio-development` | `tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis` |
| `qa` | [`environments/qa/`](environments/qa/) | `prueba-devops-microservicio-qa` | `tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis-qa` |
| `main` | [`environments/production/`](environments/production/) | `prueba-devops-microservicio-production` | `tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis-production` |

Cada bucket guarda `microservicio/<entorno>/terraform.tfstate`, con cifrado y bloqueo independiente.

## Carpetas

- `environments/`: tres puntos de entrada, cada uno con backend, provider, variables, outputs y lockfile.
- Raíz (`main.tf`, `data.tf`, `variables.tf`): módulo común llamado por los tres roots; no desplegar desde aquí.
- `modules/iam_roles`, `cluster`, `red_pods`, `nodos`: identidades, EKS/acceso privado, CNI/Pod Identity y workers.
- `.github/workflows`, `scripts`, `tests`: checks, plan/apply manual y controles probados con mocks.

Cada entorno declara 16 recursos: EKS 1.36, roles propios, API privada accesible desde Jenkins, dos add-ons y un nodo `t3.medium` con 20 GiB gp3 cifrado. Clústeres, roles, node groups, plantillas y estados tienen nombres distintos. Los tres sumarían 48 recursos, tres control planes y tres nodos con costo recurrente. Un nodo por entorno no ofrece HA. Terraform es explícito, sin locals/for/for_each.

## Flujo

`feature/* → PR develop → checks → merge/plan development → apply manual`. El usuario decide avanzar mediante PR `develop → qa` y después `qa → main`. Cada destino genera **su propio plan**; nunca se aplica el plan de otro entorno.

Las ramas develop, qa y main están publicadas con la configuración de sus respectivos entornos. Falta configurar protección/revisores remotos.

## Workflows

**2 workflows, 3 jobs, 24 pasos:** `terraform.yml` tiene checks (6) → plan (9); `terraform-apply.yml` tiene apply (9).

Push a develop/qa/main o ejecución manual genera plan solo con `AWS_DEPLOY_ENABLED=true`. PR hacia esas ramas solo valida los tres roots, sin OIDC. Apply requiere ejecución manual en la rama correspondiente y el ID del run, commit vigente y SHA-256 del plan. Comprueba también rama, entorno, bucket y clave; no vuelve a planificar. Plan/apply se serializan por rama; artefactos privados duran un día.

| Job `checks`: paso | Función |
|---|---|
| 1. Checkout | Obtiene el código. |
| 2. Setup Terraform | Instala Terraform 1.15.9. |
| 3. Comprobar formato | Revisa el formato de raíz y módulos sin modificar archivos. |
| 4. Inicializar sin backend | Prepara módulo común y los tres roots sin backend, con lockfiles de proveedores fijos. |
| 5. Validar | Valida los tres roots y prueba con mocks que clústeres/node groups son distintos. |
| 6. Probar aprobación | Ejecuta las pruebas del control de planes aprobados. |

| Job `plan`: paso | Función |
|---|---|
| 1. Checkout | Obtiene el código. |
| 2. Setup Terraform | Instala Terraform 1.15.9. |
| 3. Autenticación OIDC | Asume el rol AWS del proyecto con credenciales temporales. |
| 4. Comprobar rol vinculado | Comprueba su lectura y distingue un rol ausente de un acceso denegado. |
| 5. Comprobar catálogo y subredes | Verifica versiones de add-ons, AMI y subredes privadas contra el estado de red. |
| 6. Inicializar y validar | Conecta con el backend S3 y valida sin modificar el lockfile. |
| 7. Planificar y comprobar alcance | Guarda plan/log y solo admite los recursos autorizados con acciones create/no-op. |
| 8. Registrar plan | Registra rama, entorno, bucket, clave S3, ID del run, intento, commit y SHA-256 del plan. |
| 9. Guardar plan privado | Incluso ante fallo, intenta conservar plan, metadatos y log disponibles durante 1 día. |

| Job `apply`: paso | Función |
|---|---|
| 1. Checkout | Obtiene el código. |
| 2. Setup Terraform | Instala Terraform 1.15.9. |
| 3. Verificar aprobación y descargar | Comprueba origen, ejecución exitosa, commit vigente de la rama, intento, metadatos, entorno, bucket, clave S3 y hash del plan elegido. Rechaza un plan de otro entorno. |
| 4. Autenticación OIDC | Asume el rol AWS del proyecto con credenciales temporales. |
| 5. Inicializar y validar | Conecta con el backend existente y valida sin modificar el lockfile. |
| 6. Comprobar rama | Verifica de nuevo que la rama elegida apunta al commit de la ejecución. |
| 7. Aplicar plan guardado | Aplica el archivo aprobado sin generar otro plan y registra el resultado. |
| 8. Verificar infraestructura | Comprueba por API AWS clúster privado, grupos de nodos y add-ons activos; no valida pods. |
| 9. Guardar diagnóstico | Incluso ante fallo, intenta conservar apply.log y errored.tfstate disponibles durante 1 día. |

## Estado y validación

Código publicado, **sin despliegue AWS**. El bootstrap debe crear los buckets QA/production y aplicar sus permisos/OIDC actualizados; requiere recuperar su estado existente. La CLI local no tiene credenciales y los nodos de herramientas presentaron fallo de cuota Fleet. El workflow publicado separa plan y aprobación manual del apply; AWS_DEPLOY_ENABLED permanece sin habilitar.

Se validaron los tres roots, tres planes simulados y controles de aprobación. Los mocks no comprueban cuotas, permisos ni conectividad AWS. Comprobar la clave histórica `microservicio/terraform.tfstate` antes del primer apply; no se migró ni eliminó automáticamente.

Las [capturas anteriores](imágenes/) muestran [checks con deploy omitido](imágenes/01-github-checks-correctos-despliegue-omitido.jpg) y [solo herramientas en us-east-1](imágenes/02-aws-cluster-microservicio-no-listado-us-east-1.jpg), no los tres entornos funcionando.
