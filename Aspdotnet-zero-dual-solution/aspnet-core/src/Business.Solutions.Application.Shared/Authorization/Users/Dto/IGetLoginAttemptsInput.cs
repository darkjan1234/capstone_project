using Abp.Application.Services.Dto;

namespace Business.Solutions.Authorization.Users.Dto
{
    public interface IGetLoginAttemptsInput: ISortedResultRequest
    {
        string Filter { get; set; }
    }
}