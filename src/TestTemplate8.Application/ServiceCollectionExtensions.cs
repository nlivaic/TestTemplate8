using MediatR;
using Microsoft.Extensions.DependencyInjection;
using TestTemplate8.Application.Pipelines;

namespace TestTemplate8.Application
{
    public static class ServiceCollectionExtensions
    {
        public static void AddTestTemplate8ApplicationHandlers(this IServiceCollection services)
        {
            services.AddMediatR(typeof(ServiceCollectionExtensions).Assembly);
            services.AddPipelines();

            services.AddAutoMapper(typeof(ServiceCollectionExtensions).Assembly);
        }
    }
}
