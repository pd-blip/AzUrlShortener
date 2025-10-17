# Mehrstufiger Build für Produktion

# STAGE 1: Build-Umgebung (mit SDK zum Kompilieren)
# Basis-Image für .NET 9.0 SDK
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Kopiere die Projektdatei und stelle Abhängigkeiten wieder her
# Angenommen, das Projekt heißt AzUrlShortener.csproj und liegt in src/
COPY ["src/AzUrlShortener.csproj", "src/"]
RUN dotnet restore "src/AzUrlShortener.csproj"

# Kopiere den gesamten Rest des Codes
COPY . .

# Veröffentliche die Anwendung
RUN dotnet publish "src/AzUrlShortener.csproj" -c Release -o /app/publish --no-restore

# STAGE 2: Finale Laufzeit-Umgebung (kleineres Image ohne SDK)
# Basis-Image für .NET 9.0 Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Wichtig: Legt den Port 8080 fest, den Container Apps und die meisten Container erwarten
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Kopieren der veröffentlichten Artefakte
COPY --from=build /app/publish .

# Startbefehl
ENTRYPOINT ["dotnet", "AzUrlShortener.dll"]
