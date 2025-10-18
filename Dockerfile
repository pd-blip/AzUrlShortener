# STAGE 1: Build-Umgebung (mit SDK zum Kompilieren)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Kopiere die Solution-Datei in das Arbeitsverzeichnis
COPY ["AzUrlShortener.sln", "."]

# Kopiere alle Projektdateien (.csproj) in ihre jeweiligen Unterordner
# Dies ist notwendig für 'dotnet restore' auf Solution-Ebene
COPY ["src/**/*.csproj", "src/"] 

# Kopiere alle anderen Dateien
COPY . .

# Stelle alle NuGet-Pakete wieder her, indem wir auf die Solution-Datei verweisen
RUN dotnet restore "AzUrlShortener.sln"

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
