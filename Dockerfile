# STAGE 1: Build-Umgebung (mit SDK zum Kompilieren)
# Basis-Image für .NET 8.0 SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Kopiere die Projektdatei und stelle Abhängigkeiten wieder her
COPY ["src/AzUrlShortener.csproj", "src/"]
RUN dotnet restore "src/AzUrlShortener.csproj"

# Kopiere den gesamten Code und veröffentliche
COPY . .
RUN dotnet publish "src/AzUrlShortener.csproj" -c Release -o /app/publish --no-restore

# STAGE 2: Finale Laufzeit-Umgebung (kleineres Image ohne SDK)
# Basis-Image für .NET 8.0 Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Legt den internen Port fest, den Container Apps erwartet
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Kopieren der veröffentlichten Artefakte
COPY --from=build /app/publish .

# Startbefehl
ENTRYPOINT ["dotnet", "AzUrlShortener.dll"]
