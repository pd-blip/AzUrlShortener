# STAGE 1: Build-Umgebung (mit SDK zum Kompilieren)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Kopiere alle Dateien im Repository in das Arbeitsverzeichnis des Containers
# (Der Build-Context, der alle Dateien umfasst, wird hier kopiert)
COPY . .

# Stelle die Abhängigkeiten wieder her (wir verwenden hier einen robusten Wildcard-Pfad)
# Der Restore-Befehl wird jetzt auf dem gesamten Ordner ausgeführt.
RUN dotnet restore

# Veröffentliche das API-Projekt
# Wir behalten den korrigierten Pfad bei: src/Api/Cloud5mins.ShortenerTools.Api.csproj
RUN dotnet publish "src/Api/Cloud5mins.ShortenerTools.Api.csproj" -c Release -o /app/publish --no-restore

# STAGE 2: Finale Laufzeit-Umgebung
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Kopieren der veröffentlichten Artefakte
COPY --from=build /app/publish .

# Startbefehl
ENTRYPOINT ["dotnet", "Cloud5mins.ShortenerTools.Api.dll"]
