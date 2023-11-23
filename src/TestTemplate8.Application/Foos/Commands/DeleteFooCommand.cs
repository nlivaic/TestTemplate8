﻿using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;

namespace TestTemplate8.Application.Questions.Commands
{
    public class DeleteFooCommand : IRequest<Unit>
    {
        public Guid Id { get; set; }

        private class DeleteFooCommandHandler : IRequestHandler<DeleteFooCommand, Unit>
        {
            public DeleteFooCommandHandler()
            {
            }

            public Task<Unit> Handle(DeleteFooCommand request, CancellationToken cancellationToken) => Task.FromResult(Unit.Value);
        }
    }
}
