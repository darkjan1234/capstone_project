using Business.Solutions.Maintenance;
using System;
using System.Linq;
using Abp.Organizations;
using Business.Solutions.Authorization.Roles;
using Business.Solutions.MultiTenancy;

namespace Business.Solutions.EntityHistory
{
    public static class EntityHistoryHelper
    {
        public const string EntityHistoryConfigurationName = "EntityHistory";

        public static readonly Type[] HostSideTrackedTypes =
        {
            typeof(PPO),
            typeof(Log),
            typeof(GroupMember),
            typeof(OrganizationUnit), typeof(Role), typeof(Tenant)
        };

        public static readonly Type[] TenantSideTrackedTypes =
        {
            typeof(PPO),
            typeof(Log),
            typeof(GroupMember),
            typeof(OrganizationUnit), typeof(Role)
        };

        public static readonly Type[] TrackedTypes =
            HostSideTrackedTypes
                .Concat(TenantSideTrackedTypes)
                .GroupBy(type => type.FullName)
                .Select(types => types.First())
                .ToArray();
    }
}