<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use App\Models\User;
use App\Models\Staff;

class RolesAndPermissionsSeeder extends Seeder
{
    public function run()
    {
        // ✅ Always clear cache FIRST
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // -----------------------------
        // WEB PERMISSIONS
        // -----------------------------
        $webPermissions = [
            'manage reports',
            'assign reports',
            'update status',
            'view analytics',
            'manage users',
            'manage staff',
        ];

        foreach ($webPermissions as $perm) {
            Permission::firstOrCreate([
                'name' => $perm,
                'guard_name' => 'web',
            ]);
        }

        // -----------------------------
        // STAFF PERMISSIONS
        // -----------------------------
        $staffPermissions = [
            'update status',
        ];

        foreach ($staffPermissions as $perm) {
            Permission::firstOrCreate([
                'name' => $perm,
                'guard_name' => 'staff',
            ]);
        }

        // -----------------------------
        // ROLES
        // -----------------------------

        // Staff role
        $staffRole = Role::firstOrCreate([
            'name' => 'staff',
            'guard_name' => 'staff',
        ]);

        $staffRole->syncPermissions($staffPermissions);

        // Admin role
        $adminRole = Role::firstOrCreate([
            'name' => 'admin',
            'guard_name' => 'web',
        ]);

        $adminRole->syncPermissions([
            'manage reports',
            'assign reports',
            'view analytics',
            'manage users',
            'manage staff',
        ]);

        // Super Admin
        $superAdmin = Role::firstOrCreate([
            'name' => 'super-admin',
            'guard_name' => 'web',
        ]);

        $superAdmin->syncPermissions(
            Permission::where('guard_name', 'web')->get()
        );

        // -----------------------------
        // USERS
        // -----------------------------

        $admin = User::firstOrCreate(
            ['email' => 'admin@blockiqx.com'],
            [
                'name' => 'Admin User',
                'password' => bcrypt('password'),
            ]
        );
        $admin->assignRole('super-admin');

        $staffUser = Staff::firstOrCreate(
            ['email' => 'staff@blockiqx.com'],
            [
                'name' => 'Staff User',
                'password' => bcrypt('password'),
            ]
        );
        $staffUser->assignRole('staff');

        // ✅ Clear cache AGAIN (important)
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();
    }
}
