using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Business.Solutions.Migrations
{
    public partial class updatesystem : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Execute conditional creation for PttGroups
            migrationBuilder.Sql(@"
                IF OBJECT_ID(N'[dbo].[PttGroups]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [PttGroups] (
                        [Id] bigint NOT NULL IDENTITY(1,1),
                        [Name] nvarchar(128) NOT NULL,
                        [Description] nvarchar(500) NULL,
                        [CreatedByAdminId] bigint NOT NULL,
                        [ParentGroupId] bigint NULL,
                        [HierarchyLevel] int NOT NULL,
                        [IsActive] bit NOT NULL,
                        [GroupType] int NOT NULL,
                        [CreationTime] datetime2 NOT NULL,
                        [CreatorUserId] bigint NULL,
                        [LastModificationTime] datetime2 NULL,
                        [LastModifierUserId] bigint NULL,
                        [IsDeleted] bit NOT NULL,
                        [DeleterUserId] bigint NULL,
                        [DeletionTime] datetime2 NULL,
                        CONSTRAINT [PK_PttGroups] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_PttGroups_AbpUsers_CreatedByAdminId]
                            FOREIGN KEY ([CreatedByAdminId]) REFERENCES [AbpUsers]([Id]) ON DELETE CASCADE,
                        CONSTRAINT [FK_PttGroups_PttGroups_ParentGroupId]
                            FOREIGN KEY ([ParentGroupId]) REFERENCES [PttGroups]([Id])
                    );
                    CREATE INDEX [IX_PttGroups_CreatedByAdminId] ON [PttGroups]([CreatedByAdminId]);
                    CREATE INDEX [IX_PttGroups_ParentGroupId] ON [PttGroups]([ParentGroupId]);
                END
            ");

            // Execute conditional creation for PttGroupMembers
            migrationBuilder.Sql(@"
                IF OBJECT_ID(N'[dbo].[PttGroupMembers]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [PttGroupMembers] (
                        [Id] bigint NOT NULL IDENTITY(1,1),
                        [PttGroupId] bigint NOT NULL,
                        [UserId] bigint NOT NULL,
                        [Role] int NOT NULL,
                        [IsActive] bit NOT NULL,
                        [JoinedDate] datetime2 NOT NULL,
                        [AddedByAdminId] bigint NULL,
                        [CreationTime] datetime2 NOT NULL,
                        [CreatorUserId] bigint NULL,
                        [LastModificationTime] datetime2 NULL,
                        [LastModifierUserId] bigint NULL,
                        [IsDeleted] bit NOT NULL,
                        [DeleterUserId] bigint NULL,
                        [DeletionTime] datetime2 NULL,
                        CONSTRAINT [PK_PttGroupMembers] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_PttGroupMembers_AbpUsers_AddedByAdminId]
                            FOREIGN KEY ([AddedByAdminId]) REFERENCES [AbpUsers]([Id]),
                        CONSTRAINT [FK_PttGroupMembers_AbpUsers_UserId]
                            FOREIGN KEY ([UserId]) REFERENCES [AbpUsers]([Id]) ON DELETE CASCADE,
                        CONSTRAINT [FK_PttGroupMembers_PttGroups_PttGroupId]
                            FOREIGN KEY ([PttGroupId]) REFERENCES [PttGroups]([Id]) ON DELETE CASCADE
                    );
                    CREATE INDEX [IX_PttGroupMembers_AddedByAdminId] ON [PttGroupMembers]([AddedByAdminId]);
                    CREATE INDEX [IX_PttGroupMembers_PttGroupId] ON [PttGroupMembers]([PttGroupId]);
                    CREATE INDEX [IX_PttGroupMembers_UserId] ON [PttGroupMembers]([UserId]);
                END
            ");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Only drop PttGroupMembers if it exists
            migrationBuilder.Sql(@"
                IF OBJECT_ID(N'[dbo].[PttGroupMembers]', N'U') IS NOT NULL
                BEGIN
                    DROP TABLE [PttGroupMembers];
                END
            ");

            // Only drop PttGroups if it exists
            migrationBuilder.Sql(@"
                IF OBJECT_ID(N'[dbo].[PttGroups]', N'U') IS NOT NULL
                BEGIN
                    DROP TABLE [PttGroups];
                END
            ");
        }
    }
}
