#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["src/TestTemplate8.WorkerServices/TestTemplate8.WorkerServices.csproj", "src/TestTemplate8.WorkerServices/"]
COPY ["src/TestTemplate8.Core/TestTemplate8.Core.csproj", "src/TestTemplate8.Core/"]
COPY ["src/TestTemplate8.Common/TestTemplate8.Common.csproj", "src/TestTemplate8.Common/"]
RUN dotnet restore "src/TestTemplate8.WorkerServices/TestTemplate8.WorkerServices.csproj"
COPY . .
WORKDIR "/src/src/TestTemplate8.WorkerServices"
RUN dotnet build "TestTemplate8.WorkerServices.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "TestTemplate8.WorkerServices.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY ["src/TestTemplate8.WorkerServices/entrypoint.sh", "src/entrypoint.sh"]
COPY ["src/TestTemplate8.WorkerServices/wait-for-it.sh", "src/wait-for-it.sh"]
CMD ["/bin/bash", "src/entrypoint.sh"]
