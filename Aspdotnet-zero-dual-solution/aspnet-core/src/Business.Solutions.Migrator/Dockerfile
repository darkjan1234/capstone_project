#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["src/Business.Solutions.Migrator/Business.Solutions.Migrator.csproj", "src/Business.Solutions.Migrator/"]
COPY ["src/Business.Solutions.EntityFrameworkCore/Business.Solutions.EntityFrameworkCore.csproj", "src/Business.Solutions.EntityFrameworkCore/"]
COPY ["src/Business.Solutions.Core/Business.Solutions.Core.csproj", "src/Business.Solutions.Core/"]
COPY ["src/Business.Solutions.Core.Shared/Business.Solutions.Core.Shared.csproj", "src/Business.Solutions.Core.Shared/"]
RUN dotnet restore "src/Business.Solutions.Migrator/Business.Solutions.Migrator.csproj"
COPY . .
WORKDIR "/src/src/Business.Solutions.Migrator"
RUN dotnet build "Business.Solutions.Migrator.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Business.Solutions.Migrator.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Business.Solutions.Migrator.dll", "-s"]
