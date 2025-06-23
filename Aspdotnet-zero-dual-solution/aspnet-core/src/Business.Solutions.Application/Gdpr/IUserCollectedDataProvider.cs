using System.Collections.Generic;
using System.Threading.Tasks;
using Abp;
using Business.Solutions.Dto;

namespace Business.Solutions.Gdpr
{
    public interface IUserCollectedDataProvider
    {
        Task<List<FileDto>> GetFiles(UserIdentifier user);
    }
}
