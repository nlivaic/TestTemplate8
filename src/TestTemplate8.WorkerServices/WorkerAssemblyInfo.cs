﻿using System.Reflection;

namespace TestTemplate8.WorkerServices
{
    public static class WorkerAssemblyInfo
    {
        public static Assembly Value { get; } = typeof(WorkerAssemblyInfo).Assembly;
        public static string ServiceName { get; } = "TestTemplate8";
    }
}
