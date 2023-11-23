using System.Threading.Tasks;
using MassTransit;
using TestTemplate8.Core.Events;

namespace TestTemplate8.WorkerServices.FooService
{
    public class FooConsumer : IConsumer<IFooEvent>
    {
        public Task Consume(ConsumeContext<IFooEvent> context) =>
            Task.CompletedTask;
    }
}
