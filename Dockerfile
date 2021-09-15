FROM mcr.microsoft.com/dotnet/aspnet:3.1-focal AS base
WORKDIR /app
EXPOSE 5000/tcp
ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:3.1-focal AS build
WORKDIR /src
COPY ["netcorerest.csproj", "./"]
RUN dotnet restore "netcorerest.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "netcorerest.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "netcorerest.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "netcorerest.dll"]


# docker run -tp 5000:5000  netcorerest:latest

# http://localhost:5000/WeatherForecast
# http://127.0.0.1:5000/WeatherForecast