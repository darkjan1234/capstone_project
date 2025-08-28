using Microsoft.EntityFrameworkCore.Migrations;
using System;

namespace Business.Solutions.Migrations
{
    public partial class AddPttGroupTablesFixed : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Create PttGroups table
            migrationBuilder.CreateTable(
                name: "PttGroups",
                columns: table => new
                {
                    Id = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(maxLength: 128, nullable: false),
                    Description = table.Column<string>(maxLength: 500, nullable: true),
                    CreatedByAdminId = table.Column<long>(nullable: false),
                    ParentGroupId = table.Column<long>(nullable: true),
                    HierarchyLevel = table.Column<int>(nullable: false, defaultValue: 0),
                    IsActive = table.Column<bool>(nullable: false, defaultValue: true),
                    GroupType = table.Column<int>(nullable: false, defaultValue: 2), // User = 2
                    CreationTime = table.Column<DateTime>(nullable: false),
                    CreatorUserId = table.Column<long>(nullable: true),
                    LastModificationTime = table.Column<DateTime>(nullable: true),
                    LastModifierUserId = table.Column<long>(nullable: true),
                    IsDeleted = table.Column<bool>(nullable: false, defaultValue: false),
                    DeleterUserId = table.Column<long>(nullable: true),
                    DeletionTime = table.Column<DateTime>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PttGroups", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PttGroups_AbpUsers_CreatedByAdminId",
                        column: x => x.CreatedByAdminId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PttGroups_PttGroups_ParentGroupId",
                        column: x => x.ParentGroupId,
                        principalTable: "PttGroups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            // Create PttGroupMembers table
            migrationBuilder.CreateTable(
                name: "PttGroupMembers",
                columns: table => new
                {
                    Id = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PttGroupId = table.Column<long>(nullable: false),
                    UserId = table.Column<long>(nullable: false),
                    Role = table.Column<int>(nullable: false, defaultValue: 1), // User = 1
                    IsActive = table.Column<bool>(nullable: false, defaultValue: true),
                    JoinedDate = table.Column<DateTime>(nullable: false),
                    AddedByAdminId = table.Column<long>(nullable: true),
                    CreationTime = table.Column<DateTime>(nullable: false),
                    CreatorUserId = table.Column<long>(nullable: true),
                    LastModificationTime = table.Column<DateTime>(nullable: true),
                    LastModifierUserId = table.Column<long>(nullable: true),
                    IsDeleted = table.Column<bool>(nullable: false, defaultValue: false),
                    DeleterUserId = table.Column<long>(nullable: true),
                    DeletionTime = table.Column<DateTime>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PttGroupMembers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PttGroupMembers_PttGroups_PttGroupId",
                        column: x => x.PttGroupId,
                        principalTable: "PttGroups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PttGroupMembers_AbpUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_PttGroupMembers_AbpUsers_AddedByAdminId",
                        column: x => x.AddedByAdminId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            // Create indexes
            migrationBuilder.CreateIndex(
                name: "IX_PttGroups_CreatedByAdminId",
                table: "PttGroups",
                column: "CreatedByAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroups_ParentGroupId",
                table: "PttGroups",
                column: "ParentGroupId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroups_Name",
                table: "PttGroups",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroups_IsActive",
                table: "PttGroups",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroupMembers_PttGroupId",
                table: "PttGroupMembers",
                column: "PttGroupId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroupMembers_UserId",
                table: "PttGroupMembers",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroupMembers_AddedByAdminId",
                table: "PttGroupMembers",
                column: "AddedByAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroupMembers_PttGroupId_UserId",
                table: "PttGroupMembers",
                columns: new[] { "PttGroupId", "UserId" },
                unique: true,
                filter: "[IsDeleted] = 0");

            // Insert sample data
            migrationBuilder.Sql(@"
                -- Insert sample PTT groups for admin user (assuming admin user ID = 1)
                INSERT INTO PttGroups (Name, Description, CreatedByAdminId, ParentGroupId, HierarchyLevel, IsActive, GroupType, CreationTime)
                VALUES 
                ('Main Admin Group', 'Root administrative group', 1, NULL, 0, 1, 1, GETUTCDATE()),
                ('Operations Team', 'Operations department group', 1, 1, 1, 1, 2, GETUTCDATE()),
                ('Security Team', 'Security department group', 1, 1, 1, 1, 2, GETUTCDATE()),
                ('Field Team Alpha', 'Field operations team A', 1, 2, 2, 1, 2, GETUTCDATE()),
                ('Field Team Beta', 'Field operations team B', 1, 2, 2, 1, 2, GETUTCDATE());
            ");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PttGroupMembers");

            migrationBuilder.DropTable(
                name: "PttGroups");
        }
    }
}
