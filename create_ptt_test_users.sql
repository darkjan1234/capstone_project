-- Create test users for PTT voice transmission testing
-- Run this SQL script to quickly create users

PRINT 'Creating PTT test users...';
PRINT '';

-- Check if users already exist
IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'john')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [RegionCode], [PttRole]
    )
    VALUES (
        1, 'john', 'John', 'Doe', 'john@test.com',
        1, 'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q==', 1, GETDATE(),
        0, 'REGION1', 'FieldUser'
    );
    PRINT '✅ Created user: john (Region 1 Field User)';
END
ELSE
BEGIN
    PRINT '✅ User john already exists';
END

IF NOT EXISTS (SELECT * FROM [dbo].[AbpUsers] WHERE [UserName] = 'user')
BEGIN
    INSERT INTO [dbo].[AbpUsers] (
        [TenantId], [UserName], [Name], [Surname], [EmailAddress], 
        [IsEmailConfirmed], [Password], [IsActive], [CreationTime], 
        [IsDeleted], [RegionCode], [PttRole]
    )
    VALUES (
        1, 'user', 'Test', 'User', 'user@test.com',
        1, 'AQAAAAEAACcQAAAAEKM8JNlQWlSgNVjJsNV1D1Oe2MQg2Q==', 1, GETDATE(),
        0, 'REGION1', 'FieldUser'
    );
    PRINT '✅ Created user: user (Region 1 Field User)';
END
ELSE
BEGIN
    PRINT '✅ User user already exists';
END

-- Make sure admin user has PTT role
UPDATE [dbo].[AbpUsers] 
SET [PttRole] = 'SuperAdmin', [RegionCode] = NULL 
WHERE [UserName] = 'admin';
PRINT '✅ Updated admin user as Super Admin';

PRINT '';
PRINT '========================================';
PRINT '✅ PTT Test Users Created Successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Test Users Created:';
PRINT '1. admin / 123qwe (Super Admin - All Regions)';
PRINT '2. john / 123qwe (Field User - Region 1)';
PRINT '3. user / 123qwe (Field User - Region 1)';
PRINT '';
PRINT 'All users can now:';
PRINT '✅ Login to the system';
PRINT '✅ Connect to PTT voice system';
PRINT '✅ Transmit and receive voice';
PRINT '✅ Communicate in same region';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Start your application: dotnet run';
PRINT '2. Test PTT: https://localhost:44301/ptt-test.html';
PRINT '3. Connect all 3 users and test voice transmission';
