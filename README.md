# Script de Backup Automático

Este script Bash foi desenvolvido para automatizar o processo de backup dos arquivos da pasta home do usuário. Ele cria backups compactados em formato `tar.gz`, mantendo apenas os últimos 10 backups para economizar espaço em disco.

### Funcionalidades

- **Backup Automático:** Cria backups regularmente da pasta home do usuário.
- **Compactação:** Os backups são compactados em formato `tar.gz` para economizar espaço.
- **Limite de Backups:** Apenas os 10 backups mais recentes são mantidos.
- **Criptografia Opcional:** Possibilidade de criptografar os backups para maior segurança.
- **Notificações por E-mail:** Envia notificações por e-mail sobre o status dos backups.

### Como Usar

1. Clone este repositório:
   ```bash
   `git clone https://github.com/seuusuario/script-backup-automatico.git`

2. Navegue até o diretório do script:
   `cd script-backup-automatico`

3. Dê permissão de execução ao script:
   `chmod +x backup.sh`

4. Execute o script:
   `./backup_vaporhole.sh`

### Opções
- `-h, --help:` Exibe a mensagem de ajuda.
- `-e: Criptografa` o backup usando GPG.

### Requisitos:
- Bash
- GPG (para criptografia)

### Contribuindo
Sinta-se à vontade para contribuir com melhorias neste script. Basta fazer um fork do repositório, fazer as alterações e enviar um pull request.

### Licença
Este projeto está licenciado sob a Licença GNU General Public License v3.0.

---

# Automatic Backup Script
This Bash script was developed to automate the process of backing up user's home directory files. It creates compressed backups in tar.gz format, keeping only the last 10 backups to save disk space.

### Features
Automatic Backup: Regularly creates backups of the user's home directory.
Compression: Backups are compressed in tar.gz format to save space.
Backup Limit: Only the 10 most recent backups are kept.
Optional Encryption: Option to encrypt backups for added security.
Email Notifications: Sends email notifications about backup status.

### How to Use
1. Clone this repository:
   `git clone https://github.com/yourusername/automatic-backup-script.git`

2. Navigate to the script directory:
   `cd automatic-backup-script`

3. Give execution permission to the script:
   `chmod +x backup.sh`

4. Run the script:
   `./backup_vaporhole.sh`

### Options
- `-h, --help:` Display the help message.
- `-e: Encrypt` the backup using GPG.

### Requirements:
- Bash
- GPG (for encryption)

### Contributing
Feel free to contribute improvements to this script. Just fork the repository, make the changes, and send a pull request.

### License
This project is licensed under the GNU General Public License v3.0.
