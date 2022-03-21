#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["TestDockerApp2.csproj", "."]
RUN dotnet restore "./TestDockerApp2.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "TestDockerApp2.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "TestDockerApp2.csproj" -c Release -o /app/publish

ENV ASPNETCORE_URLS http://+:5000
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y nginx
ADD testapp.conf /etc/nginx/sites-enabled
CMD ["nginx", "-g", "daemon off;"]

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TestDockerApp2.dll"]