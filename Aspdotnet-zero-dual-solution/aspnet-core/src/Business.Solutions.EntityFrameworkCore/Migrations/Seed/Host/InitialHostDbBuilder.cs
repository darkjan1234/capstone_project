using Business.Solutions.EntityFrameworkCore;

namespace Business.Solutions.Migrations.Seed.Host
{
    public class InitialHostDbBuilder
    {
        private readonly SolutionsDbContext _context;

        public InitialHostDbBuilder(SolutionsDbContext context)
        {
            _context = context;
        }

        public void Create()
        {
            new DefaultEditionCreator(_context).Create();
            new DefaultLanguagesCreator(_context).Create();
            new HostRoleAndUserCreator(_context).Create();
            new DefaultSettingsCreator(_context).Create();

            _context.SaveChanges();
        }
    }
}
