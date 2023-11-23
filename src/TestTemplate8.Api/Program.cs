using System;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using Serilog;
using SparkRoseDigital.Infrastructure.Logging;
using LoggerExtensions = SparkRoseDigital.Infrastructure.Logging.LoggerExtensions;

namespace TestTemplate8.Api
{
    public class Program
    {
        public static void Main(string[] args)
        {
            LoggerExtensions.ConfigureSerilogLogger("ASPNETCORE_ENVIRONMENT");

            try
            {
                Log.Information("Starting up TestTemplate8.");
                CreateHostBuilder(args)
                    .Build()
                    .AddW3CTraceContextActivityLogging()
                    .Run();
            }
            catch (Exception ex)
            {
                Log.Fatal(ex, "TestTemplate8 failed at startup.");
            }
            finally
            {
                Log.CloseAndFlush();
            }
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                })
                .UseSerilog();
    }
}
