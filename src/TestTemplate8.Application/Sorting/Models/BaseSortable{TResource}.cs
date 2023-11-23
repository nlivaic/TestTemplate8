﻿using System;

namespace TestTemplate8.Application.Sorting.Models
{
    public abstract class BaseSortable<TResource> : BaseSortable
    {
        public override Type ResourceType { get; } = typeof(TResource);
    }
}
