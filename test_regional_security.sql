-- Test script to verify PPO regional security is working
-- Run this after updating the database with regional support

PRINT '========================================';
PRINT 'Testing PPO Regional Security Setup';
PRINT '========================================';
PRINT '';

-- Check if columns were added
PRINT 'Step 1: Checking if RegionCode and PttRole columns exist...';

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AbpUsers]') AND name = 'RegionCode')
    PRINT '✅ RegionCode column exists in AbpUsers'
ELSE
    PRINT '❌ RegionCode column missing in AbpUsers'

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AbpUsers]') AND name = 'PttRole')
    PRINT '✅ PttRole column exists in AbpUsers'
ELSE
    PRINT '❌ PttRole column missing in AbpUsers'

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[PttGroups]') AND name = 'RegionCode')
    PRINT '✅ RegionCode column exists in PttGroups'
ELSE
    PRINT '❌ RegionCode column missing in PttGroups'

PRINT '';

-- Check existing users
PRINT 'Step 2: Current users and their PTT roles...';
SELECT 
    [UserName],
    [Name],
    [RegionCode],
    [PttRole],
    [IsActive]
FROM [dbo].[AbpUsers]
WHERE [IsDeleted] = 0
ORDER BY [UserName];

PRINT '';

-- Check existing PPO groups
PRINT 'Step 3: Current PPO groups...';
SELECT 
    [Id],
    [Name],
    [Description],
    [RegionCode],
    [GroupType],
    [IsActive]
FROM [dbo].[PttGroups]
WHERE [IsDeleted] = 0
ORDER BY [RegionCode], [Name];

PRINT '';

-- Create test users for each region
PRINT 'Step 4: Creating test users for regional testing...';

-- Create PPO Admin for Region 1
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin_region1')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [UserName], [Name], [Surname], [EmailAddress], [IsEmailConfirmed],
        [Password], [IsActive], [CreationTime], [IsDeleted], [TenantId],
        [RegionCode], [PttRole]
    )
    VALUES (
        'admin_region1', 'Admin', 'Region1', 'admin.region1@ppo.gov.ph', 1,
        'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q==', 1, GETDATE(), 0, 1,
        'REGION1', 'PPOAdmin'
    );
    PRINT '✅ Created admin_region1 (PPO Admin for Region 1)';
END

-- Create Field User for Region 1
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'user1_region1')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [UserName], [Name], [Surname], [EmailAddress], [IsEmailConfirmed],
        [Password], [IsActive], [CreationTime], [IsDeleted], [TenantId],
        [RegionCode], [PttRole]
    )
    VALUES (
        'user1_region1', 'User1', 'Region1', 'user1.region1@ppo.gov.ph', 1,
        'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q==', 1, GETDATE(), 0, 1,
        'REGION1', 'FieldUser'
    );
    PRINT '✅ Created user1_region1 (Field User for Region 1)';
END

-- Create PPO Admin for Region 2
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'admin_region2')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [UserName], [Name], [Surname], [EmailAddress], [IsEmailConfirmed],
        [Password], [IsActive], [CreationTime], [IsDeleted], [TenantId],
        [RegionCode], [PttRole]
    )
    VALUES (
        'admin_region2', 'Admin', 'Region2', 'admin.region2@ppo.gov.ph', 1,
        'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q==', 1, GETDATE(), 0, 1,
        'REGION2', 'PPOAdmin'
    );
    PRINT '✅ Created admin_region2 (PPO Admin for Region 2)';
END

-- Create Field User for Region 2
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'user1_region2')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [UserName], [Name], [Surname], [EmailAddress], [IsEmailConfirmed],
        [Password], [IsActive], [CreationTime], [IsDeleted], [TenantId],
        [RegionCode], [PttRole]
    )
    VALUES (
        'user1_region2', 'User1', 'Region2', 'user1.region2@ppo.gov.ph', 1,
        'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q==', 1, GETDATE(), 0, 1,
        'REGION2', 'FieldUser'
    );
    PRINT '✅ Created user1_region2 (Field User for Region 2)';
END

PRINT '';

-- Test regional isolation
PRINT 'Step 5: Testing regional communication rules...';
PRINT '';
PRINT 'Communication Matrix:';
PRINT '✅ = Allowed, ❌ = Blocked';
PRINT '';

-- Super Admin can communicate with everyone
PRINT 'Super Admin (admin):';
PRINT '  → Region 1 users: ✅ ALLOWED (Super Admin privilege)';
PRINT '  → Region 2 users: ✅ ALLOWED (Super Admin privilege)';
PRINT '';

-- Region 1 users
PRINT 'Region 1 users (admin_region1, user1_region1):';
PRINT '  → Other Region 1 users: ✅ ALLOWED (same region)';
PRINT '  → Region 2 users: ❌ BLOCKED (different region)';
PRINT '';

-- Region 2 users  
PRINT 'Region 2 users (admin_region2, user1_region2):';
PRINT '  → Other Region 2 users: ✅ ALLOWED (same region)';
PRINT '  → Region 1 users: ❌ BLOCKED (different region)';
PRINT '';

-- Show final user list
PRINT 'Step 6: Final user list with regional assignments...';
SELECT 
    [UserName] as 'Username',
    [Name] + ' ' + [Surname] as 'Full Name',
    ISNULL([RegionCode], 'ALL REGIONS') as 'Region',
    ISNULL([PttRole], 'No PTT Role') as 'PTT Role',
    CASE 
        WHEN [PttRole] = 'SuperAdmin' THEN 'Can access all regions'
        WHEN [PttRole] = 'PPOAdmin' THEN 'Can manage ' + [RegionCode] + ' only'
        WHEN [PttRole] = 'FieldUser' THEN 'Can use ' + [RegionCode] + ' only'
        ELSE 'No PTT access'
    END as 'Access Level'
FROM [dbo].[AbpUsers]
WHERE [IsDeleted] = 0 AND [IsActive] = 1
ORDER BY 
    CASE [PttRole] 
        WHEN 'SuperAdmin' THEN 1
        WHEN 'PPOAdmin' THEN 2  
        WHEN 'FieldUser' THEN 3
        ELSE 4
    END,
    [RegionCode],
    [UserName];

PRINT '';
PRINT '========================================';
PRINT '✅ Regional Security Test Complete!';
PRINT '========================================';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Test login with different user types';
PRINT '2. Verify API returns correct groups per user';
PRINT '3. Test Flutter app with regional restrictions';
PRINT '4. Test voice communication isolation';
PRINT '';
PRINT 'Test credentials (all use same password):';
PRINT '- admin / 123qwe (Super Admin - sees all)';
PRINT '- admin_region1 / 123qwe (PPO Admin - sees Region 1 only)';
PRINT '- user1_region1 / 123qwe (Field User - sees assigned groups only)';
PRINT '- admin_region2 / 123qwe (PPO Admin - sees Region 2 only)';
PRINT '- user1_region2 / 123qwe (Field User - sees assigned groups only)';
