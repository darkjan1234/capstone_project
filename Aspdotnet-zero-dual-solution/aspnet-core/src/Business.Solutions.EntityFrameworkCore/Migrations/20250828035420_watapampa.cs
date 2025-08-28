using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Business.Solutions.Migrations
{
    public partial class watapampa : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Drop old foreign keys
            migrationBuilder.DropForeignKey("FK_PttGroupMembers_AbpUsers_AddedByAdminId", "PttGroupMembers");
            migrationBuilder.DropForeignKey("FK_PttGroupMembers_AbpUsers_UserId", "PttGroupMembers");
            migrationBuilder.DropForeignKey("FK_PttGroupMembers_PttGroups_PttGroupId", "PttGroupMembers");
            migrationBuilder.DropForeignKey("FK_PttGroups_AbpUsers_CreatedByAdminId", "PttGroups");
            migrationBuilder.DropForeignKey("FK_PttGroups_PttGroups_ParentGroupId", "PttGroups");

            migrationBuilder.DropIndex("IX_PttGroupMembers_PttGroupId", "PttGroupMembers");

            // Add new columns
            migrationBuilder.AddColumn<string>("RegionCode", "PttGroups", type: "nvarchar(50)", maxLength: 50, nullable: true);
            //migrationBuilder.AddColumn<string>("PttRole", "AbpUsers", type: "nvarchar(max)", nullable: true);
            //migrationBuilder.AddColumn<string>("RegionCode", "AbpUsers", type: "nvarchar(max)", nullable: true);

            // Conditionally create unique index
            migrationBuilder.Sql(@"
                IF NOT EXISTS (
                    SELECT * FROM sys.indexes
                    WHERE name = 'IX_PttGroupMembers_PttGroupId_UserId'
                      AND object_id = OBJECT_ID(N'[dbo].[PttGroupMembers]')
                )
                BEGIN
                    CREATE UNIQUE INDEX [IX_PttGroupMembers_PttGroupId_UserId]
                        ON [dbo].[PttGroupMembers] ([PttGroupId], [UserId])
                        WHERE [IsDeleted] = 0;
                END
            ");

            // Re-add foreign keys with restricted delete behavior
            migrationBuilder.AddForeignKey(
                "FK_PttGroupMembers_AbpUsers_AddedByAdminId",
                "PttGroupMembers",
                "AddedByAdminId",
                "AbpUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                "FK_PttGroupMembers_AbpUsers_UserId",
                "PttGroupMembers",
                "UserId",
                "AbpUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                "FK_PttGroupMembers_PttGroups_PttGroupId",
                "PttGroupMembers",
                "PttGroupId",
                "PttGroups",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                "FK_PttGroups_AbpUsers_CreatedByAdminId",
                "PttGroups",
                "CreatedByAdminId",
                "AbpUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                "FK_PttGroups_PttGroups_ParentGroupId",
                "PttGroups",
                "ParentGroupId",
                "PttGroups",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Drop the conditional index if it exists
            migrationBuilder.Sql(@"
                IF EXISTS (
                    SELECT * FROM sys.indexes
                    WHERE name = 'IX_PttGroupMembers_PttGroupId_UserId'
                      AND object_id = OBJECT_ID(N'[dbo].[PttGroupMembers]')
                )
                BEGIN
                    DROP INDEX [IX_PttGroupMembers_PttGroupId_UserId] ON [dbo].[PttGroupMembers];
                END
            ");

            // Drop your added columns
            migrationBuilder.DropColumn("RegionCode", "PttGroups");
            migrationBuilder.DropColumn("PttRole", "AbpUsers");
            migrationBuilder.DropColumn("RegionCode", "AbpUsers");

            // Re-create previous index
            migrationBuilder.CreateIndex("IX_PttGroupMembers_PttGroupId", "PttGroupMembers", "PttGroupId");

            // Re-add original foreign keys with previous cascade behavior
            migrationBuilder.AddForeignKey(
                "FK_PttGroupMembers_AbpUsers_AddedByAdminId",
                "PttGroupMembers",
                "AddedByAdminId",
                "AbpUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                "FK_PttGroupMembers_AbpUsers_UserId",
                "PttGroupMembers",
                "UserId",
                "AbpUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                "FK_PttGroupMembers_PttGroups_PttGroupId",
                "PttGroupMembers",
                "PttGroupId",
                "PttGroups",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                "FK_PttGroups_AbpUsers_CreatedByAdminId",
                "PttGroups",
                "CreatedByAdminId",
                "AbpUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                "FK_PttGroups_PttGroups_ParentGroupId",
                "PttGroups",
                "ParentGroupId",
                "PttGroups",
                principalColumn: "Id");
        }
    }
}
