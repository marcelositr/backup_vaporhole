#!/bin/bash
#===============================================================================
#
#          FILE: backup_vaporhole.sh
#
#         USAGE: ./backup_vaporhole.sh [-e] [-h | --help]
#
#   DESCRIPTION: This script creates a backup of the user's home directory.
#                The backup is created in tar.gz format and named with the format
#                (username)-YYYY-MM-DD_HH-MM-SS.tar.gz.
#                Only the last 10 backups are kept.
#                The user can choose to encrypt the backup using GPG.
#
#       OPTIONS: -e to encrypt the backup
#                -h, --help to display this help message
#  REQUIREMENTS: bash, gpg
#          BUGS: n/a
#         NOTES: Uses SHA256 instead of MD5. Allows encryption with GPG.
#        AUTHOR: ~marcelositr marcelositr@vaporhole.xyz
#  ORGANIZATION: vaporhole.xyz
#       CREATED: 2024/06/08
#       VERSION: 0.02
#      REVISION: n/a
#===============================================================================

# Function to send emails
# Função para enviar e-mails
send_email() {
    local subject="$1"
    local message="$2"
    local recipient="${USER}@vaporhole.xyz"
    echo "$message" | mail -s "$subject" "$recipient"
}

# Function to generate SHA256 file
# Função para gerar arquivo SHA256
generate_sha256() {
    local file="$1"
    sha256sum "$file" | awk '{print $1 "  " $2}' > "$file.sha256"
}

# Function to encrypt the backup file
# Função para criptografar o arquivo de backup
encrypt_backup() {
    local file="$1"
    gpg --symmetric --cipher-algo AES256 "$file"
}

# Function to display the help message
# Função para exibir a mensagem de ajuda
show_help() {
    cat << EOF
Usage: $0 [-e] [-h | --help]

This script creates a backup of the user's home directory.
The backup is created in tar.gz format and named with the format
(username)-YYYY-MM-DD_HH-MM-SS.tar.gz.
Only the last 10 backups are kept.
The user can choose to encrypt the backup using GPG.

Options:
  -e          Encrypt the backup using GPG with AES256 algorithm.
  -h, --help  Display this help message.
EOF
}

# Function to process command-line options
# Função para processar as opções de linha de comando
process_options() {
    while getopts "eh-:" opt; do
        case $opt in
            e) encrypt=true ;;
            h) show_help; exit 0 ;;
            -)
                case "${OPTARG}" in
                    help) show_help; exit 0 ;;
                    *) echo "Invalid option: --${OPTARG}"; show_help; exit 1 ;;
                esac
                ;;
            *) show_help; exit 1 ;;
        esac
    done
}

# Function to create the backup
# Função para criar o backup
create_backup() {
    local backup_file="$1"
    local source_dir="$2"
    local dest_dir="$3"
    local exclude_dir="$4"

    echo "Creating file list..."
    # Criando lista de arquivos...
    local file_list
    file_list=$(find "$source_dir" -type f ! -path "${exclude_dir}*")

    echo "Creating backup..."
    # Criando backup...
    echo "$file_list" | tar -czf "${dest_dir}${backup_file}" -T -
}

# Function to remove old backups
# Função para remover backups antigos
remove_old_backups() {
    local dest_dir="$1"
    local user="$2"
    local max_backups="$3"

    local old_backups
    old_backups=$(ls -t "$dest_dir" | grep "^${user}-" | tail -n +$((max_backups+1)))
    if [ -n "$old_backups" ]; then
        echo "Removing old backups..."
        # Removendo backups antigos...
        echo "$old_backups" | xargs -I {} rm -f "${dest_dir}{}"
    fi
}

# Function to verify backup integrity
# Função para verificar integridade do backup
verify_backup_integrity() {
    local backup_file="$1"
    local dest_dir="$2"

    echo "Verifying backup integrity..."
    # Verificando integridade do backup...
    local original_hash
    original_hash=$(sha256sum "${dest_dir}${backup_file}" | awk '{print $1}')

    if [[ "$backup_file" == *.gpg ]]; then
        gpg -d "${dest_dir}${backup_file}" | tar -xz -C "$dest_dir"
        local extracted_file
        extracted_file=$(basename "${backup_file%.gpg}")
    else
        tar -xz -C "$dest_dir" -f "${dest_dir}${backup_file}"
        extracted_file="$backup_file"
    fi

    local new_hash
    new_hash=$(sha256sum "${dest_dir}${extracted_file}" | awk '{print $1}')

    if [ "$original_hash" == "$new_hash" ]; then
        echo "Backup integrity successfully verified."
        # Integridade do backup verificada com sucesso.
        rm -rf "${dest_dir}home"
    else
        echo "Error: Backup integrity compromised."
        # Erro: Integridade do backup comprometida.
        send_email "Backup error" "There was an error: Backup integrity compromised on $(date '+%Y-%m-%d_%H-%M-%S')."
        exit 1
    fi
}

# Main function
# Função principal
main() {
    local user
    user=$(whoami)

    local datetime
    datetime=$(date +"%Y-%m-%d_%H-%M-%S")
    local backup_file="${user}-${datetime}.tar.gz"

    local source_dir="/home/${user}/"
    local dest_dir="/home/${user}/backup/"
    local max_backups=10

    mkdir -p "$dest_dir"
    create_backup "$backup_file" "$source_dir" "$dest_dir" "$dest_dir"

    if [ $? -eq 0 ]; then
        echo -e "\e[32mBackup successfully created: ${dest_dir}${backup_file}\e[0m"
        # Backup criado com sucesso: ${dest_dir}${backup_file}

        if [ "$encrypt" = true ]; then
            echo "Encrypting the backup..."
            # Criptografando o backup...
            encrypt_backup "${dest_dir}${backup_file}"
            if [ $? -eq 0 ]; then
                echo -e "\e[32mBackup successfully encrypted: ${dest_dir}${backup_file}.gpg\e[0m"
                # Backup criptografado com sucesso: ${dest_dir}${backup_file}.gpg
                rm -f "${dest_dir}${backup_file}"
                backup_file="${backup_file}.gpg"
            else
                echo -e "\e[31mError encrypting the backup.\e[0m"
                # Erro ao criptografar o backup.
                send_email "Backup error" "There was an error encrypting the backup for ${user} on ${datetime}."
                exit 1
            fi
        fi

        remove_old_backups "$dest_dir" "$user" "$max_backups"
        generate_sha256 "${dest_dir}${backup_file}"
        verify_backup_integrity "$backup_file" "$dest_dir"

        send_email "Backup completed" "The backup for ${user} was successfully created on ${datetime}."
    else
        echo "Error creating the backup."
        # Erro ao criar o backup.
        send_email "Backup error" "There was an error creating the backup for ${user} on ${datetime}."
        exit 1
    fi
}

# Variable to control encryption
# Variável para controlar a criptografia
encrypt=false

# Process command-line options
# Processa opções de linha de comando
process_options "$@"

# Execute the main function
# Executa a função principal
main
