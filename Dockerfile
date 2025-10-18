# STAGE 1: Build-Umgebung (mit SDK zum Kompilieren)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Wir stellen auf Basis der Solution-Datei (.sln) wieder her,
# da sie im Root-Ordner liegt und alle Abhängigkeiten erfasst.
COPY ["AzUrlShortener.sln", ""] 
COPY . .

# Führe den Restore-Befehl aus
RUN dotnet restore "AzUrlShortener.sln"

# Veröffentliche das API-Projekt, das als Hauptanwendung dient.
# Korrekter Pfad basierend auf Ihrem Screenshot: src/Api/Cloud5mins.ShortenerTools.Api.csproj
RUN dotnet publish "src/Api/Cloud5mins.ShortenerTools.Api.csproj" -c Release -o /app/publish --no-restore

# STAGE 2: Finale Laufzeit-Umgebung
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Kopieren der veröffentlichten Artefakte
COPY --from=build /app/publish .

# Startbefehl (Der Name der DLL muss mit dem Projektnamen übereinstimmen)
ENTRYPOINT ["dotnet", "Cloud5mins.ShortenerTools.Api.dll"]
