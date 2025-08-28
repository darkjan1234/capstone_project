-- PTT Groups Tables Creation Script
-- Run this script manually if Entity Framework migration fails

-- Create PttGroups table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PttGroups' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[PttGroups] (
        [Id] bigint IDENTITY(1,1) NOT NULL,
        [Name] nvarchar(128) NOT NULL,
        [Description] nvarchar(500) NULL,
        [CreatedByAdminId] bigint NOT NULL,
        [ParentGroupId] bigint NULL,
        [HierarchyLevel] int NOT NULL DEFAULT 0,
        [IsActive] bit NOT NULL DEFAULT 1,
        [GroupType] int NOT NULL DEFAULT 2,
        [CreationTime] datetime2 NOT NULL,
        [CreatorUserId] bigint NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierUserId] bigint NULL,
        [IsDeleted] bit NOT NULL DEFAULT 0,
        [DeleterUserId] bigint NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_PttGroups] PRIMARY KEY ([Id])
    );
    
    PRINT 'PttGroups table created successfully';
END
ELSE
BEGIN
    PRINT 'PttGroups table already exists';
END

-- Create PttGroupMembers table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PttGroupMembers' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[PttGroupMembers] (
        [Id] bigint IDENTITY(1,1) NOT NULL,
        [PttGroupId] bigint NOT NULL,
        [UserId] bigint NOT NULL,
        [Role] int NOT NULL DEFAULT 1,
        [IsActive] bit NOT NULL DEFAULT 1,
        [JoinedDate] datetime2 NOT NULL,
        [AddedByAdminId] bigint NULL,
        [CreationTime] datetime2 NOT NULL,
        [CreatorUserId] bigint NULL,
        [LastModificationTime] datetime2 NULL,
        [LastModifierUserId] bigint NULL,
        [IsDeleted] bit NOT NULL DEFAULT 0,
        [DeleterUserId] bigint NULL,
        [DeletionTime] datetime2 NULL,
        CONSTRAINT [PK_PttGroupMembers] PRIMARY KEY ([Id])
    );
    
    PRINT 'PttGroupMembers table created successfully';
END
ELSE
BEGIN
    PRINT 'PttGroupMembers table already exists';
END

-- Add foreign key constraints with NO ACTION to prevent cascade conflicts
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PttGroups_AbpUsers_CreatedByAdminId')
BEGIN
    ALTER TABLE [dbo].[PttGroups]
    ADD CONSTRAINT [FK_PttGroups_AbpUsers_CreatedByAdminId] 
    FOREIGN KEY ([CreatedByAdminId]) REFERENCES [dbo].[AbpUsers] ([Id]) ON DELETE NO ACTION;
    
    PRINT 'FK_PttGroups_AbpUsers_CreatedByAdminId constraint added';
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PttGroups_PttGroups_ParentGroupId')
BEGIN
    ALTER TABLE [dbo].[PttGroups]
    ADD CONSTRAINT [FK_PttGroups_PttGroups_ParentGroupId] 
    FOREIGN KEY ([ParentGroupId]) REFERENCES [dbo].[PttGroups] ([Id]) ON DELETE NO ACTION;
    
    PRINT 'FK_PttGroups_PttGroups_ParentGroupId constraint added';
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PttGroupMembers_PttGroups_PttGroupId')
BEGIN
    ALTER TABLE [dbo].[PttGroupMembers]
    ADD CONSTRAINT [FK_PttGroupMembers_PttGroups_PttGroupId] 
    FOREIGN KEY ([PttGroupId]) REFERENCES [dbo].[PttGroups] ([Id]) ON DELETE NO ACTION;
    
    PRINT 'FK_PttGroupMembers_PttGroups_PttGroupId constraint added';
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PttGroupMembers_AbpUsers_UserId')
BEGIN
    ALTER TABLE [dbo].[PttGroupMembers]
    ADD CONSTRAINT [FK_PttGroupMembers_AbpUsers_UserId] 
    FOREIGN KEY ([UserId]) REFERENCES [dbo].[AbpUsers] ([Id]) ON DELETE NO ACTION;
    
    PRINT 'FK_PttGroupMembers_AbpUsers_UserId constraint added';
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PttGroupMembers_AbpUsers_AddedByAdminId')
BEGIN
    ALTER TABLE [dbo].[PttGroupMembers]
    ADD CONSTRAINT [FK_PttGroupMembers_AbpUsers_AddedByAdminId] 
    FOREIGN KEY ([AddedByAdminId]) REFERENCES [dbo].[AbpUsers] ([Id]) ON DELETE NO ACTION;
    
    PRINT 'FK_PttGroupMembers_AbpUsers_AddedByAdminId constraint added';
END

-- Create indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PttGroups_CreatedByAdminId')
BEGIN
    CREATE INDEX [IX_PttGroups_CreatedByAdminId] ON [dbo].[PttGroups] ([CreatedByAdminId]);
    PRINT 'IX_PttGroups_CreatedByAdminId index created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PttGroups_ParentGroupId')
BEGIN
    CREATE INDEX [IX_PttGroups_ParentGroupId] ON [dbo].[PttGroups] ([ParentGroupId]);
    PRINT 'IX_PttGroups_ParentGroupId index created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PttGroups_Name')
BEGIN
    CREATE INDEX [IX_PttGroups_Name] ON [dbo].[PttGroups] ([Name]);
    PRINT 'IX_PttGroups_Name index created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PttGroups_IsActive')
BEGIN
    CREATE INDEX [IX_PttGroups_IsActive] ON [dbo].[PttGroups] ([IsActive]);
    PRINT 'IX_PttGroups_IsActive index created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PttGroupMembers_PttGroupId')
BEGIN
    CREATE INDEX [IX_PttGroupMembers_PttGroupId] ON [dbo].[PttGroupMembers] ([PttGroupId]);
    PRINT 'IX_PttGroupMembers_PttGroupId index created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PttGroupMembers_UserId')
BEGIN
    CREATE INDEX [IX_PttGroupMembers_UserId] ON [dbo].[PttGroupMembers] ([UserId]);
    PRINT 'IX_PttGroupMembers_UserId index created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PttGroupMembers_AddedByAdminId')
BEGIN
    CREATE INDEX [IX_PttGroupMembers_AddedByAdminId] ON [dbo].[PttGroupMembers] ([AddedByAdminId]);
    PRINT 'IX_PttGroupMembers_AddedByAdminId index created';
END

-- Create unique constraint for group membership (prevent duplicates)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PttGroupMembers_PttGroupId_UserId')
BEGIN
    CREATE UNIQUE INDEX [IX_PttGroupMembers_PttGroupId_UserId] 
    ON [dbo].[PttGroupMembers] ([PttGroupId], [UserId]) 
    WHERE [IsDeleted] = 0;
    PRINT 'IX_PttGroupMembers_PttGroupId_UserId unique index created';
END

-- Insert sample data (only if admin user exists)
IF EXISTS (SELECT 1 FROM [dbo].[AbpUsers] WHERE [Id] = 1)
BEGIN
    -- Insert sample PTT groups for admin user (ID = 1)
    IF NOT EXISTS (SELECT 1 FROM [dbo].[PttGroups] WHERE [Name] = 'Main Admin Group')
    BEGIN
        INSERT INTO [dbo].[PttGroups] ([Name], [Description], [CreatedByAdminId], [ParentGroupId], [HierarchyLevel], [IsActive], [GroupType], [CreationTime])
        VALUES 
        ('Main Admin Group', 'Root administrative group', 1, NULL, 0, 1, 1, GETUTCDATE()),
        ('Operations Team', 'Operations department group', 1, 1, 1, 1, 2, GETUTCDATE()),
        ('Security Team', 'Security department group', 1, 1, 1, 1, 2, GETUTCDATE()),
        ('Field Team Alpha', 'Field operations team A', 1, 2, 2, 1, 2, GETUTCDATE()),
        ('Field Team Beta', 'Field operations team B', 1, 2, 2, 1, 2, GETUTCDATE());
        
        PRINT 'Sample PTT groups inserted successfully';
    END
    ELSE
    BEGIN
        PRINT 'Sample PTT groups already exist';
    END
END
ELSE
BEGIN
    PRINT 'Admin user (ID=1) not found. Skipping sample data insertion.';
END

PRINT '';
PRINT '========================================';
PRINT '✅ PTT Groups tables created successfully!';
PRINT '========================================';
PRINT 'Tables created:';
PRINT '- PttGroups (with hierarchy support)';
PRINT '- PttGroupMembers (with role management)';
PRINT 'All foreign key constraints use NO ACTION to prevent cascade conflicts.';
PRINT 'Sample data inserted for testing (if admin user exists).';
PRINT '';
