using Abp.Dependency;

namespace Business.Solutions.Web.Xss
{
    public interface IHtmlSanitizer: ITransientDependency
    {
        string Sanitize(string html);
    }
}