#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["src/TestTemplate8.Api/TestTemplate8.Api.csproj", "src/TestTemplate8.Api/"]
COPY ["src/TestTemplate8.Data/TestTemplate8.Data.csproj", "src/TestTemplate8.Data/"]
COPY ["src/TestTemplate8.Common/TestTemplate8.Common.csproj", "src/TestTemplate8.Common/"]
COPY ["src/TestTemplate8.Core/TestTemplate8.Core.csproj", "src/TestTemplate8.Core/"]
RUN dotnet restore "src/TestTemplate8.Api/TestTemplate8.Api.csproj"
COPY . .
WORKDIR "/src/src/TestTemplate8.Api"
RUN dotnet build "TestTemplate8.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "TestTemplate8.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TestTemplate8.Api.dll"]