# Utilisez l'image de base Windows avec support graphique
FROM mcr.microsoft.com/windows:20H2

# Installer Chocolatey, un gestionnaire de paquets pour Windows
RUN powershell.exe -Command \
    "Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && \
    choco feature enable -n allowGlobalConfirmation

# Installez les dépendances: Git et 7-Zip
RUN choco install git 7zip.install

# Récupérer et décompresser le serveur SteamCMD
RUN powershell.exe -Command \
    "New-Item -ItemType Directory -Path C:/steamcmd; \
    Invoke-WebRequest -Uri 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile 'C:/steamcmd/steamcmd.zip'; \
    Expand-Archive -Path 'C:/steamcmd/steamcmd.zip' -DestinationPath 'C:/steamcmd'"

# Installer le serveur DayZ Standalone via SteamCMD
RUN C:/steamcmd/steamcmd.exe +login anonymous +force_install_dir C:/dayz +app_update 223350 +quit

# Exposer les ports nécessaires pour le serveur DayZ Standalone (2302 pour le jeu, 27016 pour Steam)
EXPOSE 2302/udp 27016/udp

# Lancer le serveur DayZ Standalone
CMD C:/dayz/DayZServer_x64.exe -config=serverDZ.cfg -port=2302
