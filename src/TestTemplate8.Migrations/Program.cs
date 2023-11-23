using System;
using System.IO;
using DbUp;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace TestTemplate8.Migrations
{
    public class Program
    {
        public static int Main(string[] args)
        {
            var connectionString = string.Empty;
            var dbUser = string.Empty;
            var dbPassword = string.Empty;
            var scriptsPath = string.Empty;

            var env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")
                ?? "Development";
            Console.WriteLine($"Environment: {env}.");
            var builder = new ConfigurationBuilder()
                .AddJsonFile($"appsettings.json", true, true)
                .AddJsonFile($"appsettings.{env}.json", true, true)
                .AddEnvironmentVariables();

            var config = builder.Build();
            InitializeParameters();
            var connectionStringTestTemplate8 = new SqlConnectionStringBuilder(connectionString)
            {
                UserID = dbUser,
                Password = dbPassword
            }.ConnectionString;

            var upgraderTestTemplate8 =
                DeployChanges.To
                    .SqlDatabase(connectionStringTestTemplate8)
                    .WithScriptsFromFileSystem(
                        !string.IsNullOrWhiteSpace(scriptsPath)
                                ? Path.Combine(scriptsPath, "TestTemplate8Scripts")
                            : Path.Combine(Environment.CurrentDirectory, "TestTemplate8Scripts"))
                    .LogToConsole()
                    .Build();
            Console.WriteLine($"Now upgrading TestTemplate8.");
            var resultTestTemplate8 = upgraderTestTemplate8.PerformUpgrade();

            if (!resultTestTemplate8.Successful)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"TestTemplate8 upgrade error: {resultTestTemplate8.Error}");
                Console.ResetColor();
                return -1;
            }

            // Uncomment the below sections if you also have an Identity Server project in the solution.
            /*
            var connectionStringTestTemplate8Identity = string.IsNullOrWhiteSpace(args.FirstOrDefault())
                ? config["ConnectionStrings:TestTemplate8IdentityDb"]
                : args.FirstOrDefault();

            var upgraderTestTemplate8Identity =
                DeployChanges.To
                    .SqlDatabase(connectionStringTestTemplate8Identity)
                    .WithScriptsFromFileSystem(
                        scriptsPath != null
                            ? Path.Combine(scriptsPath, "TestTemplate8IdentityScripts")
                            : Path.Combine(Environment.CurrentDirectory, "TestTemplate8IdentityScripts"))
                    .LogToConsole()
                    .Build();
            Console.WriteLine($"Now upgrading TestTemplate8 Identity.");
            if (env != "Development")
            {
                upgraderTestTemplate8Identity.MarkAsExecuted("0004_InitialData.sql");
                Console.WriteLine($"Skipping 0004_InitialData.sql since we are not in Development environment.");
                upgraderTestTemplate8Identity.MarkAsExecuted("0005_Initial_Configuration_Data.sql");
                Console.WriteLine($"Skipping 0005_Initial_Configuration_Data.sql since we are not in Development environment.");
            }
            var resultTestTemplate8Identity = upgraderTestTemplate8Identity.PerformUpgrade();

            if (!resultTestTemplate8Identity.Successful)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"TestTemplate8 Identity upgrade error: {resultTestTemplate8Identity.Error}");
                Console.ResetColor();
                return -1;
            }
            */

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Success!");
            Console.ResetColor();
            return 0;

            void InitializeParameters()
            {
                if (args.Length == 0)
                {
                    connectionString = config["ConnectionStrings:TestTemplate8Db_Migrations_Connection"];
                    dbUser = config["DB_USER"];
                    dbPassword = config["DB_PASSWORD"];
                }
                else if (args.Length == 4)
                {
                    connectionString = args[0];
                    dbUser = args[1];
                    dbPassword = args[2];
                    scriptsPath = args[3];
                }
            }
        }
    }
}
