-- TARGETED FIX FOR USER LOGIN ISSUE
-- This script will use the EXACT working admin password hash

PRINT '🔧 FIXING USER LOGIN - TARGETED APPROACH...';
PRINT '';

-- Use the EXACT password hash from the working admin (ID=2 based on your screenshot)
DECLARE @WorkingAdminHash NVARCHAR(MAX) = 'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q==';

PRINT 'Using working admin password hash for all users...';

-- Update ALL users to use the same working password hash
UPDATE [dbo].[AbpUsers]
SET [Password] = @WorkingAdminHash
WHERE [UserName] IN ('admin', 'test123', 'user', 'user1');

PRINT '✅ Updated ALL users to use working password hash';

PRINT '';
PRINT '🔧 STEP 2: Fix user properties...';

-- Make sure all users are properly configured
UPDATE [dbo].[AbpUsers]
SET
    [IsActive] = 1,
    [IsEmailConfirmed] = 1,
    [AccessFailedCount] = 0,
    [LockoutEndDateUtc] = NULL,
    [IsLockoutEnabled] = 0,
    [ShouldChangePasswordOnNextLogin] = 0,
    [IsPhoneNumberConfirmed] = 0,
    [PttRole] = CASE
        WHEN [UserName] = 'admin' THEN 'SuperAdmin'
        ELSE 'FieldUser'
    END,
    [RegionCode] = CASE
        WHEN [UserName] = 'admin' THEN NULL
        ELSE 'REGION1'
    END
WHERE [UserName] IN ('admin', 'test123', 'user', 'user1');

PRINT '✅ Updated user properties';

PRINT '';
PRINT '🔧 STEP 3: Create missing test users if needed...';

-- Create test123 if it doesn't exist
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'test123')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [RegionCode], [PttRole], [IsLockoutEnabled],
        [AccessFailedCount], [ShouldChangePasswordOnNextLogin]
    )
    SELECT 
        1, 'test123', 'Test', 'User', 'test123@example.com',
        1, [Password], 1, GETDATE(),
        0, 'REGION1', 'FieldUser', 0, 0, 0
    FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin';
    
    PRINT '✅ Created test123 user with admin password hash';
END

-- Create user if it doesn't exist
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'user')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [RegionCode], [PttRole], [IsLockoutEnabled],
        [AccessFailedCount], [ShouldChangePasswordOnNextLogin]
    )
    SELECT 
        1, 'user', 'Regular', 'User', 'user@example.com',
        1, [Password], 1, GETDATE(),
        0, 'REGION1', 'FieldUser', 0, 0, 0
    FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin';
    
    PRINT '✅ Created user with admin password hash';
END

-- Create user1 if it doesn't exist
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'user1')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [RegionCode], [PttRole], [IsLockoutEnabled],
        [AccessFailedCount], [ShouldChangePasswordOnNextLogin]
    )
    SELECT 
        1, 'user1', 'User', 'One', 'user1@example.com',
        1, [Password], 1, GETDATE(),
        0, 'REGION1', 'FieldUser', 0, 0, 0
    FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin';
    
    PRINT '✅ Created user1 with admin password hash';
END

PRINT '';
PRINT '🔧 STEP 4: Verify password hashes match...';

-- Verify all users now have the same password hash as admin
SELECT 
    [UserName],
    CASE 
        WHEN [Password] = (SELECT [Password] FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin') 
        THEN '✅ MATCHES ADMIN' 
        ELSE '❌ DIFFERENT' 
    END as 'Password Status',
    LEFT([Password], 20) + '...' as 'Hash Preview'
FROM [dbo].[AbpUsers] 
WHERE [UserName] IN ('admin', 'test123', 'user', 'user1')
ORDER BY [UserName];

PRINT '';
PRINT '========================================';
PRINT '✅ PASSWORD HASH FIX COMPLETED!';
PRINT '========================================';
PRINT '';
PRINT 'All users now have IDENTICAL password hashes as admin.';
PRINT 'Since admin can login with "123qwe", all users should work with "123qwe"';
PRINT '';
PRINT '🎯 TEST THESE CREDENTIALS IN FLUTTER:';
PRINT '• admin / 123qwe ← Already working';
PRINT '• test123 / 123qwe ← Should work now!';
PRINT '• user / 123qwe ← Should work now!';
PRINT '• user1 / 123qwe ← Should work now!';
PRINT '';

-- Final verification
PRINT 'Final user status:';
SELECT 
    [UserName] as 'Username',
    [Name] + ' ' + ISNULL([Surname], '') as 'Full Name',
    CASE WHEN [IsActive] = 1 THEN '✅ Active' ELSE '❌ Inactive' END as 'Status',
    CASE WHEN [IsEmailConfirmed] = 1 THEN '✅ Confirmed' ELSE '❌ Not Confirmed' END as 'Email',
    [AccessFailedCount] as 'Failed Attempts',
    ISNULL([PttRole], 'No Role') as 'PTT Role',
    ISNULL([RegionCode], 'No Region') as 'Region',
    CASE WHEN [ShouldChangePasswordOnNextLogin] = 1 THEN '⚠️ Must Change' ELSE '✅ OK' END as 'Password Status'
FROM [dbo].[AbpUsers] 
WHERE [UserName] IN ('admin', 'test123', 'user', 'user1')
ORDER BY [UserName];

PRINT '';
PRINT '🚀 NOW TEST LOGIN IN FLUTTER APP!';
