# 🚨 PTT System Setup Guide - PPO Regional Security

## 📋 System Overview

Your PTT system now supports **PPO-based regional isolation** with secure communication:

```
Main System (Head Office)
├── Super Admin (No Region) - Can access ALL regions
├── PPO Region 1 (Admin1) - Can only manage Region 1
│   ├── User1, User2, User3 - Can only talk within Region 1
│   └── Field Teams under Region 1
├── PPO Region 2 (Admin2) - Can only manage Region 2
│   ├── User4, User5, User6 - Can only talk within Region 2
│   └── Field Teams under Region 2
└── More regions as needed...
```

## 🔧 Setup Steps

### Step 1: Update Database
```bash
# Run this to add region support to database
create_ptt_migration.bat
```

### Step 2: Create PPO Regions (Super Admin Only)

1. **Login as Super Admin** (default admin user)
2. **Create PPO Regions:**
   - Region 1: "REGION1" 
   - Region 2: "REGION2"
   - Bohol: "BOHOL"
   - Cebu: "CEBU"

### Step 3: Assign PPO Admins

1. **Create users for each PPO Admin**
2. **Assign them to regions:**
   - User: admin_region1 → RegionCode: "REGION1", PttRole: "PPOAdmin"
   - User: admin_region2 → RegionCode: "REGION2", PttRole: "PPOAdmin"

### Step 4: Create Field Users

Each PPO Admin can create users in their region:
- User: user1_region1 → RegionCode: "REGION1", PttRole: "FieldUser"
- User: user2_region1 → RegionCode: "REGION1", PttRole: "FieldUser"

## 🔒 Security Rules

### Communication Rules:
- ✅ **Same Region**: Users can communicate within their region
- ❌ **Cross Region**: Users CANNOT communicate across regions
- ✅ **Super Admin**: Can communicate with ALL regions
- ✅ **PPO Admin**: Can manage only their region

### Access Control:
- **Super Admin**: Sees all groups, all regions
- **PPO Admin**: Sees only their region's groups
- **Field User**: Sees only groups they're member of

## 📱 Flutter Integration

### User Types in Mobile App:

1. **Super Admin Login** → Shows all regions and groups
2. **PPO Admin Login** → Shows only their region's groups
3. **Field User Login** → Shows only their assigned groups

### Example Login Flow:
```dart
// User logs in
final user = await PttAuthService.login(username, password);

// App determines what to show based on user type
switch (user.userType) {
  case PttUserType.superAdmin:
    // Show all regions dashboard
    break;
  case PttUserType.ppoAdmin:
    // Show only their region's groups
    break;
  case PttUserType.fieldUser:
    // Show only groups they're member of
    break;
}
```

## 🎯 Example Scenario

### Region 1 Setup:
1. **Super Admin** creates "REGION1" PPO
2. **Super Admin** assigns "admin_region1" as PPO Admin
3. **admin_region1** creates field users: user1, user2, user3
4. **admin_region1** creates groups: "Patrol Team A", "Traffic Unit"
5. **Users** can only communicate within Region 1 groups

### Communication Test:
- ✅ user1 (Region1) → user2 (Region1) = **ALLOWED**
- ❌ user1 (Region1) → user4 (Region2) = **BLOCKED**
- ✅ Super Admin → Anyone = **ALLOWED**

## 🚀 Implementation Status

### ✅ Completed:
- Database schema with RegionCode
- Security service with region isolation
- User entity with PTT roles
- Flutter login logic
- Communication restrictions

### 🔄 Next Steps:
1. Run database migration
2. Test user creation with regions
3. Implement Flutter UI
4. Test communication restrictions
5. Add voice transmission with region checks

## 📞 PTT Communication Flow

### When User Presses PTT:
1. **Check Region**: Verify user's region
2. **Get Recipients**: Only users in same region
3. **Transmit Voice**: Send to region members only
4. **Block Cross-Region**: Prevent unauthorized access

### Security Validation:
```csharp
// Before allowing communication
if (!await _pttSecurity.CanCommunicateWithGroup(groupId))
{
    throw new UnauthorizedException("Cannot communicate with this group");
}
```

## 🛠️ Configuration

### Database Tables:
- **Users**: Added RegionCode, PttRole
- **PttGroups**: Added RegionCode, security methods
- **PttGroupMembers**: Existing table for membership

### API Endpoints:
- `/api/PttSecurity/GetAccessibleGroups` - Get user's allowed groups
- `/api/PttSecurity/CanCommunicateWithGroup` - Check communication permission
- `/api/PttSecurity/GetCommunicableUsers` - Get users in same region

This system ensures **complete regional isolation** while maintaining administrative hierarchy! 🔒✅
