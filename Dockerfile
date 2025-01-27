FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Create cert directory and copy certificate
RUN mkdir -p /app/certs
COPY ./certs/selfsigned.pfx /app/certs/selfsigned.pfx
RUN chmod 644 /app/certs/selfsigned.pfx

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["SampleWebApi/SampleWebApi.csproj", "SampleWebApi/"]
RUN dotnet restore "SampleWebApi/SampleWebApi.csproj"
COPY . .
WORKDIR "/src/SampleWebApi"
RUN dotnet build "SampleWebApi.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "SampleWebApi.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SampleWebApi.dll"]
