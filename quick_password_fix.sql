-- QUICK PASSWORD FIX - COPY WORKING ADMIN HASH TO ALL USERS
-- Based on your database screenshot, admin (ID=2) has a working password hash

PRINT '🚀 QUICK PASSWORD FIX - COPYING ADMIN HASH TO ALL USERS...';

-- Use admin's working password hash for all users
UPDATE [dbo].[AbpUsers] 
SET [Password] = (SELECT [Password] FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin' AND [Id] = 2)
WHERE [UserName] IN ('test123', 'user', 'user1');

-- Make sure all users are active and properly configured
UPDATE [dbo].[AbpUsers] 
SET 
    [IsActive] = 1,
    [IsEmailConfirmed] = 1,
    [AccessFailedCount] = 0,
    [LockoutEndDateUtc] = NULL,
    [IsLockoutEnabled] = 0
WHERE [UserName] IN ('admin', 'test123', 'user', 'user1');

PRINT '✅ DONE! All users now have admin password hash.';
PRINT 'Test login with: test123/123qwe, user/123qwe, user1/123qwe';

-- Verify the fix
SELECT [UserName], [IsActive], LEFT([Password], 30) + '...' as 'Password Hash'
FROM [dbo].[AbpUsers] 
WHERE [UserName] IN ('admin', 'test123', 'user', 'user1')
ORDER BY [UserName];
