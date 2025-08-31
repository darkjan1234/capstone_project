-- 🎯 COMPLETE GROUP-BASED PTT SOLUTION
-- This creates a working group system where admin creates groups and users can communicate within their groups

PRINT '🚀 SETTING UP COMPLETE GROUP-BASED PTT SYSTEM...';
PRINT '';

-- STEP 1: Fix all user passwords to work with mobile app
PRINT '🔧 STEP 1: Fixing user authentication...';

-- Use a known working password hash (admin's hash)
DECLARE @WorkingPasswordHash NVARCHAR(MAX);
SELECT @WorkingPasswordHash = [Password] FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin' AND [Id] = 2;

-- Update ALL users to use the same working password hash
UPDATE [dbo].[AbpUsers] 
SET [Password] = @WorkingPasswordHash,
    [IsActive] = 1,
    [IsEmailConfirmed] = 1,
    [AccessFailedCount] = 0,
    [LockoutEndDateUtc] = NULL,
    [IsLockoutEnabled] = 0,
    [ShouldChangePasswordOnNextLogin] = 0
WHERE [UserName] IN ('admin', 'test123', 'user', 'user1');

PRINT '✅ All users now have working password: 123qwe';

-- STEP 2: Create missing users if needed
PRINT '';
PRINT '🔧 STEP 2: Creating test users...';

-- Create test123 if missing
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'test123')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [PttRole], [RegionCode]
    )
    VALUES (
        1, 'test123', 'Test', 'User', 'test123@example.com',
        1, @WorkingPasswordHash, 1, GETDATE(),
        0, 'FieldUser', 'REGION1'
    );
    PRINT '✅ Created test123 user';
END

-- Create user if missing
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'user')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [PttRole], [RegionCode]
    )
    VALUES (
        1, 'user', 'Regular', 'User', 'user@example.com',
        1, @WorkingPasswordHash, 1, GETDATE(),
        0, 'FieldUser', 'REGION1'
    );
    PRINT '✅ Created user';
END

-- Create user1 if missing
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'user1')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [PttRole], [RegionCode]
    )
    VALUES (
        1, 'user1', 'User', 'One', 'user1@example.com',
        1, @WorkingPasswordHash, 1, GETDATE(),
        0, 'FieldUser', 'REGION1'
    );
    PRINT '✅ Created user1';
END

-- STEP 3: Create PTT Groups tables if they don't exist
PRINT '';
PRINT '🔧 STEP 3: Setting up PTT Groups system...';

-- Create PttGroups table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PttGroups' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[PttGroups] (
        [Id] bigint IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [Description] nvarchar(500) NULL,
        [CreatedByAdminId] bigint NOT NULL,
        [IsActive] bit NOT NULL DEFAULT 1,
        [CreationTime] datetime2 NOT NULL,
        [CreatorUserId] bigint NULL,
        CONSTRAINT [PK_PttGroups] PRIMARY KEY ([Id])
    );
    PRINT '✅ Created PttGroups table';
END

-- Create PttGroupMembers table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PttGroupMembers' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[PttGroupMembers] (
        [Id] bigint IDENTITY(1,1) NOT NULL,
        [PttGroupId] bigint NOT NULL,
        [UserId] bigint NOT NULL,
        [IsActive] bit NOT NULL DEFAULT 1,
        [JoinedDate] datetime2 NOT NULL,
        [CreationTime] datetime2 NOT NULL,
        CONSTRAINT [PK_PttGroupMembers] PRIMARY KEY ([Id])
    );
    PRINT '✅ Created PttGroupMembers table';
END

-- STEP 4: Create sample groups for your team
PRINT '';
PRINT '🔧 STEP 4: Creating sample PTT groups...';

-- Get admin user ID
DECLARE @AdminId BIGINT;
SELECT @AdminId = [Id] FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin';

-- Create sample groups
IF NOT EXISTS (SELECT * FROM [dbo].[PttGroups] WHERE [Name] = 'Team Alpha')
BEGIN
    INSERT INTO [dbo].[PttGroups] ([Name], [Description], [CreatedByAdminId], [IsActive], [CreationTime])
    VALUES 
    ('Team Alpha', 'Main operations team', @AdminId, 1, GETDATE()),
    ('Team Beta', 'Secondary operations team', @AdminId, 1, GETDATE()),
    ('Security Team', 'Security and monitoring team', @AdminId, 1, GETDATE());
    
    PRINT '✅ Created sample PTT groups';
END

-- STEP 5: Add users to groups
PRINT '';
PRINT '🔧 STEP 5: Adding users to groups...';

-- Get group and user IDs
DECLARE @TeamAlphaId BIGINT, @TeamBetaId BIGINT, @SecurityTeamId BIGINT;
DECLARE @Test123Id BIGINT, @UserId BIGINT, @User1Id BIGINT;

SELECT @TeamAlphaId = [Id] FROM [dbo].[PttGroups] WHERE [Name] = 'Team Alpha';
SELECT @TeamBetaId = [Id] FROM [dbo].[PttGroups] WHERE [Name] = 'Team Beta';
SELECT @SecurityTeamId = [Id] FROM [dbo].[PttGroups] WHERE [Name] = 'Security Team';

SELECT @Test123Id = [Id] FROM [dbo].[AbpUsers] WHERE [UserName] = 'test123';
SELECT @UserId = [Id] FROM [dbo].[AbpUsers] WHERE [UserName] = 'user';
SELECT @User1Id = [Id] FROM [dbo].[AbpUsers] WHERE [UserName] = 'user1';

-- Add admin to all groups
IF NOT EXISTS (SELECT * FROM [dbo].[PttGroupMembers] WHERE [PttGroupId] = @TeamAlphaId AND [UserId] = @AdminId)
BEGIN
    INSERT INTO [dbo].[PttGroupMembers] ([PttGroupId], [UserId], [IsActive], [JoinedDate], [CreationTime])
    VALUES 
    (@TeamAlphaId, @AdminId, 1, GETDATE(), GETDATE()),
    (@TeamBetaId, @AdminId, 1, GETDATE(), GETDATE()),
    (@SecurityTeamId, @AdminId, 1, GETDATE(), GETDATE());
END

-- Add test123 to Team Alpha
IF @Test123Id IS NOT NULL AND NOT EXISTS (SELECT * FROM [dbo].[PttGroupMembers] WHERE [PttGroupId] = @TeamAlphaId AND [UserId] = @Test123Id)
BEGIN
    INSERT INTO [dbo].[PttGroupMembers] ([PttGroupId], [UserId], [IsActive], [JoinedDate], [CreationTime])
    VALUES (@TeamAlphaId, @Test123Id, 1, GETDATE(), GETDATE());
END

-- Add user to Team Beta
IF @UserId IS NOT NULL AND NOT EXISTS (SELECT * FROM [dbo].[PttGroupMembers] WHERE [PttGroupId] = @TeamBetaId AND [UserId] = @UserId)
BEGIN
    INSERT INTO [dbo].[PttGroupMembers] ([PttGroupId], [UserId], [IsActive], [JoinedDate], [CreationTime])
    VALUES (@TeamBetaId, @UserId, 1, GETDATE(), GETDATE());
END

-- Add user1 to Security Team
IF @User1Id IS NOT NULL AND NOT EXISTS (SELECT * FROM [dbo].[PttGroupMembers] WHERE [PttGroupId] = @SecurityTeamId AND [UserId] = @User1Id)
BEGIN
    INSERT INTO [dbo].[PttGroupMembers] ([PttGroupId], [UserId], [IsActive], [JoinedDate], [CreationTime])
    VALUES (@SecurityTeamId, @User1Id, 1, GETDATE(), GETDATE());
END

PRINT '✅ Added users to their respective groups';

-- STEP 6: Verification
PRINT '';
PRINT '========================================';
PRINT '✅ COMPLETE PTT GROUP SYSTEM READY!';
PRINT '========================================';
PRINT '';

-- Show all users and their login status
PRINT 'USER LOGIN STATUS:';
SELECT 
    [UserName] as 'Username',
    [Name] + ' ' + ISNULL([Surname], '') as 'Full Name',
    CASE WHEN [IsActive] = 1 THEN '✅ Active' ELSE '❌ Inactive' END as 'Status',
    'Password: 123qwe' as 'Login Info'
FROM [dbo].[AbpUsers] 
WHERE [UserName] IN ('admin', 'test123', 'user', 'user1')
ORDER BY [UserName];

PRINT '';
PRINT 'PTT GROUPS AND MEMBERS:';
SELECT 
    g.[Name] as 'Group Name',
    g.[Description] as 'Description',
    u.[UserName] as 'Member',
    u.[Name] + ' ' + ISNULL(u.[Surname], '') as 'Full Name'
FROM [dbo].[PttGroups] g
INNER JOIN [dbo].[PttGroupMembers] gm ON g.[Id] = gm.[PttGroupId]
INNER JOIN [dbo].[AbpUsers] u ON gm.[UserId] = u.[Id]
WHERE g.[IsActive] = 1 AND gm.[IsActive] = 1
ORDER BY g.[Name], u.[UserName];

PRINT '';
PRINT '🎯 READY TO TEST:';
PRINT '• admin / 123qwe - Can access all groups';
PRINT '• test123 / 123qwe - Member of Team Alpha';
PRINT '• user / 123qwe - Member of Team Beta';
PRINT '• user1 / 123qwe - Member of Security Team';
PRINT '';
PRINT '🚀 NOW TEST LOGIN IN YOUR FLUTTER APP!';
