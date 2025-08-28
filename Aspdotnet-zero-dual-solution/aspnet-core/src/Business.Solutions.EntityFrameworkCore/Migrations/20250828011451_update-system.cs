using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Business.Solutions.Migrations
{
    /// <inheritdoc />
    public partial class updatesystem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PttGroups",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedByAdminId = table.Column<long>(type: "bigint", nullable: false),
                    ParentGroupId = table.Column<long>(type: "bigint", nullable: true),
                    HierarchyLevel = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    GroupType = table.Column<int>(type: "int", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PttGroups", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PttGroups_AbpUsers_CreatedByAdminId",
                        column: x => x.CreatedByAdminId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PttGroups_PttGroups_ParentGroupId",
                        column: x => x.ParentGroupId,
                        principalTable: "PttGroups",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "PttGroupMembers",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PttGroupId = table.Column<long>(type: "bigint", nullable: false),
                    UserId = table.Column<long>(type: "bigint", nullable: false),
                    Role = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    JoinedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    AddedByAdminId = table.Column<long>(type: "bigint", nullable: true),
                    CreationTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatorUserId = table.Column<long>(type: "bigint", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastModifierUserId = table.Column<long>(type: "bigint", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false),
                    DeleterUserId = table.Column<long>(type: "bigint", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PttGroupMembers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PttGroupMembers_AbpUsers_AddedByAdminId",
                        column: x => x.AddedByAdminId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_PttGroupMembers_AbpUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AbpUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PttGroupMembers_PttGroups_PttGroupId",
                        column: x => x.PttGroupId,
                        principalTable: "PttGroups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PttGroupMembers_AddedByAdminId",
                table: "PttGroupMembers",
                column: "AddedByAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroupMembers_PttGroupId",
                table: "PttGroupMembers",
                column: "PttGroupId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroupMembers_UserId",
                table: "PttGroupMembers",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroups_CreatedByAdminId",
                table: "PttGroups",
                column: "CreatedByAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_PttGroups_ParentGroupId",
                table: "PttGroups",
                column: "ParentGroupId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PttGroupMembers");

            migrationBuilder.DropTable(
                name: "PttGroups");
        }
    }
}
