using Microsoft.EntityFrameworkCore;
using Business.Solutions.OpenIddict.Applications;
using Business.Solutions.OpenIddict.Authorizations;
using Business.Solutions.OpenIddict.Scopes;
using Business.Solutions.OpenIddict.Tokens;

namespace Business.Solutions.EntityFrameworkCore
{
    public interface IOpenIddictDbContext
    {
        DbSet<OpenIddictApplication> Applications { get; }

        DbSet<OpenIddictAuthorization> Authorizations { get; }

        DbSet<OpenIddictScope> Scopes { get; }

        DbSet<OpenIddictToken> Tokens { get; }
    }

}