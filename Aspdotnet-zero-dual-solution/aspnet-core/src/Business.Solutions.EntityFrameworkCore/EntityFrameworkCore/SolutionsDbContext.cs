using Business.Solutions.Maintenance;
using Abp.Zero.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Business.Solutions.Authorization.Delegation;
using Business.Solutions.Authorization.Roles;
using Business.Solutions.Authorization.Users;
using Business.Solutions.Chat;
using Business.Solutions.Editions;
using Business.Solutions.Friendships;
using Business.Solutions.MultiTenancy;
using Business.Solutions.MultiTenancy.Accounting;
using Business.Solutions.MultiTenancy.Payments;
using Business.Solutions.OpenIddict.Applications;
using Business.Solutions.OpenIddict.Authorizations;
using Business.Solutions.OpenIddict.Scopes;
using Business.Solutions.OpenIddict.Tokens;
using Business.Solutions.Storage;

namespace Business.Solutions.EntityFrameworkCore
{
    public class SolutionsDbContext : AbpZeroDbContext<Tenant, Role, User, SolutionsDbContext>, IOpenIddictDbContext
    {
        public virtual DbSet<PPO> PPOs { get; set; }

        public virtual DbSet<Log> Logs { get; set; }

        public virtual DbSet<Notification> Notifications { get; set; }

        public virtual DbSet<CommunicationHistory> CommunicationHistories { get; set; }

        public virtual DbSet<PTTMessage> PTTMessages { get; set; }

        public virtual DbSet<GroupMember> GroupMembers { get; set; }

        public virtual DbSet<Group> Groups { get; set; }

        public virtual DbSet<PttUser> PttUsers { get; set; }

        /* Define an IDbSet for each entity of the application */

        public virtual DbSet<OpenIddictApplication> Applications { get; }

        public virtual DbSet<OpenIddictAuthorization> Authorizations { get; }

        public virtual DbSet<OpenIddictScope> Scopes { get; }

        public virtual DbSet<OpenIddictToken> Tokens { get; }

        public virtual DbSet<BinaryObject> BinaryObjects { get; set; }

        public virtual DbSet<Friendship> Friendships { get; set; }

        public virtual DbSet<ChatMessage> ChatMessages { get; set; }

        public virtual DbSet<SubscribableEdition> SubscribableEditions { get; set; }

        public virtual DbSet<SubscriptionPayment> SubscriptionPayments { get; set; }

        public virtual DbSet<Invoice> Invoices { get; set; }

        public virtual DbSet<SubscriptionPaymentExtensionData> SubscriptionPaymentExtensionDatas { get; set; }

        public virtual DbSet<UserDelegation> UserDelegations { get; set; }

        public virtual DbSet<RecentPassword> RecentPasswords { get; set; }

        public SolutionsDbContext(DbContextOptions<SolutionsDbContext> options)
            : base(options)
        {

        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<PPO>(p =>
            {
                p.HasIndex(e => new { e.TenantId });
            });
            modelBuilder.Entity<Log>(l =>
                       {
                           l.HasIndex(e => new { e.TenantId });
                       });
            modelBuilder.Entity<Notification>(n =>
                       {
                           n.HasIndex(e => new { e.TenantId });
                       });
            modelBuilder.Entity<CommunicationHistory>(c =>
                       {
                           c.HasIndex(e => new { e.TenantId });
                       });
            modelBuilder.Entity<PTTMessage>(p =>
                       {
                           p.HasIndex(e => new { e.TenantId });
                       });
            modelBuilder.Entity<GroupMember>(g =>
                       {
                           g.HasIndex(e => new { e.TenantId });
                       });
            modelBuilder.Entity<Group>(g =>
                       {
                           g.HasIndex(e => new { e.TenantId });
                       });
            modelBuilder.Entity<PttUser>(p =>
                       {
                           p.HasIndex(e => new { e.TenantId });
                       });
            modelBuilder.Entity<BinaryObject>(b =>
                       {
                           b.HasIndex(e => new { e.TenantId });
                       });

            modelBuilder.Entity<ChatMessage>(b =>
            {
                b.HasIndex(e => new { e.TenantId, e.UserId, e.ReadState });
                b.HasIndex(e => new { e.TenantId, e.TargetUserId, e.ReadState });
                b.HasIndex(e => new { e.TargetTenantId, e.TargetUserId, e.ReadState });
                b.HasIndex(e => new { e.TargetTenantId, e.UserId, e.ReadState });
            });

            modelBuilder.Entity<Friendship>(b =>
            {
                b.HasIndex(e => new { e.TenantId, e.UserId });
                b.HasIndex(e => new { e.TenantId, e.FriendUserId });
                b.HasIndex(e => new { e.FriendTenantId, e.UserId });
                b.HasIndex(e => new { e.FriendTenantId, e.FriendUserId });
            });

            modelBuilder.Entity<Tenant>(b =>
            {
                b.HasIndex(e => new { e.SubscriptionEndDateUtc });
                b.HasIndex(e => new { e.CreationTime });
            });

            modelBuilder.Entity<SubscriptionPayment>(b =>
            {
                b.HasIndex(e => new { e.Status, e.CreationTime });
                b.HasIndex(e => new { PaymentId = e.ExternalPaymentId, e.Gateway });
            });

            modelBuilder.Entity<SubscriptionPaymentExtensionData>(b =>
            {
                b.HasQueryFilter(m => !m.IsDeleted)
                    .HasIndex(e => new { e.SubscriptionPaymentId, e.Key, e.IsDeleted })
                    .IsUnique()
                    .HasFilter("[IsDeleted] = 0");
            });

            modelBuilder.Entity<UserDelegation>(b =>
            {
                b.HasIndex(e => new { e.TenantId, e.SourceUserId });
                b.HasIndex(e => new { e.TenantId, e.TargetUserId });
            });

            modelBuilder.ConfigureOpenIddict();
        }
    }
}