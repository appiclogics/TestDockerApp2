#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

ENV ASPNETCORE_URLS https://*:5000

RUN apt update && apt install nginx
ADD nginx.conf /etc/nginx/sites-enabled
RUN service nginx restart

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 5000 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["TestDockerApp2.csproj", "."]
RUN dotnet restore "./TestDockerApp2.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "TestDockerApp2.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "TestDockerApp2.csproj" -c Release -o /app/publish


FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TestDockerApp2.dll"]