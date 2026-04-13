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
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // create permissions for web guard
        Permission::findOrCreate('manage reports', 'web');
        Permission::findOrCreate('assign reports', 'web');
        Permission::findOrCreate('update status', 'web');
        Permission::findOrCreate('view analytics', 'web');
        Permission::findOrCreate('manage users', 'web');
        Permission::findOrCreate('manage staff', 'web');

        // create permissions for staff guard
        Permission::findOrCreate('update status', 'staff');

        // create roles and assign created permissions

        // Staff role for staff guard
        $role = Role::findOrCreate('staff', 'staff');
        $role->givePermissionTo(['update status']);

        // Admin roles for web guard
        $role = Role::findOrCreate('admin', 'web')
            ->givePermissionTo(['manage reports', 'assign reports', 'view analytics', 'manage users', 'manage staff']);

        $role = Role::findOrCreate('super-admin', 'web');
        $role->givePermissionTo(Permission::where('guard_name', 'web')->get());

        // Create a super-admin user
        $admin = User::firstOrCreate(
            ['email' => 'admin@blockiqx.com'],
            [
                'name' => 'Admin User',
                'password' => bcrypt('password'),
            ]
        );
        $admin->assignRole('super-admin');

        // Create a sample staff user
        $staffUser = Staff::firstOrCreate(
            ['email' => 'staff@blockiqx.com'],
            [
                'name' => 'Staff User',
                'password' => bcrypt('password'),
            ]
        );
        $staffUser->assignRole('staff');
    }
}
