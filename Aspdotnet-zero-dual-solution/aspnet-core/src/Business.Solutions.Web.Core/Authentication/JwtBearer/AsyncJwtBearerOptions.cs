using System.Collections.Generic;
using Microsoft.AspNetCore.Authentication.JwtBearer;

namespace Business.Solutions.Web.Authentication.JwtBearer
{
    public class AsyncJwtBearerOptions : JwtBearerOptions
    {
        public readonly List<IAsyncSecurityTokenValidator> AsyncSecurityTokenValidators;
        
        private readonly SolutionsAsyncJwtSecurityTokenHandler _defaultAsyncHandler = new SolutionsAsyncJwtSecurityTokenHandler();

        public AsyncJwtBearerOptions()
        {
            AsyncSecurityTokenValidators = new List<IAsyncSecurityTokenValidator>() {_defaultAsyncHandler};
        }
    }

}
