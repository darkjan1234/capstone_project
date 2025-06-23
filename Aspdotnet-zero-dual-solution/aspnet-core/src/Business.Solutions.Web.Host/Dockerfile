#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["src/Business.Solutions.Web.Host/Business.Solutions.Web.Host.csproj", "src/Business.Solutions.Web.Host/"]
COPY ["src/Business.Solutions.Web.Core/Business.Solutions.Web.Core.csproj", "src/Business.Solutions.Web.Core/"]
COPY ["src/Business.Solutions.Application/Business.Solutions.Application.csproj", "src/Business.Solutions.Application/"]
COPY ["src/Business.Solutions.Application.Shared/Business.Solutions.Application.Shared.csproj", "src/Business.Solutions.Application.Shared/"]
COPY ["src/Business.Solutions.Core.Shared/Business.Solutions.Core.Shared.csproj", "src/Business.Solutions.Core.Shared/"]
COPY ["src/Business.Solutions.Core/Business.Solutions.Core.csproj", "src/Business.Solutions.Core/"]
COPY ["src/Business.Solutions.EntityFrameworkCore/Business.Solutions.EntityFrameworkCore.csproj", "src/Business.Solutions.EntityFrameworkCore/"]
COPY ["src/Business.Solutions.GraphQL/Business.Solutions.GraphQL.csproj", "src/Business.Solutions.GraphQL/"]
RUN dotnet restore "src/Business.Solutions.Web.Host/Business.Solutions.Web.Host.csproj"
COPY . .
WORKDIR "/src/src/Business.Solutions.Web.Host"
RUN dotnet build "Business.Solutions.Web.Host.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Business.Solutions.Web.Host.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Business.Solutions.Web.Host.dll"]
