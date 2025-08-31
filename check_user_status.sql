-- Check user status and fix login issues
-- Run this SQL script to diagnose and fix user login problems

PRINT 'Checking user login status...';
PRINT '';

-- Check if user exists and their status
SELECT 
    [UserName],
    [Name],
    [EmailAddress],
    [IsActive],
    [IsEmailConfirmed],
    [IsLockoutEnabled],
    [AccessFailedCount],
    [LockoutEndDateUtc],
    [Password],
    [RegionCode],
    [PttRole]
FROM [dbo].[AbpUsers] 
WHERE [UserName] IN ('admin', 'test123', 'user1', 'john', 'user')
ORDER BY [UserName];

PRINT '';
PRINT 'Fixing common login issues...';

-- Fix 1: Make sure users are active and email confirmed
UPDATE [dbo].[AbpUsers] 
SET 
    [IsActive] = 1,
    [IsEmailConfirmed] = 1,
    [AccessFailedCount] = 0,
    [LockoutEndDateUtc] = NULL
WHERE [UserName] IN ('test123', 'user1', 'john', 'user');

PRINT '✅ Updated user status (active, email confirmed, unlocked)';

-- Fix 2: Reset password for test users to known value (123qwe)
UPDATE [dbo].[AbpUsers] 
SET [Password] = 'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q=='
WHERE [UserName] IN ('test123', 'user1', 'john', 'user');

PRINT '✅ Reset passwords to: 123qwe';

-- Fix 3: Add PTT roles if missing
UPDATE [dbo].[AbpUsers] 
SET 
    [PttRole] = 'FieldUser',
    [RegionCode] = 'REGION1'
WHERE [UserName] IN ('test123', 'user1', 'john', 'user') 
  AND ([PttRole] IS NULL OR [RegionCode] IS NULL);

PRINT '✅ Added PTT roles and regions';

-- Fix 4: Create test123 user if it doesn't exist
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'test123')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [RegionCode], [PttRole], [IsLockoutEnabled],
        [AccessFailedCount]
    )
    VALUES (
        1, 'test123', 'Test', 'User', 'test123@example.com',
        1, 'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q==', 1, GETDATE(),
        0, 'REGION1', 'FieldUser', 0, 0
    );
    PRINT '✅ Created test123 user';
END
ELSE
BEGIN
    PRINT '✅ test123 user already exists';
END

PRINT '';
PRINT '========================================';
PRINT '✅ USER LOGIN FIXES COMPLETED!';
PRINT '========================================';
PRINT '';

-- Show final user status
PRINT 'Updated user list:';
SELECT 
    [UserName] as 'Username',
    [Name] + ' ' + ISNULL([Surname], '') as 'Full Name',
    CASE WHEN [IsActive] = 1 THEN 'Active' ELSE 'Inactive' END as 'Status',
    CASE WHEN [IsEmailConfirmed] = 1 THEN 'Confirmed' ELSE 'Not Confirmed' END as 'Email',
    [AccessFailedCount] as 'Failed Attempts',
    ISNULL([PttRole], 'No Role') as 'PTT Role',
    ISNULL([RegionCode], 'No Region') as 'Region'
FROM [dbo].[AbpUsers] 
WHERE [UserName] IN ('admin', 'test123', 'user1', 'john', 'user')
ORDER BY [UserName];

PRINT '';
PRINT 'Test these credentials in Flutter app:';
PRINT '• admin / 123qwe (Super Admin)';
PRINT '• test123 / 123qwe (Field User)';
PRINT '• john / 123qwe (Field User)';
PRINT '• user / 123qwe (Field User)';
PRINT '';
PRINT 'All passwords are set to: 123qwe';
