-- Add RegionCode and PttRole columns to support PPO regional security
-- Run this SQL script on your database

-- Add RegionCode to Users table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AbpUsers]') AND name = 'RegionCode')
BEGIN
    ALTER TABLE [dbo].[AbpUsers] 
    ADD [RegionCode] NVARCHAR(50) NULL;
    
    PRINT 'Added RegionCode column to AbpUsers table';
END
ELSE
BEGIN
    PRINT 'RegionCode column already exists in AbpUsers table';
END

-- Add PttRole to Users table  
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AbpUsers]') AND name = 'PttRole')
BEGIN
    ALTER TABLE [dbo].[AbpUsers] 
    ADD [PttRole] NVARCHAR(50) NULL;
    
    PRINT 'Added PttRole column to AbpUsers table';
END
ELSE
BEGIN
    PRINT 'PttRole column already exists in AbpUsers table';
END

-- Add RegionCode to PttGroups table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[PttGroups]') AND name = 'RegionCode')
BEGIN
    ALTER TABLE [dbo].[PttGroups] 
    ADD [RegionCode] NVARCHAR(50) NULL;
    
    PRINT 'Added RegionCode column to PttGroups table';
END
ELSE
BEGIN
    PRINT 'RegionCode column already exists in PttGroups table';
END

-- Create sample data for testing
PRINT 'Setting up sample PPO regions...';

-- Update admin user to be Super Admin (no region)
UPDATE [dbo].[AbpUsers] 
SET [PttRole] = 'SuperAdmin', [RegionCode] = NULL 
WHERE [UserName] = 'admin';

-- Create sample PPO regions if they don't exist
IF NOT EXISTS (SELECT * FROM [dbo].[PttGroups] WHERE [Name] = 'PPO Region 1')
BEGIN
    INSERT INTO [dbo].[PttGroups] ([Name], [Description], [RegionCode], [GroupType], [CreatedByAdminId], [HierarchyLevel], [IsActive], [CreationTime], [IsDeleted])
    VALUES ('PPO Region 1', 'Police Provincial Office - Region 1', 'REGION1', 1, 1, 0, 1, GETDATE(), 0);
    
    PRINT 'Created PPO Region 1';
END

IF NOT EXISTS (SELECT * FROM [dbo].[PttGroups] WHERE [Name] = 'PPO Region 2')
BEGIN
    INSERT INTO [dbo].[PttGroups] ([Name], [Description], [RegionCode], [GroupType], [CreatedByAdminId], [HierarchyLevel], [IsActive], [CreationTime], [IsDeleted])
    VALUES ('PPO Region 2', 'Police Provincial Office - Region 2', 'REGION2', 1, 1, 0, 1, GETDATE(), 0);
    
    PRINT 'Created PPO Region 2';
END

IF NOT EXISTS (SELECT * FROM [dbo].[PttGroups] WHERE [Name] = 'PPO Bohol')
BEGIN
    INSERT INTO [dbo].[PttGroups] ([Name], [Description], [RegionCode], [GroupType], [CreatedByAdminId], [HierarchyLevel], [IsActive], [CreationTime], [IsDeleted])
    VALUES ('PPO Bohol', 'Police Provincial Office - Bohol', 'BOHOL', 1, 1, 0, 1, GETDATE(), 0);
    
    PRINT 'Created PPO Bohol';
END

IF NOT EXISTS (SELECT * FROM [dbo].[PttGroups] WHERE [Name] = 'PPO Cebu')
BEGIN
    INSERT INTO [dbo].[PttGroups] ([Name], [Description], [RegionCode], [GroupType], [CreatedByAdminId], [HierarchyLevel], [IsActive], [CreationTime], [IsDeleted])
    VALUES ('PPO Cebu', 'Police Provincial Office - Cebu', 'CEBU', 1, 1, 0, 1, GETDATE(), 0);
    
    PRINT 'Created PPO Cebu';
END

PRINT 'Database update completed successfully!';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Create PPO Admin users for each region';
PRINT '2. Assign RegionCode and PttRole to users';
PRINT '3. Test regional communication restrictions';
PRINT '';
PRINT 'Example user assignments:';
PRINT '- Super Admin: PttRole=SuperAdmin, RegionCode=NULL (can access all)';
PRINT '- PPO Admin: PttRole=PPOAdmin, RegionCode=REGION1 (can manage Region 1 only)';
PRINT '- Field User: PttRole=FieldUser, RegionCode=REGION1 (can use Region 1 only)';
