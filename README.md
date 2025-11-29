# DevOps Pipeline Configuration

This directory contains the Ansible configuration files and playbooks for deploying the complete CI/CD pipeline.

## Service Port Configuration

**Important:** Jenkins has been configured to run on port **8080** instead of the default port 8080.

| Service | Server | Port | Access URL | Purpose |
|---------|--------|------|------------|---------|
| Jenkins | jenkins-ctl | 8080 | `http://<JENKINS-IP>:8080` | Pipeline orchestration |
| SonarQube | sonar-01 | 9000 | `http://<SONAR-IP>:9000` | Code quality analysis |
| Nexus | nexus-01 | 8081 | `http://<NEXUS-IP>:8081` | Artifact repository |
| Tomcat | tomcat-01 | 8080 | `http://<TOMCAT-IP>:8080` | Application deployment |
| Docker | build-01 | 2375 | SSH only | Build execution |

## Configuration Files

### hosts.ini
Ansible inventory file containing all server definitions. **You must update this file with your actual EC2 public IP addresses** after launching the instances.

**Placeholders to replace:**
- `JIP` - Jenkins server public IP
- `SIP` - SonarQube server public IP
- `NIP` - Nexus server public IP
- `BIP` - Build server public IP
- `TIP` - Tomcat server public IP

### Playbooks Directory

Contains 5 Ansible playbooks for automated deployment:

1. **jenkins.yml** - Installs Jenkins controller with OpenJDK 17
2. **sonar.yml** - Deploys SonarQube 10.2 with PostgreSQL via Docker Compose
3. **nexus.yml** - Sets up Nexus Repository Manager 3.62.0
4. **build.yml** - Configures build server with Maven and Docker
5. **tomcat.yml** - Installs Tomcat 9 application server

## Usage

### 1. Update Inventory File
```bash
cd /path/to/devops-pipeline
vim hosts.ini  # Replace JIP, SIP, NIP, BIP, TIP with actual IPs
```

### 2. Test Connectivity
```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible all -i hosts.ini -m ping
```

Expected: SUCCESS from all 5 hosts

### 3. Deploy All Services
```bash
# Deploy in order
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini playbooks/jenkins.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini playbooks/sonar.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini playbooks/nexus.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini playbooks/build.yml
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini playbooks/tomcat.yml
```

### 4. Access Services

After deployment, access your services at:

- **Jenkins**: http://&lt;JENKINS-IP&gt;:**8080**
  - Get admin password: `ansible jenkins -i hosts.ini -a "cat /var/lib/jenkins/secrets/initialAdminPassword"`
  - Initial setup required (install plugins, create admin user)

- **SonarQube**: http://&lt;SONAR-IP&gt;:9000
  - Default credentials: admin/admin (change on first login)
  - Create authentication token for Jenkins pipeline

- **Nexus**: http://&lt;NEXUS-IP&gt;:8081
  - Get admin password: `ansible nexus -i hosts.ini -a "cat /opt/nexus-data/admin.password"`
  - Create maven-releases repository

- **Tomcat**: http://&lt;TOMCAT-IP&gt;:8080
  - Manager credentials: admin/admin123
  - Deployer credentials: deployer/deployer123

## Important Notes

### Jenkins Port 8080 Configuration
Jenkins is configured to run on port 8080. This is noted in:
- Security group rules (make sure to allow inbound traffic on port 8080)
- Jenkins URL configuration in Jenkins system settings
- This helps avoid conflicts with Tomcat which also uses port 8080

### Port Conflicts
- **Jenkins**: Uses 8080 (non-standard) to avoid conflict with Tomcat
- **Tomcat**: Uses 8080 (standard)
- **Nexus**: Uses 8081 (non-standard)
- **SonarQube**: Uses 9000 (standard)

Ensure your security groups allow access to all these ports from your IP address.

## Troubleshooting

### Unable to connect to Jenkins on port 8080
**Solution**: Jenkins runs on port 8080. Use http://&lt;JENKINS-IP&gt;:8080

### Port already in use errors
**Solution**: The services use different ports to avoid conflicts:
- Jenkins: 8080
- Tomcat: 8080
- Nexus: 8081

### Docker socket permission denied
**Solution**: Make sure the ubuntu user is in the docker group:
```bash
ansible build -i hosts.ini -a "groups ubuntu"
```
If not, re-run the build playbook to add the user to the docker group.

## Next Steps

After all services are deployed:
1. Configure Jenkins credentials (SSH key, SonarQube token, Nexus credentials, Docker Hub token)
2. Configure Jenkins tools (JDK-17, Maven-3.9, Ansible)
3. Create Jenkins pipeline job pointing to your Git repository
4. Run your first build!

## Security Considerations

⚠️ **Important**: This is a development/testing setup. For production use:
- Use strong passwords (change from the default admin123, deployer123)
- Enable SSL/TLS for all services
- Use a secrets management system (Vault, AWS Secrets Manager)
- Restrict security group access (don't use 0.0.0.0/0)
- Regularly update all services and apply security patches
